# VIPS Swift Module Organization

This directory contains Swift bindings for libvips, organized to mirror the modular structure of the libvips C library.

## Directory Structure

### Core/
Core VIPS functionality including initialization, error handling, and fundamental image types.
- **VIPS.swift** - Main initialization and error handling
- **Enums/** - Core enum types (VipsImageType, VipsBandFormat, VipsInterpretation, etc.)

### Arithmetic/
Arithmetic and mathematical operations on images.
- **operators.swift** - Arithmetic operator implementations
- **Enums/** - Math operation enums (VipsOperationMath, VipsOperationBoolean, etc.)

### Colour/
Color space conversions and color management.
- **colour.swift** - Color conversion functions
- **Enums/** - Color-related enums (VipsIntent, VipsPCS)

### Conversion/
Image format and geometric conversions.
- **conversion.swift** - Conversion functions
- **Enums/** - Conversion enums (VipsExtend, VipsAlign, VipsAngle, etc.)

### Convolution/
Convolution and filtering operations.
- **convolution.swift** - Convolution functions
- **Enums/** - Convolution enums (VipsCombine, VipsPrecision)

### Create/
Image creation and generation functions.
- **create.swift** - Image creation functions
- **Enums/** - Creation enums (VipsTextWrap, VipsSdfShape)

### Draw/
Drawing operations and compositing.
- **Enums/** - Drawing enums (VipsBlendMode, VipsCombineMode)

### Foreign/
Foreign file format support (loading and saving various image formats).
- **Enums/** - Format-specific enums organized by type:
  - **TIFF/** - TIFF format options
  - **PNG/** - PNG format options
  - **WebP/** - WebP format options
  - **DeepZoom/** - Deep Zoom tiling options
  - **HEIF/** - HEIF/HEIC format options
  - **PPM/** - PPM/PGM/PBM format options

### Histogram/
Histogram operations and analysis.
- **histogram.swift** - Histogram functions

### Morphology/
Morphological operations (erosion, dilation, etc.).
- **Enums/** - Morphology enums (VipsOperationMorphology)

### Resample/
Image resampling and resizing operations.
- **resample.swift** - Resample functions
- **Enums/** - Resample enums (VipsKernel, VipsSize, VipsRegionShrink)

## Usage

Each module corresponds to a specific area of image processing functionality. Import the main VIPS module and access submodules as needed:

```swift
import VIPS

// Initialize VIPS
try VIPS.start()

// Use various module functionality
// Color conversions, arithmetic operations, etc.
```

## Adding New Functionality

When adding new bindings:
1. Identify the corresponding libvips module
2. Place enum extensions in the appropriate `Module/Enums/` directory
3. Place function implementations in the module's main Swift file
4. For foreign formats, create subdirectories for format-specific enums