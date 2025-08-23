# SwiftVIPS Testing TODO

This document tracks the testing status of all generated API functions in SwiftVIPS. The generated API includes 196+ functions across multiple modules that need comprehensive test coverage.

## Testing Status Overview

- ✅ **Partially Tested**: Basic arithmetic operations (sin, cos, tan, abs, sign, round, relational)
- ⚠️ **Minimal Tests**: Basic image loading, resizing, thumbnail, export operations
- ❌ **Not Tested**: Most generated API functions (180+ functions)

## Testing Priority Levels

### Priority 1: Core Operations (IMMEDIATE)
These are fundamental operations used frequently by users.

#### Arithmetic Operations (`arithmetic.generated.swift`)
- [ ] `add` - Addition operations (image + image, image + constant)
- [ ] `subtract` - Subtraction operations
- [ ] `multiply` - Multiplication operations  
- [ ] `divide` - Division operations
- [ ] `remainder` - Modulo operations
- [ ] `pow` - Power operations
- [ ] `wop` - Weighted operations
- [ ] `linear` - Linear transformations
- [ ] `math` - Mathematical operations (exp, log, etc.)
- [ ] `math2` - Two-input math operations
- [ ] `complex` - Complex number operations
- [ ] `complexget` - Complex component extraction
- [ ] `complex2` - Two-input complex operations
- [ ] `complexform` - Complex form conversion
- [ ] `boolean` - Boolean operations (AND, OR, XOR)
- [ ] `booleanConst` - Boolean operations with constants
- [ ] `relational` - Relational comparisons
- [ ] `relationalConst` - Relational comparisons with constants
- [ ] `abs` - Absolute value (partial coverage exists)
- [ ] `sign` - Sign operation (partial coverage exists)
- [ ] `round` - Rounding operations (partial coverage exists)
- [ ] `floor` - Floor operations
- [ ] `ceil` - Ceiling operations
- [ ] `rint` - Round to integer
- [ ] `invert` - Bitwise inversion
- [ ] `avg` - Average calculation (basic test exists)
- [ ] `deviate` - Standard deviation
- [ ] `min` - Minimum value
- [ ] `max` - Maximum value
- [ ] `stats` - Statistical analysis
- [ ] `sum` - Sum of pixels
- [ ] `histogram` - Histogram calculation

#### Conversion Operations (`conversion.generated.swift`)
- [ ] `cast` - Type casting between formats
- [ ] `copy` - Image copying
- [ ] `tilecache` - Tile caching
- [ ] `linecache` - Line caching  
- [ ] `sequential` - Sequential access
- [ ] `cache` - General caching
- [ ] `embed` - Embed image in larger image
- [ ] `flip` - Flip operations
- [ ] `rot` - Rotation operations
- [ ] `rot45` - 45-degree rotations
- [ ] `autorot` - Automatic rotation
- [ ] `zoom` - Zoom operations
- [ ] `wrap` - Wrap operations
- [ ] `bandjoin` - Join bands
- [ ] `bandjoinConst` - Join bands with constants
- [ ] `bandmean` - Band mean
- [ ] `bandbool` - Boolean operations on bands
- [ ] `bandand` - Bitwise AND on bands
- [ ] `bandor` - Bitwise OR on bands
- [ ] `bandeor` - Bitwise XOR on bands
- [ ] `bandfold` - Fold bands
- [ ] `bandunfold` - Unfold bands
- [ ] `flatten` - Flatten alpha
- [ ] `premultiply` - Premultiply alpha
- [ ] `unpremultiply` - Unpremultiply alpha
- [ ] `grid` - Grid layout
- [ ] `scale` - Scale operations
- [ ] `shrink` - Shrink operations
- [ ] `shrinkh` - Horizontal shrink
- [ ] `shrinkv` - Vertical shrink
- [ ] `reduce` - Reduce operations
- [ ] `reduceh` - Horizontal reduce
- [ ] `reducev` - Vertical reduce
- [ ] `quadratic` - Quadratic transformations
- [ ] `affine` - Affine transformations
- [ ] `similarity` - Similarity transformations
- [ ] `rotate` - Rotation transformations
- [ ] `resize` - Resize operations (basic test exists)
- [ ] `colourspace` - Color space conversion
- [ ] `Lab2XYZ` - Lab to XYZ conversion
- [ ] `Lab2LCh` - Lab to LCh conversion
- [ ] `LCh2Lab` - LCh to Lab conversion
- [ ] `LCh2CMC` - LCh to CMC conversion
- [ ] `CMC2LCh` - CMC to LCh conversion
- [ ] `XYZ2Lab` - XYZ to Lab conversion
- [ ] `XYZ2Yxy` - XYZ to Yxy conversion
- [ ] `Yxy2XYZ` - Yxy to XYZ conversion
- [ ] `scRGB2XYZ` - scRGB to XYZ conversion
- [ ] `XYZ2scRGB` - XYZ to scRGB conversion
- [ ] `LabQ2Lab` - LabQ to Lab conversion
- [ ] `Lab2LabQ` - Lab to LabQ conversion
- [ ] `LabQ2LabS` - LabQ to LabS conversion
- [ ] `LabS2LabQ` - LabS to LabQ conversion
- [ ] `LabS2Lab` - LabS to Lab conversion
- [ ] `Lab2LabS` - Lab to LabS conversion
- [ ] `rad2float` - Radians to float
- [ ] `float2rad` - Float to radians
- [ ] `LabQ2sRGB` - LabQ to sRGB
- [ ] `sRGB2scRGB` - sRGB to scRGB
- [ ] `scRGB2BW` - scRGB to black/white
- [ ] `sRGB2HSV` - sRGB to HSV
- [ ] `HSV2sRGB` - HSV to sRGB
- [ ] `icc_import` - ICC profile import
- [ ] `icc_export` - ICC profile export
- [ ] `icc_transform` - ICC transformation
- [ ] `dE76` - Delta E 1976
- [ ] `dE00` - Delta E 2000
- [ ] `dECMC` - Delta E CMC
- [ ] `CMYK2XYZ` - CMYK to XYZ
- [ ] `XYZ2CMYK` - XYZ to CMYK
- [ ] `profile_load` - Load ICC profile
- [ ] `addalpha` - Add alpha channel
- [ ] `byteswap` - Byte swapping
- [ ] `falsecolour` - False color mapping
- [ ] `gamma` - Gamma correction

