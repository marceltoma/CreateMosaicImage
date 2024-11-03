
# Video Thumbnail Mosaic Creator

This script takes a video file and generates a 3x3 mosaic image of evenly spaced thumbnails, 
providing a quick visual summary of the video content.

## Tools and Dependencies

This script uses the following tools:
- **ffmpeg**: Required to extract frames from the video.
- **ImageMagick (montage)**: Required to create the mosaic image from individual frames.
- **bc**: Used for precise floating-point arithmetic within the script.
- **awk**: Used for handling integer extraction.

Ensure these tools are installed and accessible in your system's PATH.

## Usage Instructions

1. Clone the repository and navigate to the directory containing the script.
2. Make the script executable:
   ```bash
   chmod +x createThumbnail.sh
   ```
3. Run the script with a specified video file:
   ```bash
   ./createThumbnail.sh path/to/your_video.mp4
   ```

This will create a `mosaic.jpg` file in the same directory as the input video file, 
with frames evenly spaced throughout the video.

## Constraints and Limitations

- **Dependencies**: Ensure `ffmpeg`, `ImageMagick`, `bc`, and `awk` are installed.
- **Video File Duration**: The script is optimized for videos longer than approximately 10 seconds. 
  For shorter videos, spacing between frames might be very close.
- **Locale**: This script assumes a locale where the decimal separator is `.`. Ensure `LC_ALL` is set to `C` or `en_US.UTF-8` to avoid issues.
- **Output Directory**: The script creates a temporary directory for frames, which it deletes after the mosaic is created. Ensure write permissions are available.

