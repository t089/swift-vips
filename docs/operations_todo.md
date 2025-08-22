# VipsOperations To-Do List

This document lists the libvips operations that still need to be implemented in the Swift wrapper. Operations are organized by category based on the libvips header files.

## Implementation Status Key
- ✅ Already implemented
- 🔄 Partially implemented (via dynamic member lookup)
- ❌ Not yet implemented
- 🎯 Priority for implementation

## Arithmetic Operations

### Already Implemented ✅
- `add`, `subtract`, `multiply`, `linear`
- `avg`, `deviate`, `max`, `min`
- `divide` - Divide two images (with `/` operator)
- `abs` - Absolute value pixel-wise
- `sign` - Sign of pixels (-1, 0, 1)
- `round` - Round pixels to nearest integer
- `floor` - Floor operation
- `ceil` - Ceiling operation
- `rint` - Round to nearest integer

### Math Operations (Single Image) 🎯
- ✅ `sin`, `cos`, `tan` - Trigonometric functions
- ✅ `asin`, `acos`, `atan` - Inverse trigonometric
- ✅ `sinh`, `cosh`, `tanh` - Hyperbolic functions
- ✅ `asinh`, `acosh`, `atanh` - Inverse hyperbolic
- ✅ `log`, `log10` - Logarithmic functions
- ✅ `exp` - Exponential function
- ✅ `exp10` - Base-10 exponential function

### Math2 Operations (Two Images/Constants) 🎯
- ✅ `pow` - Power operation (with image and constant versions)
- ✅ `wop` - Raise to power, swapped arguments
- ✅ `atan2` - Two-argument arctangent
- ✅ `remainder` - Remainder after division

### Complex Number Operations ✅
- ✅ `complex` - Combine two images as complex
- ✅ `complex2` - Perform complex operation
- ✅ `complexform` - Convert real and imaginary to complex
- ✅ `complexget` - Extract component from complex
- ✅ `conj` - Complex conjugate
- ✅ `cross_phase` - Cross phase of two complex images
- ✅ `polar` - Convert complex to polar form
- ✅ `rect` - Convert polar to rectangular form
- ✅ `real` - Extract real part
- ✅ `imag` - Extract imaginary part

### Relational Operations ✅
- `equal`, `notequal` - Equality comparison
- `less`, `lesseq` - Less than comparisons
- `more`, `moreeq` - Greater than comparisons
- Const versions: `equal_const`, `notequal_const`, `less_const`, `lesseq_const`, `more_const`, `moreeq_const`

### Boolean/Bitwise Operations ✅
- ✅ `andimage`, `orimage` - Bitwise AND, OR (with `&` and `|` operators)
- ✅ `eorimage` - Bitwise XOR (with `^` operator)
- ✅ `lshift`, `rshift` - Bit shift operations (with `<<` and `>>` operators)
- ✅ Const versions: `andimage_const`, `orimage_const`, `eorimage_const`, `lshift_const`, `rshift_const`
- ✅ Band operations: `bandand`, `bandor`, `bandeor`

### Statistical Operations ✅
- ✅ `sum` - Sum array of images
- ✅ `stats` - Calculate multiple statistics
- ✅ `measure` - Measure labeled regions
- ✅ `profile` - Extract profile from image
- ✅ `project` - Project rows/columns

## Color Space Operations

### Already Implemented ✅
- `colourspace` - General color space conversion
- `icc_import` - Import with ICC profile

### To Implement 🎯

#### Color Space Conversions
- `Lab2XYZ`, `XYZ2Lab` - Lab ↔ XYZ
- `Lab2LCh`, `LCh2Lab` - Lab ↔ LCh
- `LCh2CMC`, `CMC2LCh` - LCh ↔ CMC
- `XYZ2Yxy`, `Yxy2XYZ` - XYZ ↔ Yxy
- `scRGB2XYZ`, `XYZ2scRGB` - scRGB ↔ XYZ
- `scRGB2sRGB`, `sRGB2scRGB` - scRGB ↔ sRGB
- `HSV2sRGB`, `sRGB2HSV` - HSV ↔ sRGB
- `CMYK2XYZ`, `XYZ2CMYK` - CMYK ↔ XYZ
- `Lab2LabQ`, `LabQ2Lab` - Lab quantized conversions
- `Lab2LabS`, `LabS2Lab` - Lab short conversions
- `LabQ2sRGB` - Direct LabQ to sRGB

#### Color Operations
- `dE76`, `dE00`, `dECMC` - Color difference calculations
- `icc_export` - Export with ICC profile
- `icc_transform` - Transform between ICC profiles
- `scRGB2BW` - Convert scRGB to black and white
- `falsecolour` - Create false color visualization