### Priority 2: Image Creation & Manipulation

#### Create Operations (`create.generated.swift`)
- [ ] `black` - Create black image (used in tests but not tested directly)
- [ ] `gaussnoise` - Gaussian noise
- [ ] `text` - Text rendering (basic test exists)
- [ ] `xyz` - XYZ image
- [ ] `gaussmat` - Gaussian matrix
- [ ] `logmat` - Laplacian of Gaussian matrix
- [ ] `eye` - Identity matrix
- [ ] `grey` - Grey ramp
- [ ] `zone` - Zone plate
- [ ] `sines` - Sine wave pattern
- [ ] `mask_ideal` - Ideal filter mask
- [ ] `mask_ideal_ring` - Ideal ring filter
- [ ] `mask_ideal_band` - Ideal band filter
- [ ] `mask_butterworth` - Butterworth filter
- [ ] `mask_butterworth_ring` - Butterworth ring filter
- [ ] `mask_butterworth_band` - Butterworth band filter
- [ ] `mask_gaussian` - Gaussian filter
- [ ] `mask_gaussian_ring` - Gaussian ring filter
- [ ] `mask_gaussian_band` - Gaussian band filter
- [ ] `mask_fractal` - Fractal mask
- [ ] `tonelut` - Tone curve LUT
- [ ] `identity` - Identity LUT
- [ ] `fractsurf` - Fractal surface
- [ ] `radload` - Load Radiance format
- [ ] `ppmload` - Load PPM
- [ ] `csvload` - Load CSV
- [ ] `matrixload` - Load matrix
- [ ] `rawload` - Load raw data
- [ ] `vipsload` - Load VIPS format

#### Convolution Operations (`convolution.generated.swift`)
- [ ] `conv` - Convolution
- [ ] `conva` - Convolution with accuracy
- [ ] `convf` - Float convolution
- [ ] `convi` - Integer convolution
- [ ] `compass` - Compass gradient
- [ ] `convsep` - Separable convolution
- [ ] `convasep` - Accurate separable convolution
- [ ] `fastcor` - Fast correlation
- [ ] `spcor` - Spatial correlation
- [ ] `sharpen` - Sharpen filter
- [ ] `gaussblur` - Gaussian blur
- [ ] `canny` - Canny edge detection
- [ ] `sobel` - Sobel edge detection

#### Morphology Operations (`morphology.generated.swift`)
- [ ] `morph` - Morphological operations
- [ ] `rank` - Rank filter
- [ ] `countlines` - Count lines
- [ ] `labelregions` - Label regions
- [ ] `fillnearest` - Fill nearest

