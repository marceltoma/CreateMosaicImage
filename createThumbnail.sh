#!/bin/bash

# Enable debugging
# set -x  # Uncomment this line to enable debugging

# Set locale to ensure decimal separator is '.'
export LC_ALL=C
export LANG=C

# Function to replace comma with dot in numbers
sanitize_number() {
  echo "$1" | tr ',' '.'
}

# Function to perform calculations with bc, ensuring proper decimal separator and limited scale
calculate() {
  echo "scale=6; $1" | tr ',' '.' | bc -l 2>/dev/null
}

# Function to get the integer part of a number
get_integer_part() {
  echo "$1" | awk '{printf("%d", $1)}'
}

# Check if a video file was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <video_file>"
  exit 1
fi

# Input video file from the first argument
VIDEO_FILE="$1"

# Get the directory and base name of the video file
VIDEO_DIR="$(dirname "$VIDEO_FILE")"
BASENAME="$(basename "$VIDEO_FILE" | cut -f 1 -d '.')"

# Output image name in the same directory as the video
OUTPUT_IMAGE="${VIDEO_DIR}/${BASENAME}_mosaic.jpg"

# Temporary directory for frames
TEMP_DIR="/tmp/frames_${BASENAME}"
mkdir -p "$TEMP_DIR"

# Calculate video duration in seconds using ffprobe
DURATION="$(ffprobe -v error -select_streams v:0 -show_entries stream=duration \
           -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")"

# If DURATION is empty, try to get it from format
if [ -z "$DURATION" ]; then
  DURATION="$(ffprobe -v error -show_entries format=duration \
             -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")"
fi

# Replace comma with dot in DURATION
DURATION="$(sanitize_number "$DURATION")"

# Check if duration was obtained successfully
if [ -z "$DURATION" ]; then
  echo "Error: Could not retrieve video duration."
  exit 1
fi

# Calculate interval between frames to capture 9 evenly spaced frames
INTERVAL="$(calculate "$DURATION / 10")"

# Capture 9 frames at intervals
for i in $(seq 1 9); do
  # Calculate the timestamp in seconds for each frame
  TIMESTAMP="$(calculate "$i * $INTERVAL")"

  # Compute hours, minutes, seconds
  HOURS_DECIMAL="$(calculate "$TIMESTAMP / 3600")"
  HOURS="$(get_integer_part "$HOURS_DECIMAL")"

  REMAINDER="$(calculate "$TIMESTAMP - ($HOURS * 3600)")"

  MINUTES_DECIMAL="$(calculate "$REMAINDER / 60")"
  MINUTES="$(get_integer_part "$MINUTES_DECIMAL")"

  SEC="$(calculate "$REMAINDER - ($MINUTES * 60)")"

  # Format with leading zeros
  HOURS="$(printf "%02d" "$HOURS")"
  MINUTES="$(printf "%02d" "$MINUTES")"
  SEC="$(printf "%06.3f" "$SEC")"

  # Combine into HH:MM:SS.mmm format for ffmpeg
  TIMESTAMP_FORMATTED="${HOURS}:${MINUTES}:${SEC}"

  # Capture the frame at the specified timestamp
  OUTPUT_FRAME="${TEMP_DIR}/frame_${i}.jpg"
  ffmpeg -nostdin -y -loglevel error -ss "$TIMESTAMP_FORMATTED" -i "$VIDEO_FILE" -frames:v 1 -q:v 2 "$OUTPUT_FRAME"
done

# Create a 3x3 mosaic using ImageMagick
montage "${TEMP_DIR}/frame_"*.jpg -tile 3x3 -geometry +0+0 "$OUTPUT_IMAGE"

# Cleanup temporary frames
rm -rf "$TEMP_DIR"

echo "Mosaic created in video directory: $OUTPUT_IMAGE"

