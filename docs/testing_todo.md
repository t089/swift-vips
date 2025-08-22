# Testing TODO for SwiftVIPS Generated API

This document outlines all the areas that need tests for the generated libvips API. Tests are organized by module/category.

## Test Coverage Status Key
- ✅ Already tested
- 🚧 Partially tested
- ❌ Not tested
- 🎯 Priority for testing

## Arithmetic Operations `Sources/VIPS/Generated/arithmetic.generated.swift`

### Already Tested ✅
- Basic arithmetic operators (`+`, `-`, `*`, `/`)
- Trigonometric functions (`sin`, `cos`, `tan`, `asin`, `acos`, `atan`)
- Hyperbolic functions (`sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`)
- Exponential and logarithmic (`exp`, `exp10`, `log`, `log10`)
- Power operations (`pow`, `wop`, `atan2`)
- Bitwise operations (`andimage`, `orimage`, `eorimage`, `lshift`, `rshift`)
- Band operations (`bandand`, `bandor`, `bandeor`)
- Complex operations (`complex`, `polar`, `rect`, `conj`, `real`, `imag`)
- Statistical operations (`sum`, `stats`, `profile`, `project`)
- Linear operations (`linear` with various overloads)
- Remainder operations (`remainder`)

### Needs Testing ❌ 🎯
- `abs` - Absolute value
- `sign` - Sign function
- `round` - Rounding with mode
- `floor` - Floor operation
- `ceil` - Ceiling operation
- `rint` - Round to nearest integer
- `measure` - Measure labeled regions
- `getpoint` - Get pixel values
- `find` - Find image position
- `deviate` - Standard deviation
- `complexget` - Get complex component
- `complex2` - Complex binary operations
- `cross_phase` - Cross phase

## Colour Operations `Sources/VIPS/Generated/colour.generated.swift`

### Needs Testing ❌ 🎯
All colour operations need testing:
- Color space conversions:
  - `CMC2LCh`, `LCh2CMC`
  - `CMYK2XYZ`, `XYZ2CMYK`
  - `HSV2sRGB`, `sRGB2HSV`
  - `Lab2LCh`, `LCh2Lab`
  - `Lab2LabQ`, `LabQ2Lab`, `LabQ2sRGB`
  - `Lab2XYZ`, `XYZ2Lab`
  - `XYZ2Yxy`, `Yxy2XYZ`
  - `XYZ2scRGB`, `scRGB2XYZ`
  - `sRGB2scRGB`, `scRGB2sRGB`
  - `scRGB2BW`
- Color operations:
  - `colourspace` - General color space conversion
  - `falsecolour` - False color mapping
  - `labelregions` - Label connected regions
- ICC Profile operations:
  - `iccExport`
  - `iccImport`
  - `iccTransform`

## Conversion Operations `Sources/VIPS/Generated/conversion.generated.swift`

### Needs Testing ❌ 🎯
All conversion operations need testing:
- Geometric transforms:
  - `affine` - Affine transformation
  - `similarity` - Similarity transformation
  - `rotate` - Arbitrary rotation
  - `flip` - Flip horizontally/vertically
  - `rot` - Fixed rotations (90, 180, 270)
  - `rot45` - 45-degree rotations
  - `transpose3d` - 3D transpose
- Resizing operations:
  - `resize` - Smart resize
  - `reduce`, `reduceh`, `reducev` - High-quality reduction
  - `shrink`, `shrinkh`, `shrinkv` - Integer shrinking
  - `scale` - Scale to 0-255
- Cropping and embedding:
  - `crop` - Extract rectangular area
  - `smartcrop` - Intelligent cropping
  - `embed` - Embed in larger image
  - `extractArea` - Extract area
  - `extractBand` - Extract band(s)
- Joining operations:
  - `bandjoin` - Join bands (arrays of images)
  - `bandjoinConst` - Join constant bands
  - `join` - Join two images
  - `insert` - Insert sub-image
  - `grid` - Arrange in grid
- Image properties:
  - `autorot` - Auto-rotate based on EXIF
  - `cast` - Cast to different format
  - `copy` - Copy with modifications
  - `recomb` - Recombination
- Compositing:
  - `composite2` - Composite two images
- Caching:
  - `tilecache` - Add tile cache

## Convolution Operations `Sources/VIPS/Generated/convolution.generated.swift`