## Conversion Operations

### Already Implemented ✅
- `gravity`, `replicate`, `crop`, `composite2`
- `cast`, `extract_band`, `bandjoin`, `autorot`

### To Implement 🎯

#### Geometric Transforms
- `embed` - Embed image in larger image
- `flip` - Flip horizontally/vertically
- `rot90`, `rot180`, `rot270` - Fixed rotations
- `rot45` - 45-degree rotation options
- `transpose3d` - 3D transpose
- `wrap` - Wrap image edges
- `zoom` - Integer zoom

#### Array/Band Operations
- `arrayjoin` - Join array of images
- `bandrank` - Rank filter across bands
- `bandfold`, `bandunfold` - Fold/unfold bands
- `bandmean` - Mean across bands
- `bandbool` - Boolean operation across bands
- `msb` - Most significant byte

#### Image Adjustments
- `scale` - Scale pixel values to 0-255
- `byteswap` - Swap byte order
- `falsecolour` - False color mapping
- `flatten` - Flatten alpha against background
- `premultiply`, `unpremultiply` - Alpha premultiplication
- `addalpha` - Add alpha channel
- `ifthenelse` - Conditional selection
- `switch` - Multi-way switch
- `insert` - Insert sub-image
- `join` - Join two images

#### Data Conversion
- `copy_file` - Copy with file metadata
- `tilecache` - Add tile cache
- `linecache` - Add line cache
- `sequential` - Force sequential access
- `cache` - Add operation cache
- `getpoint` - Get pixel value (needs proper Swift wrapper)
- `smartcrop` - Intelligent cropping
- `find_trim` - Find trim bounds

#### Special Conversions
- `float2rad` - Float to Radiance format
- `rad2float` - Radiance to float format
- `grid` - Arrange images in grid
- `subsample` - Subsample image

## Convolution Operations

### Already Implemented ✅
- `sharpen` - Unsharp mask sharpening

### To Implement 🎯
- `conv` - Convolution with matrix
- `conva` - Approximate convolution
- `convf` - Convolution with float mask
- `convi` - Convolution with integer mask
- `convsep` - Separable convolution
- `convasep` - Approximate separable convolution
- `gaussblur` - Gaussian blur
- `canny` - Canny edge detector
- `sobel` - Sobel edge detector
- `prewitt` - Prewitt edge detector
- `scharr` - Scharr edge detector
- `compass` - Compass edge detector
- `fastcor` - Fast correlation
- `spcor` - Spatial correlation

## Create Operations

### Already Implemented ✅
- `text` - Create text image
- `identity` - Identity LUT
- `black` - Create black image

### To Implement 🎯
- `gaussnoise` - Gaussian noise image
- `xy`, `xyz` - Create coordinate images
- `grey` - Create grey ramp
- `zone` - Create zone plate
- `sines` - Create sine wave pattern
- `eye` - Create test pattern
- `mask_ideal` - Ideal frequency mask
- `mask_butterworth` - Butterworth frequency mask
- `mask_gaussian` - Gaussian frequency mask
- Band versions: `mask_ideal_band`, `mask_butterworth_band`, etc.
- Ring versions: `mask_ideal_ring`, `mask_butterworth_ring`, etc.
- `buildlut` - Build lookup table
- `invertlut` - Invert lookup table
- `tonelut` - Build tone curve (partially implemented)
- `logmat` - Create log matrix
- `gaussmat` - Create Gaussian matrix
- `fractsurf` - Create fractal surface
- `worley` - Worley noise
- `perlin` - Perlin noise

## Draw Operations ❌

None currently implemented. All need implementation:

### To Implement 🎯
- `draw_rect` - Draw rectangle
- `draw_circle` - Draw circle
- `draw_line` - Draw line
- `draw_mask` - Draw mask image
- `draw_image` - Draw image onto image
- `draw_point` - Draw single point
- `draw_smudge` - Smudge effect
- `draw_flood` - Flood fill
- Versions with `1` suffix for single color

## Histogram Operations

### Already Implemented ✅
- `percent` - Find percentile
- `hist_local` - Local histogram equalization
- `hist_find` - Find histogram

### To Implement 🎯
- `hist_cum` - Cumulative histogram
- `hist_norm` - Normalize histogram
- `hist_equal` - Histogram equalization
- `hist_plot` - Plot histogram
- `hist_match` - Match histograms
- `hist_entropy` - Calculate entropy
- `hist_ismonotonic` - Check if monotonic
- `hist_find_indexed` - Indexed histogram
- `hist_find_ndim` - N-dimensional histogram
- `stdif` - Standard deviation filter
- `case` - Case pattern matching
- `profile_load` - Load profile