#### Histogram Operations (`histogram.generated.swift`)
- [ ] `histogram` - Generate histogram
- [ ] `hist_cum` - Cumulative histogram
- [ ] `hist_norm` - Normalize histogram
- [ ] `hist_equal` - Histogram equalization
- [ ] `hist_plot` - Plot histogram
- [ ] `hist_match` - Histogram matching
- [ ] `hist_local` - Local histogram equalization
- [ ] `hist_ismonotonic` - Check if monotonic
- [ ] `hist_entropy` - Histogram entropy

#### Resample Operations (`resample.generated.swift`)
- [ ] `shrink` - Shrink image
- [ ] `shrinkh` - Shrink horizontally
- [ ] `shrinkv` - Shrink vertically
- [ ] `reduce` - Reduce image
- [ ] `reduceh` - Reduce horizontally
- [ ] `reducev` - Reduce vertically
- [ ] `thumbnail` - Generate thumbnail (basic test exists)
- [ ] `thumbnail_image` - Thumbnail from image (basic test exists)
- [ ] `mapim` - Map image
- [ ] `affine` - Affine transformation
- [ ] `similarity` - Similarity transformation
- [ ] `rotate` - Rotate image
- [ ] `resize` - Resize image (basic test exists)
- [ ] `quadratic` - Quadratic transformation

### Priority 3: File Format Support

#### Foreign Operations (Multiple files)
- [ ] **JPEG** (`foreign_jpeg.generated.swift`)
  - [ ] `jpegload` - Load JPEG
  - [ ] `jpegload_buffer` - Load JPEG from buffer
  - [ ] `jpegload_source` - Load JPEG from source
  - [ ] `jpegsave` - Save as JPEG
  - [ ] `jpegsave_buffer` - Save JPEG to buffer
  - [ ] `jpegsave_target` - Save JPEG to target
  - [ ] `jpegsave_mime` - Save JPEG as MIME

- [ ] **PNG** (`foreign_png.generated.swift`)
  - [ ] `pngload` - Load PNG
  - [ ] `pngload_buffer` - Load PNG from buffer
  - [ ] `pngload_source` - Load PNG from source
  - [ ] `pngsave` - Save as PNG
  - [ ] `pngsave_buffer` - Save PNG to buffer
  - [ ] `pngsave_target` - Save PNG to target

- [ ] **WebP** (`foreign_webp.generated.swift`)
  - [ ] `webpload` - Load WebP
  - [ ] `webpload_buffer` - Load WebP from buffer
  - [ ] `webpload_source` - Load WebP from source
  - [ ] `webpsave` - Save as WebP
  - [ ] `webpsave_buffer` - Save WebP to buffer (basic test exists)
  - [ ] `webpsave_target` - Save WebP to target
  - [ ] `webpsave_mime` - Save WebP as MIME

- [ ] **TIFF** (`foreign_tiff.generated.swift`)
  - [ ] `tiffload` - Load TIFF
  - [ ] `tiffload_buffer` - Load TIFF from buffer
  - [ ] `tiffload_source` - Load TIFF from source
  - [ ] `tiffsave` - Save as TIFF
  - [ ] `tiffsave_buffer` - Save TIFF to buffer
  - [ ] `tiffsave_target` - Save TIFF to target

- [ ] **HEIF/AVIF** (`foreign_heif.generated.swift`)
  - [ ] `heifload` - Load HEIF
  - [ ] `heifload_buffer` - Load HEIF from buffer
  - [ ] `heifload_source` - Load HEIF from source
  - [ ] `heifsave` - Save as HEIF (basic AVIF test exists)
  - [ ] `heifsave_buffer` - Save HEIF to buffer
  - [ ] `heifsave_target` - Save HEIF to target

- [ ] **GIF** (`foreign_gif.generated.swift`)
  - [ ] `gifload` - Load GIF
  - [ ] `gifload_buffer` - Load GIF from buffer
  - [ ] `gifload_source` - Load GIF from source
  - [ ] `gifsave` - Save as GIF
  - [ ] `gifsave_buffer` - Save GIF to buffer
  - [ ] `gifsave_target` - Save GIF to target

- [ ] **PDF** (`foreign_pdf.generated.swift`)
  - [ ] `pdfload` - Load PDF
  - [ ] `pdfload_buffer` - Load PDF from buffer
  - [ ] `pdfload_source` - Load PDF from source

- [ ] **SVG** (`foreign_svg.generated.swift`)
  - [ ] `svgload` - Load SVG
  - [ ] `svgload_buffer` - Load SVG from buffer
  - [ ] `svgload_source` - Load SVG from source