### Needs Testing ❌ 🎯
All convolution operations need testing:
- `blur` - Box blur
- `canny` - Canny edge detector
- `compass` - Compass edge filter
- `conv` - Convolution with matrix
- `conva` - Approximate convolution
- `convasep` - Approximate separable convolution
- `convf` - Float convolution
- `convi` - Integer convolution
- `convsep` - Separable convolution
- `fastcor` - Fast correlation
- `gaussblur` - Gaussian blur
- `scharr` - Scharr edge detector
- `sharpen` - Unsharp mask
- `sobel` - Sobel edge detector

## Create Operations `Sources/VIPS/Generated/create.generated.swift`

### Already Tested 🚧
- `black` - Create black image (used in tests)
- `identity` - Identity LUT (used in tests)

### Needs Testing ❌ 🎯
- `buildlut` - Build lookup table
- `eye` - Eye test pattern
- `fractsurf` - Fractal surface
- `gaussmat` - Gaussian matrix
- `gaussnoise` - Gaussian noise
- `grey` - Grey ramp
- `invertlut` - Invert LUT
- `logmat` - Log polar matrix
- `mask_butterworth` - Butterworth mask
- `mask_gaussian` - Gaussian mask  
- `mask_ideal` - Ideal frequency mask
- `perlin` - Perlin noise
- `sines` - Sine wave pattern
- `text` - Text rendering
- `tonelut` - Tone curve LUT
- `worley` - Worley noise
- `xyz` - XYZ coordinate image
- `zone` - Zone plate

## Resample Operations `Sources/VIPS/Generated/resample.generated.swift`

### Needs Testing ❌ 🎯
- `affine` - Affine transformation
- `mapim` - Map with index image
- `quadratic` - Quadratic transformation
- `reduce` - High-quality reduce
- `reduceh` - Horizontal reduce
- `reducev` - Vertical reduce
- `resize` - Smart resize
- `rotate` - Arbitrary rotation
- `shrink` - Integer shrink
- `shrinkh` - Horizontal shrink
- `shrinkv` - Vertical shrink
- `similarity` - Similarity transformation
- `thumbnail` - Create thumbnail
- `thumbnailBuffer` - Thumbnail from buffer
- `thumbnailImage` - Thumbnail from image
- `thumbnailSource` - Thumbnail from source

## Histogram Operations `Sources/VIPS/Generated/histogram.generated.swift`

### Needs Testing ❌ 🎯
- `case` - Case operation
- `histCum` - Cumulative histogram
- `histEntropy` - Histogram entropy
- `histEqual` - Histogram equalization
- `histFind` - Find histogram
- `histFindIndexed` - Indexed histogram
- `histFindNdim` - N-dimensional histogram
- `histIsmonotonic` - Check monotonic
- `histLocal` - Local histogram equalization
- `histMatch` - Match histograms
- `histNorm` - Normalize histogram
- `histPlot` - Plot histogram
- `maplut` - Map through LUT
- `percent` - Find percentile
- `stdif` - Standard deviation filter

## Morphology Operations `Sources/VIPS/Generated/morphology.generated.swift`

### Needs Testing ❌ 🎯
- `countlines` - Count lines
- `fillNearest` - Fill with nearest
- `labelregions` - Label regions
- `morph` - Morphological operation
- `rank` - Rank filter

## Frequency Filter Operations `Sources/VIPS/Generated/freqfilt.generated.swift`

### Needs Testing ❌
- `freqmult` - Frequency multiplication
- `fwfft` - Forward FFT
- `invfft` - Inverse FFT
- `phasecor` - Phase correlation
- `spectrum` - Spectrum

## Misc Operations `Sources/VIPS/Generated/misc.generated.swift`

### Needs Testing ❌
- `copy` - Copy operation
- `getpoint` - Get point value
- Various other utility operations

## Foreign (Import/Export) Operations

### Needs Testing ❌ 🎯

#### JPEG `Sources/VIPS/Generated/Foreign/foreign_jpeg.generated.swift`
- `jpegload` - Load JPEG from file
- `jpegloadBuffer` - Load JPEG from buffer
- `jpegloadSource` - Load JPEG from source
- `jpegsave` - Save as JPEG file
- `jpegsaveBuffer` - Save as JPEG buffer
- `jpegsaveTarget` - Save to JPEG target
- `jpegsaveMime` - Save with MIME type

#### PNG `Sources/VIPS/Generated/Foreign/foreign_png.generated.swift`
- `pngload` - Load PNG from file
- `pngloadBuffer` - Load PNG from buffer
- `pngloadSource` - Load PNG from source
- `pngsave` - Save as PNG file
- `pngsaveBuffer` - Save as PNG buffer
- `pngsaveTarget` - Save to PNG target