## Morphology Operations

### To Implement 🎯
- `morph` - Morphological operation
- `rank` - Rank filter
- `median` - Median filter
- `countlines` - Count lines
- `labelregions` - Label connected regions
- `fill_nearest` - Fill with nearest

## Resample Operations

### Already Implemented ✅
- `resize` - Resize with scale
- `rotate` - Arbitrary rotation
- `thumbnail_image` - Thumbnail from image
- `thumbnail_buffer` - Thumbnail from buffer

### To Implement 🎯
- `affine` - Affine transformation
- `similarity` - Similarity transformation
- `quadratic` - Quadratic transformation
- `shrink`, `shrinkh`, `shrinkv` - Integer shrink
- `reduce`, `reduceh`, `reducev` - High-quality reduce
- `mapim` - Map with index image
- `thumbnail` - General thumbnail (file-based)
- `thumbnail_source` - Thumbnail from source

## Foreign (Import/Export) Operations

### Already Implemented ✅
- JPEG load/save (via buffer/file)
- PNG load/save (via buffer)
- HEIF load/save (via buffer)
- WebP save (via buffer)
- General loader detection

### To Implement 🎯

#### High Priority Formats
- `tiffload`, `tiffsave` - TIFF format (+ buffer/source/target variants)
- `gifload`, `gifsave` - GIF format (+ variants)
- `svgload` - SVG format (+ buffer/source/string variants)
- `pdfload` - PDF format (+ buffer/source variants)

#### Additional Formats
- `jp2kload`, `jp2ksave` - JPEG 2000 (+ variants)
- `jxlload`, `jxlsave` - JPEG XL (+ variants)
- `openexrload` - OpenEXR format
- `radload`, `radsave` - Radiance format (+ variants)
- `ppmload`, `ppmsave` - PPM format (+ variants)
- `fitsload`, `fitssave` - FITS format
- `niftiload`, `niftisave` - NIfTI medical format
- `analyzeload` - Analyze medical format
- `matload` - Matlab format
- `openslideload` - OpenSlide whole-slide imaging
- `magickload`, `magicksave` - ImageMagick (+ buffer variants)
- `rawload`, `rawsave` - Raw pixel data
- `csvload`, `csvsave` - CSV format (+ source/target variants)
- `matrixload`, `matrixsave` - Matrix format (+ source/target variants)
- `vipsload`, `vipssave` - Native VIPS format (+ source/target variants)
- `dzsave` - Deep Zoom format (+ buffer/target variants)

#### Special Save Operations
- `jpegsave_mime` - JPEG with MIME type
- `webpsave_mime` - WebP with MIME type
- `matrixprint` - Print matrix to stdout
- `rawsave_fd` - Raw save to file descriptor

## Transform Operations

### To Implement ❌
- `hough_circle` - Hough circle detection
- `hough_line` - Hough line detection

## Frequency Domain Operations ❌

None currently implemented:
- `fwfft` - Forward FFT
- `invfft` - Inverse FFT
- `freqmult` - Frequency domain multiplication

## Mosaicing Operations ❌

None currently implemented. These are specialized operations for image stitching.

## Priority Recommendations

### High Priority 🎯
1. **Basic Math Operations**: divide, abs, floor, ceil, round
2. **Relational Operations**: equal, less, more and their const variants
3. **Common Filters**: gaussblur, median
4. **Essential I/O**: tiffload/save, gifload/save, svgload
5. **Geometric**: flip, embed, affine
6. **Draw Operations**: Basic drawing primitives

### Medium Priority
1. **Advanced Math**: Trigonometric and logarithmic functions
2. **Color Space**: Additional conversions beyond colourspace
3. **Morphology**: Basic morphological operations
4. **Advanced Filters**: Edge detectors (canny, sobel)
5. **Statistical**: sum, stats, measure

### Low Priority
1. ~~**Complex Operations**: Complex number handling~~ (Completed)
2. **Specialized Formats**: Medical imaging formats
3. **Frequency Domain**: FFT operations
4. **Mosaicing**: Image stitching operations

## Implementation Notes

1. Operations marked with 🔄 may be partially accessible through the dynamic member lookup system but would benefit from proper Swift wrappers with type safety.

2. Many operations have variants:
   - `_const` versions for operation with constant
   - `_buffer`, `_source`, `_target` for I/O operations
   - Band-specific versions

3. The Swift wrapper should prioritize:
   - Type safety with proper Swift types
   - Consistent error handling
   - Swift-idiomatic API design
   - Performance optimization for common operations

4. Consider implementing operation groups as Swift protocols or extensions for better organization.

5. Some operations may require additional C shim functions due to variadic argument limitations in Swift.