- [ ] **Other Formats** (`foreign_other.generated.swift`)
  - [ ] `csvload` - Load CSV
  - [ ] `csvsave` - Save as CSV
  - [ ] `matrixload` - Load matrix
  - [ ] `matrixsave` - Save as matrix
  - [ ] `matrixprint` - Print matrix
  - [ ] `rawload` - Load raw
  - [ ] `rawsave` - Save as raw
  - [ ] `vipsload` - Load VIPS format
  - [ ] `vipssave` - Save as VIPS format
  - [ ] `ppmload` - Load PPM
  - [ ] `ppmsave` - Save as PPM
  - [ ] `radload` - Load Radiance
  - [ ] `radsave` - Save as Radiance
  - [ ] `magickload` - Load via ImageMagick
  - [ ] `magickload_buffer` - Load via ImageMagick from buffer
  - [ ] `magicksave` - Save via ImageMagick
  - [ ] `magicksave_buffer` - Save via ImageMagick to buffer

### Priority 4: Advanced Operations

#### Frequency Filter Operations (`freqfilt.generated.swift`)
- [ ] `fwfft` - Forward FFT
- [ ] `invfft` - Inverse FFT
- [ ] `freqmult` - Frequency multiply
- [ ] `spectrum` - Spectrum
- [ ] `phasecor` - Phase correlation

#### Miscellaneous Operations (`misc.generated.swift`)
- [ ] `copy` - Copy image
- [ ] `tilecache` - Tile cache
- [ ] `linecache` - Line cache
- [ ] `sequential` - Sequential mode
- [ ] `cache` - Cache
- [ ] `embed` - Embed image
- [ ] `gravity` - Gravity positioning
- [ ] `flip` - Flip image
- [ ] `insert` - Insert image
- [ ] `join` - Join images
- [ ] `extract_area` - Extract area
- [ ] `crop` - Crop image
- [ ] `smartcrop` - Smart crop
- [ ] `extract_band` - Extract band
- [ ] `bandrank` - Band rank
- [ ] `bandmean` - Band mean
- [ ] `recomb` - Recombination
- [ ] `ifthenelse` - If-then-else
- [ ] `switch` - Switch operation
- [ ] `flatten` - Flatten alpha
- [ ] `premultiply` - Premultiply alpha
- [ ] `unpremultiply` - Unpremultiply alpha
- [ ] `grid` - Grid layout
- [ ] `transpose3d` - 3D transpose
- [ ] `wrap` - Wrap image
- [ ] `rot` - Rotate 90/180/270
- [ ] `rot45` - Rotate 45 degrees
- [ ] `rot180` - Rotate 180 degrees
- [ ] `rot270` - Rotate 270 degrees
- [ ] `rot90` - Rotate 90 degrees
- [ ] `scale` - Scale image
- [ ] `subsample` - Subsample
- [ ] `msb` - Most significant bits
- [ ] `slice` - Slice image
- [ ] `arrayjoin` - Join array
- [ ] `composite` - Composite images
- [ ] `composite2` - Composite two images

## Test Implementation Guidelines

### Test Structure
1. Each generated file should have a corresponding test file
2. Use Swift Testing framework (not XCTest)
3. All test suites should use `@Suite(.serialized)` to prevent resource conflicts
4. Group related operations in logical test functions

### Test Data Requirements
- Small test images (3x3, 10x10) for mathematical operations
- Real images for format conversion tests (bay.jpg, mythical_giant.jpg)
- Generated patterns for filter tests
- Edge cases: empty images, single pixel, large images

### Test Coverage Goals
- Basic functionality test for each operation
- Parameter variation tests (different options)
- Error handling tests (invalid inputs)
- Memory management tests (no leaks)
- Performance benchmarks for critical operations

### Example Test Pattern
```swift
@Test
func testOperationName() throws {
    // Setup
    let testImage = try VIPSImage.black(width: 10, height: 10)
        .linear(1.0, 128.0)
    
    // Execute
    let result = try testImage.operationName(param: value)
    
    // Verify
    #expect(result.size.width == 10)
    #expect(try result.avg() > 0)
    
    // Cleanup happens automatically
}
```

## Progress Tracking

### Completed
- ✅ Basic arithmetic operations (partial)
- ✅ Basic image I/O operations
- ✅ Thumbnail generation
- ✅ Basic WebP export
- ✅ Basic AVIF export

### In Progress
- 🔄 Creating this TODO document
- 🔄 Setting up test structure

### Next Steps
1. Create test files for each generated module
2. Implement Priority 1 tests first
3. Add test data generation utilities
4. Set up CI to track test coverage

## Notes
- Total generated functions to test: 196+
- Current test coverage: < 10%
- Target test coverage: > 80%