#### WebP `Sources/VIPS/Generated/Foreign/foreign_webp.generated.swift`
- `webpload` - Load WebP from file
- `webploadBuffer` - Load WebP from buffer
- `webploadSource` - Load WebP from source
- `webpsave` - Save as WebP file
- `webpsaveBuffer` - Save as WebP buffer
- `webpsaveTarget` - Save to WebP target
- `webpsaveMime` - Save with MIME type

#### TIFF `Sources/VIPS/Generated/Foreign/foreign_tiff.generated.swift`
- `tiffload` - Load TIFF from file
- `tiffloadBuffer` - Load TIFF from buffer
- `tiffloadSource` - Load TIFF from source
- `tiffsave` - Save as TIFF file
- `tiffsaveBuffer` - Save as TIFF buffer
- `tiffsaveTarget` - Save to TIFF target

#### HEIF `Sources/VIPS/Generated/Foreign/foreign_heif.generated.swift`
- `heifload` - Load HEIF from file
- `heifloadBuffer` - Load HEIF from buffer
- `heifloadSource` - Load HEIF from source
- `heifsave` - Save as HEIF file
- `heifsaveBuffer` - Save as HEIF buffer
- `heifsaveTarget` - Save to HEIF target

#### GIF `Sources/VIPS/Generated/Foreign/foreign_gif.generated.swift`
- `gifload` - Load GIF from file
- `gifloadBuffer` - Load GIF from buffer
- `gifloadSource` - Load GIF from source
- `gifsave` - Save as GIF file (if available)
- `gifsaveBuffer` - Save as GIF buffer
- `gifsaveTarget` - Save to GIF target

#### SVG `Sources/VIPS/Generated/Foreign/foreign_svg.generated.swift`
- `svgload` - Load SVG from file
- `svgloadBuffer` - Load SVG from buffer
- `svgloadSource` - Load SVG from source
- `svgloadString` - Load SVG from string

#### PDF `Sources/VIPS/Generated/Foreign/foreign_pdf.generated.swift`
- `pdfload` - Load PDF from file
- `pdfloadBuffer` - Load PDF from buffer
- `pdfloadSource` - Load PDF from source

#### Other Formats `Sources/VIPS/Generated/Foreign/foreign_other.generated.swift`
- Various other format loaders and savers

## Testing Priority Order

### Phase 1: Core Operations 🎯
1. **Conversion basics**: `crop`, `extractBand`, `bandjoin`, `cast`, `flip`, `rot`
2. **Create basics**: `gaussnoise`, `grey`, `text`, `eye`
3. **Colour basics**: `sRGB2HSV`, `HSV2sRGB`, `colourspace`
4. **Convolution basics**: `gaussblur`, `sharpen`, `sobel`

### Phase 2: Image I/O 🎯
1. **JPEG operations**: Load/save with various options
2. **PNG operations**: Load/save with compression options
3. **WebP operations**: Load/save with quality settings
4. **TIFF operations**: Multi-page support

### Phase 3: Advanced Processing
1. **Histogram operations**: Equalization, matching
2. **Morphology operations**: Erosion, dilation
3. **Resample operations**: High-quality resizing
4. **Advanced colour**: ICC profiles, Lab conversions

### Phase 4: Specialized Operations
1. **Frequency domain**: FFT operations
2. **Advanced create**: Noise generators, patterns
3. **Foreign formats**: SVG, PDF, GIF
4. **Misc operations**: Utility functions

## Test Implementation Guidelines

1. **Test File Organization**:
   - Create separate test files for each category
   - E.g., `ColourOperationsTests.swift`, `ConversionOperationsTests.swift`

2. **Test Structure**:
   - Use Swift Testing framework (not XCTest)
   - Mark suites with `@Suite(.serialized)` to prevent resource conflicts
   - Create simple, predictable test images
   - Verify results with known expected values

3. **Test Coverage Goals**:
   - Test basic functionality of each operation
   - Test with different image formats (uchar, float, etc.)
   - Test with single and multi-band images
   - Test error conditions and edge cases
   - Test optional parameters with various values

4. **Resource Management**:
   - Use test images from `Tests/VIPSTests/data/` when needed
   - Create synthetic test images programmatically when possible
   - Clean up temporary files after tests

5. **Performance Considerations**:
   - Keep test images small (e.g., 10x10, 100x100)
   - Focus on correctness, not performance in unit tests
   - Add separate performance tests if needed