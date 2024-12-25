# WebP Batch Converter

A powerful macOS application for batch converting and optimizing images to WebP format with AI-powered quality optimization.

![App Screenshot](screenshots/main-window.png)

## Features

- **Smart Optimization**: AI-powered image analysis for optimal quality settings
- **Batch Processing**: Convert multiple images at once
- **Side-by-Side Comparison**: Compare original and optimized images
- **Quality Presets**: Choose from multiple optimization presets
  - Maximum Quality (1MB target)
  - Balanced (500KB target)
  - Aggressive Compression (200KB target)
  - Custom size target
- **Content-Aware**: Automatically adjusts settings based on image content type
- **Real-Time Preview**: See the results immediately
- **Progress Tracking**: Monitor conversion progress and results
- **History**: Keep track of processed images and their optimization results

## Requirements

- macOS 12.0 or later
- Xcode 13.0 or later (for building)

## Installation

1. Clone the repository:
git clone https://github.com/d4lvl13n/Image-Resizer.git

2. Open the project in Xcode:
bash
cd Image-Resizer
open Package.swift


3. Build and run the project in Xcode

## Usage

1. Select input folder containing your images
2. Choose output folder for WebP files
3. Configure optimization settings:
   - Enable Smart Optimization for AI-powered quality settings
   - Choose a preset or set custom target size
   - Adjust target width if needed
4. Click "Convert Images" to start the process
5. Review results in the side-by-side comparison view

## Building from Source

The project uses Swift Package Manager for dependencies. To build from the command line:

bash
swift build

bash
swift run


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Uses [cwebp](https://developers.google.com/speed/webp/docs/cwebp) for WebP conversion
- Built with SwiftUI and Vision framework