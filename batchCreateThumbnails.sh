#!/bin/bash

set -x

# Usage: ./batchCreateThumbnails.sh /path/to/directory
# This script takes a root directory as an argument and runs createThumbnail.sh
# on all video files in all subdirectories.

# Check if directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

ROOT_DIR="$1"

# Check if the specified directory exists
if [ ! -d "$ROOT_DIR" ]; then
    echo "Error: Directory $ROOT_DIR does not exist."
    exit 1
fi

echo "Root dir: $ROOT_DIR"

# Loop through all video files in subdirectories
find "$ROOT_DIR" -type f \( -name "*.mp4" -o -name "*.mov" -o -name "*.avi" -o -name "*.mkv" \) | while IFS= read -r video_file; do
    echo "Processing video: $video_file"
    ./createThumbnail.sh "$video_file"  # Quote the variable to handle spaces/special characters
done

echo "Batch thumbnail creation completed."

