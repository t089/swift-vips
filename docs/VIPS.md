## Module `VIPS`

### Table of Contents

| Type | Name |
| --- | --- |
| class | `VIPSObject` |
| class | `VIPSBlob` |
| class | `VIPSImage` |
| struct | `VIPSImage.Size` |
| class | `VIPSInterpolate` |
| class | `VIPSTarget` |
| class | `VIPSTargetCustom` |
| struct | `UnownedVIPSObjectRef` |
| struct | `VIPSError` |
| struct | `VIPSImageRef` |
| struct | `VIPSObjectRef` |
| struct | `VIPSOption` |
| struct | `Whence` |
| enum | `VIPS` |
| protocol | `PointerWrapper` |
| protocol | `VIPSImageProtocol` |
| protocol | `VIPSLoggingDelegate` |
| protocol | `VIPSObjectProtocol` |
| func | `vipsFindLoader(path:)` |
| typealias | `VIPSProgress` |
| typealias | `VipsAccess` |
| typealias | `VipsBandFormat` |
| typealias | `VipsIntent` |
| typealias | `VipsInteresting` |
| typealias | `VipsInterpretation` |
| typealias | `VipsKernel` |
| typealias | `VipsOperationBoolean` |
| typealias | `VipsOperationComplex` |
| typealias | `VipsOperationComplex2` |
| typealias | `VipsOperationComplexget` |
| typealias | `VipsOperationMath` |
| typealias | `VipsOperationMath2` |
| typealias | `VipsOperationRelational` |
| typealias | `VipsOperationRound` |
| typealias | `VipsPCS` |
| typealias | `VipsPrecision` |
| typealias | `VipsSize` |
| Array extension | `Array` |
| Collection extension | `Collection` |

### Public interface

#### class VIPSObject

```swift
public class VIPSObject: PointerWrapper, VIPSObjectProtocol {
  public var ptr: UnsafeMutableRawPointer!

  public var type: GType { get }

  public required init(_ ptr: UnsafeMutableRawPointer)

  public func unref()
}
```

#### class VIPSBlob

```swift
public final class VIPSBlob: Collection, ExpressibleByArrayLiteral, Sendable, SendableMetatype, Sequence {
  /// The number of elements in the collection.
  /// 
  /// To check whether a collection is empty, use its `isEmpty` property
  /// instead of comparing `count` to zero. Unless the collection guarantees
  /// random-access performance, calculating `count` can be an O(*n*)
  /// operation.
  /// 
  /// - Complexity: O(1) if the collection conforms to
  ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
  ///   of the collection.
  public var count: Int { get }

  /// A textual representation of this instance, suitable for debugging.
  /// 
  /// Calling this property directly is discouraged. Instead, convert an
  /// instance of any type to a string by using the `String(reflecting:)`
  /// initializer. This initializer works with any type, and uses the custom
  /// `debugDescription` property for types that conform to
  /// `CustomDebugStringConvertible`:
  /// 
  ///     struct Point: CustomDebugStringConvertible {
  ///         let x: Int, y: Int
  /// 
  ///         var debugDescription: String {
  ///             return "(\(x), \(y))"
  ///         }
  ///     }
  /// 
  ///     let p = Point(x: 21, y: 30)
  ///     let s = String(reflecting: p)
  ///     print(s)
  ///     // Prints "(21, 30)"
  /// 
  /// The conversion of `p` to a string in the assignment to `s` uses the
  /// `Point` type's `debugDescription` property.
  public var debugDescription: String { get }

  /// The collection's "past the end" position---that is, the position one
  /// greater than the last valid subscript argument.
  /// 
  /// When you need a range that includes the last element of a collection, use
  /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
  /// creates a range that doesn't include the upper bound, so it's always
  /// safe to use with `endIndex`. For example:
  /// 
  ///     let numbers = [10, 20, 30, 40, 50]
  ///     if let index = numbers.firstIndex(of: 30) {
  ///         print(numbers[index ..< numbers.endIndex])
  ///     }
  ///     // Prints "[30, 40, 50]"
  /// 
  /// If the collection is empty, `endIndex` is equal to `startIndex`.
  public var endIndex: Int { get }

  /// The position of the first element in a nonempty collection.
  /// 
  /// If the collection is empty, `startIndex` is equal to `endIndex`.
  public var startIndex: Int { get }

  public func copy() -> VIPSBlob

  public func findLoader() -> String?

  /// Returns the position immediately after the given index.
  /// 
  /// The successor of an index must be well defined. For an index `i` into a
  /// collection `c`, calling `c.index(after: i)` returns the same index every
  /// time.
  /// 
  /// - Parameter i: A valid index of the collection. `i` must be less than
  ///   `endIndex`.
  /// - Returns: The index value immediately after `i`.
  public func index(after i: Int) -> Int

  /// Creates a new VIPSBlob by copying the bytes from the given collection.
  public init(_ buffer: some Collection<UInt8>)

  /// Creates an instance initialized with the given elements.
  public convenience init(arrayLiteral elements: UInt8...)

  /// Create a VIPSBlob from a buffer without copying the data.
  /// IMPORTANT: It is the responsibility of the caller to ensure that the buffer remains valid for the lifetime
  /// of the VIPSBlob or any derived images.
  public init(noCopy buffer: UnsafeRawBufferPointer)

  /// Create a VIPSBlob from a buffer without copying the data.
  /// Will call `onDealloc` when the lifetime of the blob ends.
  /// IMPORTANT: It is the responsibility of the caller to ensure that the buffer remains valid for the lifetime
  /// of the VIPSBlob or any derived images.
  public init(noCopy buffer: UnsafeRawBufferPointer, onDealloc: @escaping () -> Void)

  /// Yield the contiguous buffer of this blob.
  /// 
  /// Never returns nil, unless `body` returns nil.
  public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<UInt8>) throws -> R) rethrows -> R?

  public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R

  /// Access the raw bytes of the blob.
  /// 
  /// If you escape the pointer from the closure, you _must_ call `storageManagement.retain()` to get ownership to
  /// the bytes and you also must call `storageManagement.release()` if you no longer require those bytes. Calls to
  /// `retain` and `release` must be balanced.
  public func withUnsafeBytesAndStorageManagement<R>(_ body: (UnsafeRawBufferPointer, Unmanaged<AnyObject>) throws -> R) rethrows -> R
}
```

#### class VIPSImage

```swift
public class VIPSImage: VIPSObject, PointerWrapper, VIPSImageProtocol, VIPSObjectProtocol {
  /// A structure representing the dimensions of an image.
  public struct Size {
    /// The height of the image in pixels.
    public var height: Int

    /// The width of the image in pixels.
    public var width: Int

    /// Creates a new Size with the specified width and height.
    public init(width: Int, height: Int)
  }

  /// The number of bands (channels) in the image.
  /// 
  /// For example, RGB images have 3 bands, RGBA images have 4 bands,
  /// and grayscale images have 1 band.
  /// - Returns: The number of bands in the image
  public var bands: Int { get }

  /// The name of the file the image was loaded from.
  /// 
  /// Returns the filename that was used to load this image, or `nil`
  /// if the image was created programmatically or from memory.
  /// - Returns: The filename, or `nil` if no filename is available
  public var filename: String? { get }

  /// Whether the image has an alpha channel.
  /// 
  /// This checks if the image has transparency information. For example,
  /// RGBA images return true, while RGB images return false.
  /// - Returns: `true` if the image has an alpha channel, `false` otherwise
  public var hasAlpha: Bool { get }

  /// Whether the image has an embedded ICC color profile.
  /// 
  /// ICC profiles contain information about the color characteristics
  /// of the image and are used for accurate color reproduction.
  /// - Returns: `true` if the image has an ICC profile, `false` otherwise
  public var hasProfile: Bool { get }

  /// The number of pixels down the image.
  /// - Returns: The image height in pixels
  public var height: Int { get }

  /// The processing history of the image.
  /// 
  /// VIPS maintains a log of operations that have been performed on an image.
  /// This can be useful for debugging or understanding how an image was created.
  /// - Returns: The history string, or `nil` if no history is available
  public var history: String? { get }

  /// The image mode as a string.
  /// 
  /// This is an optional string field that can be used to store additional
  /// information about how the image should be interpreted or processed.
  /// - Returns: The mode string, or `nil` if no mode is set
  public var mode: String? { get }

  /// The number of pages in the image file.
  /// 
  /// This is the number of pages in the original image file, not necessarily
  /// the number of pages that have been loaded into this image object.
  /// For single-page images, this returns 1.
  /// - Returns: The number of pages in the image file
  public var nPages: Int { get }

  /// The number of sub-image file directories.
  /// 
  /// Some image formats (particularly TIFF) can contain multiple sub-images
  /// or sub-directories. This returns the count of such structures.
  /// Returns 0 if not present or not applicable to the format.
  /// - Returns: The number of sub-IFDs in the image file
  public var nSubifds: Int { get }

  /// The offset value for matrix images.
  /// 
  /// Matrix images can have an optional offset field for use by integer
  /// convolution operations. The offset is added after convolution
  /// and scaling.
  /// - Returns: The offset value, typically 0.0 for non-matrix images
  public var offset: Double { get }

  /// The EXIF orientation value for the image.
  /// 
  /// Returns the orientation value from EXIF metadata, if present.
  /// Values range from 1-8 according to the EXIF specification.
  /// - Returns: The EXIF orientation value, or 1 if no orientation is set
  public var orientation: Int { get }

  /// Whether applying the orientation would swap width and height.
  /// 
  /// Some EXIF orientations require rotating the image by 90 or 270 degrees,
  /// which would swap the width and height dimensions. This property
  /// indicates if such a swap would occur.
  /// - Returns: `true` if width and height would swap when applying orientation
  public var orientationSwap: Bool { get }

  /// The height of each page in multi-page images.
  /// 
  /// Multi-page images (such as animated GIFs or multi-page TIFFs) can have
  /// a page height different from the total image height. If page-height is
  /// not set, it defaults to the image height.
  /// - Returns: The height of each page in pixels
  public var pageHeight: Int { get }

  /// The scale factor for matrix images.
  /// 
  /// Matrix images can have an optional scale field for use by integer
  /// convolution operations. The scale is applied after convolution
  /// to normalize the result.
  /// - Returns: The scale factor, typically 1.0 for non-matrix images
  public var scale: Double { get }

  /// The size of the image as a Size struct containing width and height.
  /// - Returns: A Size struct with the image dimensions in pixels
  public var size: Size { get }

  /// The interpretation of the image as a human-readable string.
  /// 
  /// This returns the string representation of the image's interpretation,
  /// such as "srgb", "rgb", "cmyk", "lab", etc.
  /// - Returns: A string describing the image interpretation
  public var space: String { get }

  /// The number of pixels across the image.
  /// - Returns: The image width in pixels
  public var width: Int { get }

  /// The horizontal position of the image origin, in pixels.
  /// 
  /// This is a hint about where this image should be positioned relative
  /// to some larger canvas. It's often used in image tiling operations.
  /// - Returns: The horizontal offset in pixels
  public var xoffset: Int { get }

  /// The horizontal image resolution in pixels per millimeter.
  /// 
  /// This represents the physical resolution of the image when printed
  /// or displayed. A value of 1.0 means 1 pixel per millimeter.
  /// - Returns: The horizontal resolution in pixels per millimeter
  public var xres: Double { get }

  /// The vertical position of the image origin, in pixels.
  /// 
  /// This is a hint about where this image should be positioned relative
  /// to some larger canvas. It's often used in image tiling operations.
  /// - Returns: The vertical offset in pixels
  public var yoffset: Int { get }

  /// The vertical image resolution in pixels per millimeter.
  /// 
  /// This represents the physical resolution of the image when printed
  /// or displayed. A value of 1.0 means 1 pixel per millimeter.
  /// - Returns: The vertical resolution in pixels per millimeter
  public var yres: Double { get }

  /// Bandwise join a set of images
  /// 
  public static func bandjoin(_ in: [VIPSImage]) throws -> VIPSImage

  /// Band-wise rank of a set of images
  /// 
  public static func bandrank(_ in: [VIPSImage], index: Int? = nil) throws -> VIPSImage

  /// Make a black image
  /// 
  public static func black(width: Int, height: Int, bands: Int? = nil) throws -> VIPSImage

  /// Make an image showing the eye's spatial response
  /// 
  public static func eye(width: Int, height: Int, uchar: Bool? = nil, factor: Double? = nil) throws -> VIPSImage

  /// Make a fractal surface
  /// 
  public static func fractsurf(width: Int, height: Int, fractalDimension: Double) throws -> VIPSImage

  /// Make a gaussnoise image
  /// 
  public static func gaussnoise(width: Int, height: Int, sigma: Double? = nil, mean: Double? = nil, seed: Int? = nil) throws -> VIPSImage

  /// Make a grey ramp image
  /// 
  public static func grey(width: Int, height: Int, uchar: Bool? = nil) throws -> VIPSImage

  /// Make a 1d image where pixel values are indexes
  /// 
  public static func identity(bands: Int? = nil, ushort: Bool? = nil, size: Int? = nil) throws -> VIPSImage

  /// Make a butterworth filter
  /// 
  public static func maskButterworth(width: Int, height: Int, order: Double, frequencyCutoff: Double, amplitudeCutoff: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make a butterworth_band filter
  /// 
  public static func maskButterworthBand(width: Int, height: Int, order: Double, frequencyCutoffX: Double, frequencyCutoffY: Double, radius: Double, amplitudeCutoff: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make a butterworth ring filter
  /// 
  public static func maskButterworthRing(width: Int, height: Int, order: Double, frequencyCutoff: Double, amplitudeCutoff: Double, ringwidth: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make fractal filter
  /// 
  public static func maskFractal(width: Int, height: Int, fractalDimension: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make a gaussian filter
  /// 
  public static func maskGaussian(width: Int, height: Int, frequencyCutoff: Double, amplitudeCutoff: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make a gaussian filter
  /// 
  public static func maskGaussianBand(width: Int, height: Int, frequencyCutoffX: Double, frequencyCutoffY: Double, radius: Double, amplitudeCutoff: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make a gaussian ring filter
  /// 
  public static func maskGaussianRing(width: Int, height: Int, frequencyCutoff: Double, amplitudeCutoff: Double, ringwidth: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make an ideal filter
  /// 
  public static func maskIdeal(width: Int, height: Int, frequencyCutoff: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make an ideal band filter
  /// 
  public static func maskIdealBand(width: Int, height: Int, frequencyCutoffX: Double, frequencyCutoffY: Double, radius: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Make an ideal ring filter
  /// 
  public static func maskIdealRing(width: Int, height: Int, frequencyCutoff: Double, ringwidth: Double, uchar: Bool? = nil, nodc: Bool? = nil, reject: Bool? = nil, optical: Bool? = nil) throws -> VIPSImage

  /// Create an empty matrix image
  public static func matrix(width: Int, height: Int) throws -> VIPSImage

  /// Create a matrix image from a double array
  public static func matrix(width: Int, height: Int, data: [Double]) throws -> VIPSImage

  /// Make a perlin noise image
  /// 
  public static func perlin(width: Int, height: Int, cellSize: Int? = nil, uchar: Bool? = nil, seed: Int? = nil) throws -> VIPSImage

  /// Load named icc profile
  /// 
  public static func profileLoad(name: String) throws -> VIPSBlob

  /// Make a 2d sine wave
  /// 
  public static func sines(width: Int, height: Int, uchar: Bool? = nil, hfreq: Double? = nil, vfreq: Double? = nil) throws -> VIPSImage

  /// Sum an array of images
  /// 
  public static func sum(_ in: [VIPSImage]) throws -> VIPSImage

  /// Find the index of the first non-zero pixel in tests
  /// 
  public static func `switch`(tests: [VIPSImage]) throws -> VIPSImage

  /// Build a look-up table
  /// 
  public static func tonelut(inMax: Int? = nil, outMax: Int? = nil, Lb: Double? = nil, Lw: Double? = nil, Ps: Double? = nil, Pm: Double? = nil, Ph: Double? = nil, S: Double? = nil, M: Double? = nil, H: Double? = nil) throws -> VIPSImage

  /// Make a worley noise image
  /// 
  public static func worley(width: Int, height: Int, cellSize: Int? = nil, seed: Int? = nil) throws -> VIPSImage

  /// Make an image where pixel values are coordinates
  /// 
  public static func xyz(width: Int, height: Int, csize: Int? = nil, dsize: Int? = nil, esize: Int? = nil) throws -> VIPSImage

  /// Make a zone plate
  /// 
  public static func zone(width: Int, height: Int, uchar: Bool? = nil) throws -> VIPSImage

  /// Transform lch to cmc
  public func CMC2LCh() throws -> VIPSImage

  /// Transform cmyk to xyz
  public func CMYK2XYZ() throws -> VIPSImage

  /// Transform hsv to srgb
  public func HSV2sRGB() throws -> VIPSImage

  /// Transform lch to cmc
  public func LCh2CMC() throws -> VIPSImage

  /// Transform lch to lab
  public func LCh2Lab() throws -> VIPSImage

  /// Transform lab to lch
  public func Lab2LCh() throws -> VIPSImage

  /// Transform float lab to labq coding
  public func Lab2LabQ() throws -> VIPSImage

  /// Transform float lab to signed short
  public func Lab2LabS() throws -> VIPSImage

  /// Transform cielab to xyz
  /// 
  public func Lab2XYZ(temp: [Double]? = nil) throws -> VIPSImage

  /// Unpack a labq image to float lab
  public func LabQ2Lab() throws -> VIPSImage

  /// Unpack a labq image to short lab
  public func LabQ2LabS() throws -> VIPSImage

  /// Convert a labq image to srgb
  public func LabQ2sRGB() throws -> VIPSImage

  /// Transform signed short lab to float
  public func LabS2Lab() throws -> VIPSImage

  /// Transform short lab to labq coding
  public func LabS2LabQ() throws -> VIPSImage

  /// Transform xyz to cmyk
  public func XYZ2CMYK() throws -> VIPSImage

  /// Transform xyz to lab
  /// 
  public func XYZ2Lab(temp: [Double]? = nil) throws -> VIPSImage

  /// Transform xyz to yxy
  public func XYZ2Yxy() throws -> VIPSImage

  /// Transform xyz to scrgb
  public func XYZ2scRGB() throws -> VIPSImage

  /// Transform yxy to xyz
  public func Yxy2XYZ() throws -> VIPSImage

  /// Absolute value of an image
  public func abs() throws -> VIPSImage

  /// Calculate arccosine of image values (result in degrees)
  public func acos() throws -> VIPSImage

  /// Calculate inverse hyperbolic cosine of image values
  public func acosh() throws -> VIPSImage

  /// Add two images
  /// 
  public func add(_ rhs: VIPSImage) throws -> VIPSImage

  /// Bitwise AND of two images
  /// 
  public func andimage(_ rhs: VIPSImage) throws -> VIPSImage

  /// Calculate arcsine of image values (result in degrees)
  public func asin() throws -> VIPSImage

  /// Calculate inverse hyperbolic sine of image values
  public func asinh() throws -> VIPSImage

  /// Calculate arctangent of image values (result in degrees)
  public func atan() throws -> VIPSImage

  /// Calculate two-argument arctangent of y/x in degrees
  public func atan2(_ x: VIPSImage) throws -> VIPSImage

  /// Calculate inverse hyperbolic tangent of image values
  public func atanh() throws -> VIPSImage

  /// Autorotate image by exif tag
  public func autorot() throws -> VIPSImage

  /// Same as `autorot()`
  /// 
  /// See: `VIPSImage.autorot()`
  public func autorotate() throws -> VIPSImage

  /// Find image average
  public func avg() throws -> Double

  /// Perform bitwise AND operation across bands.
  /// 
  /// Reduces multiple bands to a single band by performing bitwise AND
  /// on corresponding pixels across all bands.
  /// 
  /// - Returns: A new single-band image
  /// - Throws: `VIPSError` if the operation fails
  public func bandand() throws -> VIPSImage

  /// Perform bitwise XOR (exclusive OR) operation across bands.
  /// 
  /// Reduces multiple bands to a single band by performing bitwise XOR
  /// on corresponding pixels across all bands.
  /// 
  /// - Returns: A new single-band image
  /// - Throws: `VIPSError` if the operation fails
  public func bandeor() throws -> VIPSImage

  /// Fold up x axis into bands
  /// 
  public func bandfold(factor: Int? = nil) throws -> VIPSImage

  /// Append a constant band to an image
  /// 
  public func bandjoinConst(c: [Double]) throws -> VIPSImage

  /// Band-wise average
  public func bandmean() throws -> VIPSImage

  /// Perform bitwise OR operation across bands.
  /// 
  /// Reduces multiple bands to a single band by performing bitwise OR
  /// on corresponding pixels across all bands.
  /// 
  /// - Returns: A new single-band image
  /// - Throws: `VIPSError` if the operation fails
  public func bandor() throws -> VIPSImage

  /// Unfold image bands into x axis
  /// 
  public func bandunfold(factor: Int? = nil) throws -> VIPSImage

  /// Build a look-up table
  public func buildlut() throws -> VIPSImage

  /// Byteswap an image
  public func byteswap() throws -> VIPSImage

  /// Use pixel values to pick cases from an array of images
  /// 
  public func `case`(cases: [VIPSImage]) throws -> VIPSImage

  public func ceil() throws -> VIPSImage

  /// Clamp values of an image
  /// 
  public func clamp(min: Double? = nil, max: Double? = nil) throws -> VIPSImage

  /// Create a complex image from real and imaginary parts
  public func complex(_ imaginary: VIPSImage) throws -> VIPSImage

  /// Form a complex image from two real images
  /// 
  public func complexform(_ rhs: VIPSImage) throws -> VIPSImage

  /// Get the concurrency hint for this image.
  /// 
  /// This returns the suggested level of parallelism for operations on this
  /// image. It can be used to optimize performance by limiting the number
  /// of threads used for processing.
  /// 
  /// - Parameter defaultConcurrency: The default value to return if no hint is set
  /// - Returns: The suggested concurrency level
  public func concurrency(default defaultConcurrency: Int = 1) -> Int

  /// Calculate complex conjugate
  public func conj() throws -> VIPSImage

  /// Approximate integer convolution
  /// 
  public func conva(mask: VIPSImage, layers: Int? = nil, cluster: Int? = nil) throws -> VIPSImage

  /// Approximate separable integer convolution
  /// 
  public func convasep(mask: VIPSImage, layers: Int? = nil) throws -> VIPSImage

  /// Float convolution operation
  /// 
  public func convf(mask: VIPSImage) throws -> VIPSImage

  /// Int convolution operation
  /// 
  public func convi(mask: VIPSImage) throws -> VIPSImage

  /// This function allocates memory, renders image into it, builds a new image
  /// around the memory area, and returns that.
  /// 
  /// If the image is already a simple area of memory, it just refs image and
  /// returns it.
  public func copyMemory() throws -> VIPSImage

  /// Calculate cosine of image values (in degrees)
  public func cos() throws -> VIPSImage

  /// Calculate hyperbolic cosine of image values
  public func cosh() throws -> VIPSImage

  /// Extract an area from an image
  /// 
  public func crop(left: Int, top: Int, width: Int, height: Int) throws -> VIPSImage

  /// Calculate de00
  /// 
  public func dE00(_ rhs: VIPSImage) throws -> VIPSImage

  /// Calculate de76
  /// 
  public func dE76(_ rhs: VIPSImage) throws -> VIPSImage

  /// Calculate decmc
  /// 
  public func dECMC(_ rhs: VIPSImage) throws -> VIPSImage

  /// Find image standard deviation
  public func deviate() throws -> Double

  /// Divide two images
  /// 
  public func divide(_ rhs: VIPSImage) throws -> VIPSImage

  /// Bitwise XOR of two images
  /// 
  public func eorimage(_ rhs: VIPSImage) throws -> VIPSImage

  /// Test for equality
  /// 
  public func equal(_ value: Double) throws -> VIPSImage

  /// Calculate e^x for each pixel
  public func exp() throws -> VIPSImage

  /// Calculate 10^x for each pixel
  public func exp10() throws -> VIPSImage

  /// Extract an area from an image
  /// 
  public func extractArea(left: Int, top: Int, width: Int, height: Int) throws -> VIPSImage

  /// Extract band from an image
  /// 
  public func extractBand(_ band: Int, n: Int? = nil) throws -> VIPSImage

  /// False-color an image
  public func falsecolour() throws -> VIPSImage

  /// Fast correlation
  /// 
  public func fastcor(ref: VIPSImage) throws -> VIPSImage

  /// Fill image zeros with nearest non-zero pixel
  public func fillNearest() throws -> VIPSImage

  /// Search an image for non-edge areas
  /// 
  public func findTrim(threshold: Double? = nil, background: [Double]? = nil, lineArt: Bool? = nil) throws -> Int

  /// Flatten alpha out of an image
  /// 
  public func flatten(background: [Double]? = nil, maxAlpha: Double? = nil) throws -> VIPSImage

  /// Transform float rgb to radiance coding
  public func float2rad() throws -> VIPSImage

  public func floor() throws -> VIPSImage

  /// Frequency-domain filtering
  /// 
  public func freqmult(mask: VIPSImage) throws -> VIPSImage

  /// Forward fft
  public func fwfft() throws -> VIPSImage

  /// Gamma an image
  /// 
  public func gamma(exponent: Double? = nil) throws -> VIPSImage

  /// Get the value of the pixel at the specified coordinates.
  /// 
  /// This is a convenience method that calls the main `getpoint` implementation.
  /// The pixel value is returned as an array of doubles, with one element
  /// per band in the image.
  /// 
  public func getpoint(_ x: Int, _ y: Int) throws -> [Double]

  /// Read a point from an image
  /// 
  public func getpoint(x: Int, y: Int, unpackComplex: Bool? = nil) throws -> [Double]

  /// Global balance an image mosaic
  /// 
  public func globalbalance(gamma: Double? = nil, intOutput: Bool? = nil) throws -> VIPSImage

  /// Grid an image
  /// 
  public func grid(tileHeight: Int, across: Int, down: Int) throws -> VIPSImage

  /// Form cumulative histogram
  public func histCum() throws -> VIPSImage

  /// Estimate image entropy
  public func histEntropy() throws -> Double

  /// Histogram equalisation
  /// 
  public func histEqual(band: Int? = nil) throws -> VIPSImage

  /// Find image histogram
  /// 
  public func histFind(band: Int? = nil) throws -> VIPSImage

  /// Find n-dimensional image histogram
  /// 
  public func histFindNdim(bins: Int? = nil) throws -> VIPSImage

  /// Test for monotonicity
  public func histIsmonotonic() throws -> Bool

  /// Local histogram equalisation
  /// 
  public func histLocal(width: Int, height: Int, maxSlope: Int? = nil) throws -> VIPSImage

  /// Match two histograms
  /// 
  public func histMatch(ref: VIPSImage) throws -> VIPSImage

  /// Normalise histogram
  public func histNorm() throws -> VIPSImage

  /// Plot histogram
  public func histPlot() throws -> VIPSImage

  /// Find hough circle transform
  /// 
  public func houghCircle(scale: Int? = nil, minRadius: Int? = nil, maxRadius: Int? = nil) throws -> VIPSImage

  /// Find hough line transform
  /// 
  public func houghLine(width: Int? = nil, height: Int? = nil) throws -> VIPSImage

  /// Ifthenelse an image
  /// 
  public func ifthenelse(in1: VIPSImage, in2: VIPSImage, blend: Bool? = nil) throws -> VIPSImage

  /// Extract imaginary part of complex image
  public func imag() throws -> VIPSImage

  public required init(_ ptr: UnsafeMutableRawPointer)

  /// Creates a new image by loading the given data
  /// 
  /// The image will reference the data from the blob.
  /// 
  public convenience init(blob: VIPSBlob, loader: String? = nil, options: String? = nil) throws

  /// Creates a new image by loading the given data.
  /// 
  /// The image will NOT copy the data into its own memory.
  /// You need to ensure that the data remains valid for the lifetime of the image and all its descendants.
  /// 
  public convenience init(bufferNoCopy data: UnsafeRawBufferPointer, loader: String? = nil, options: String? = nil) throws

  /// Creates a new image by loading the given data
  /// 
  /// The image will copy the data into its own memory.
  /// 
  public convenience init(data: some Collection<UInt8>, loader: String? = nil, options: String? = nil) throws

  /// Creates a VIPSImage from 64-bit floating point data with memory copy.
  /// 
  /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
  /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
  /// 
  public init(data: some Collection<Double>, width: Int, height: Int, bands: Int) throws

  /// Creates a new image by loading the given data
  /// 
  /// The image will NOT copy the data into its own memory. You must
  /// ensure that the data remain valid for the lifetime of the image
  /// and all its descendants.
  /// 
  public convenience init(unsafeData: UnsafeRawBufferPointer, loader: String? = nil, options: String? = nil) throws

  /// Creates a VIPSImage from a memory area containing 64-bit floating point data.
  /// 
  /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
  /// for example RGBRGBRGB, left-to-right, top-to-bottom.
  /// 
  /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
  /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
  /// its descendants. Use the copy variant if you are unsure about memory management.
  /// 
  public init(unsafeData buffer: UnsafeBufferPointer<Double>, width: Int, height: Int, bands: Int) throws

  /// Insert image @sub into @main at @x, @y
  /// 
  public func insert(sub: VIPSImage, x: Int, y: Int, expand: Bool? = nil, background: [Double]? = nil) throws -> VIPSImage

  /// Invert an image
  public func invert() throws -> VIPSImage

  /// Build an inverted look-up table
  /// 
  public func invertlut(size: Int? = nil) throws -> VIPSImage

  /// Inverse fft
  /// 
  public func invfft(real: Bool? = nil) throws -> VIPSImage

  /// Label regions in an image
  public func labelregions() throws -> VIPSImage

  /// Test for less than
  /// 
  public func less(_ value: Double) throws -> VIPSImage

  /// Test for less than or equal
  /// 
  public func lesseq(_ value: Double) throws -> VIPSImage

  public func linear(_ a: [Double], _ b: [Double], uchar: Bool? = nil) throws -> VIPSImage

  /// Calculate natural logarithm (ln) of each pixel
  public func log() throws -> VIPSImage

  /// Calculate base-10 logarithm of each pixel
  public func log10() throws -> VIPSImage

  /// Left shift
  /// 
  public func lshift(_ amount: Int) throws -> VIPSImage

  /// Map an image though a lut
  /// 
  public func maplut(lut: VIPSImage, band: Int? = nil) throws -> VIPSImage

  /// First-order match of two images
  /// 
  public func match(sec: VIPSImage, xr1: Int, yr1: Int, xs1: Int, ys1: Int, xr2: Int, yr2: Int, xs2: Int, ys2: Int, hwindow: Int? = nil, harea: Int? = nil, search: Bool? = nil, interpolate: VIPSInterpolate? = nil) throws -> VIPSImage

  /// Invert an matrix
  public func matrixinvert() throws -> VIPSImage

  /// Find image maximum
  /// 
  public func max(size: Int? = nil) throws -> Double

  /// Maximum of a pair of images
  /// 
  public func maxpair(_ rhs: VIPSImage) throws -> VIPSImage

  /// Measure a set of patches on a color chart
  /// 
  public func measure(h: Int, v: Int, left: Int? = nil, top: Int? = nil, width: Int? = nil, height: Int? = nil) throws -> VIPSImage

  /// Find image minimum
  /// 
  public func min(size: Int? = nil) throws -> Double

  /// Minimum of a pair of images
  /// 
  public func minpair(_ rhs: VIPSImage) throws -> VIPSImage

  /// Test for greater than
  /// 
  public func more(_ value: Double) throws -> VIPSImage

  /// Test for greater than or equal
  /// 
  public func moreeq(_ value: Double) throws -> VIPSImage

  /// Pick most-significant byte from an image
  /// 
  public func msb(band: Int? = nil) throws -> VIPSImage

  /// Multiply two images
  /// 
  public func multiply(_ rhs: VIPSImage) throws -> VIPSImage

  public func new(_ colors: [Double]) throws -> VIPSImage

  /// Test for inequality
  /// 
  public func notequal(_ value: Double) throws -> VIPSImage

  /// Bitwise OR of two images
  /// 
  public func orimage(_ rhs: VIPSImage) throws -> VIPSImage

  /// Find threshold for percent of pixels
  /// 
  public func percent(_ percent: Double) throws -> Int

  /// Calculate phase correlation
  /// 
  public func phasecor(in2: VIPSImage) throws -> VIPSImage

  /// Convert complex image to polar form
  public func polar() throws -> VIPSImage

  /// Raise image values to a constant power (integer overload)
  public func pow(_ exponent: Int) throws -> VIPSImage

  /// Prewitt edge detector
  public func prewitt() throws -> VIPSImage

  /// Extract profiles from an image.
  /// 
  /// Creates 1D profiles by averaging across rows and columns.
  /// Returns two images: column profile (vertical average) and row profile (horizontal average).
  /// 
  /// - Returns: A tuple containing (columns profile, rows profile)
  /// - Throws: `VIPSError` if the operation fails
  public func profile() throws -> (columns: VIPSImage, rows: VIPSImage)

  /// Project rows and columns to get sums.
  /// 
  /// Returns two 1D images containing the sum of each row and column.
  /// Useful for creating projections and histograms.
  /// 
  /// - Returns: A tuple containing (row sums, column sums)
  /// - Throws: `VIPSError` if the operation fails
  public func project() throws -> (rows: VIPSImage, columns: VIPSImage)

  /// Resample an image with a quadratic transform
  /// 
  public func quadratic(coeff: VIPSImage, interpolate: VIPSInterpolate? = nil) throws -> VIPSImage

  /// Unpack radiance coding to float rgb
  public func rad2float() throws -> VIPSImage

  /// Rank filter
  /// 
  public func rank(width: Int, height: Int, index: Int) throws -> VIPSImage

  /// Extract real part of complex image
  public func real() throws -> VIPSImage

  /// Linear recombination with matrix
  /// 
  public func recomb(m: VIPSImage) throws -> VIPSImage

  /// Convert polar image to rectangular form
  public func rect() throws -> VIPSImage

  /// Remainder after integer division of an image and a constant
  /// 
  public func remainder(_ value: Int) throws -> VIPSImage

  /// Remainder after integer division of an image and a constant
  /// 
  public func remainderConst(c: [Double]) throws -> VIPSImage

  /// Replicate an image
  /// 
  public func replicate(across: Int, down: Int) throws -> VIPSImage

  /// Rotate an image by a number of degrees
  /// 
  public func rotate(angle: Double, interpolate: VIPSInterpolate? = nil, background: [Double]? = nil, odx: Double? = nil, ody: Double? = nil, idx: Double? = nil, idy: Double? = nil) throws -> VIPSImage

  public func round() throws -> VIPSImage

  /// Right shift
  /// 
  public func rshift(_ amount: Int) throws -> VIPSImage

  /// Transform srgb to hsv
  public func sRGB2HSV() throws -> VIPSImage

  /// Convert an srgb image to scrgb
  public func sRGB2scRGB() throws -> VIPSImage

  /// Convert scrgb to bw
  /// 
  public func scRGB2BW(depth: Int? = nil) throws -> VIPSImage

  /// Transform scrgb to xyz
  public func scRGB2XYZ() throws -> VIPSImage

  /// Convert an scrgb image to srgb
  /// 
  public func scRGB2sRGB(depth: Int? = nil) throws -> VIPSImage

  /// Scale an image to uchar
  /// 
  public func scale(exp: Double? = nil, log: Bool? = nil) throws -> VIPSImage

  /// Scharr edge detector
  public func scharr() throws -> VIPSImage

  /// Check sequential access
  /// 
  public func sequential(tileHeight: Int? = nil) throws -> VIPSImage

  /// Unsharp masking for print
  /// 
  public func sharpen(sigma: Double? = nil, x1: Double? = nil, y2: Double? = nil, y3: Double? = nil, m1: Double? = nil, m2: Double? = nil) throws -> VIPSImage

  /// Shrink an image
  /// 
  public func shrink(hshrink: Double, vshrink: Double, ceil: Bool? = nil) throws -> VIPSImage

  /// Shrink an image horizontally
  /// 
  public func shrinkh(hshrink: Int, ceil: Bool? = nil) throws -> VIPSImage

  /// Shrink an image vertically
  /// 
  public func shrinkv(vshrink: Int, ceil: Bool? = nil) throws -> VIPSImage

  /// Unit vector of pixel
  public func sign() throws -> VIPSImage

  /// Similarity transform of an image
  /// 
  public func similarity(scale: Double? = nil, angle: Double? = nil, interpolate: VIPSInterpolate? = nil, background: [Double]? = nil, odx: Double? = nil, ody: Double? = nil, idx: Double? = nil, idy: Double? = nil) throws -> VIPSImage

  /// Calculate sine of image values (in degrees)
  public func sin() throws -> VIPSImage

  /// Calculate hyperbolic sine of image values
  public func sinh() throws -> VIPSImage

  /// Sobel edge detector
  public func sobel() throws -> VIPSImage

  /// Spatial correlation
  /// 
  public func spcor(ref: VIPSImage) throws -> VIPSImage

  /// Make displayable power spectrum
  public func spectrum() throws -> VIPSImage

  /// Find many image stats
  public func stats() throws -> VIPSImage

  /// Statistical difference
  /// 
  public func stdif(width: Int, height: Int, s0: Double? = nil, b: Double? = nil, m0: Double? = nil, a: Double? = nil) throws -> VIPSImage

  /// Subsample an image
  /// 
  public func subsample(xfac: Int, yfac: Int, point: Bool? = nil) throws -> VIPSImage

  /// Subtract two images
  /// 
  public func subtract(_ rhs: VIPSImage) throws -> VIPSImage

  /// Calculate tangent of image values (in degrees)
  public func tan() throws -> VIPSImage

  /// Calculate hyperbolic tangent of image values
  public func tanh() throws -> VIPSImage

  /// Transpose3d an image
  /// 
  public func transpose3d(pageHeight: Int? = nil) throws -> VIPSImage

  /// Raise a constant to the power of this image (integer overload)
  public func wop(_ base: Int) throws -> VIPSImage

  /// Wrap image origin
  /// 
  public func wrap(x: Int? = nil, y: Int? = nil) throws -> VIPSImage

  /// Writes the image to a memory buffer in the specified format.
  /// 
  /// This method writes the image to a memory buffer using a format determined by the suffix.
  /// Save options may be appended to the suffix as `[name=value,...]` or given in the params
  /// dictionary. Options given in the function call override options given in the filename.
  /// 
  /// Currently TIFF, JPEG, PNG and other formats are supported depending on your libvips build.
  /// You can call the various save operations directly if you wish, see `jpegsave(buffer:)` for example.
  /// 
  public func writeToBuffer(suffix: String, quality: Int? = nil, options params: [String : Any] = [:], additionalOptions: String? = nil) throws -> VIPSBlob

  /// Writes the image to a file.
  /// 
  /// This method writes the image to a file using the saver recommended by the filename extension.
  /// Save options may be appended to the filename as `[name=value,...]` or given in the options
  /// dictionary. Options given in the function call override options given in the filename.
  /// 
  public func writeToFile(_ path: String, quality: Int? = nil, options: [String : Any] = [:], additionalOptions: String? = nil) throws

  /// Writes the image to a target in the specified format.
  /// 
  /// This method writes the image to a target using a format determined by the suffix.
  /// Save options may be appended to the suffix as `[name=value,...]` or given in the params
  /// dictionary. Options given in the function call override options given in the filename.
  /// 
  /// You can call the various save operations directly if you wish, see `jpegsave(target:)` for example.
  /// 
  public func writeToTarget(suffix: String, target: VIPSTarget, quality: Int? = nil, options params: [String : Any] = [:], additionalOptions: String? = nil) throws

  /// Zoom an image
  /// 
  public func zoom(xfac: Int, yfac: Int) throws -> VIPSImage
}
```

#### class VIPSInterpolate

```swift
public class VIPSInterpolate: VIPSObject, PointerWrapper, VIPSObjectProtocol {
  public var bilinear: VIPSInterpolate { get }

  public var nearest: VIPSInterpolate { get }

  public init(_ name: String) throws
}
```

#### class VIPSTarget

```swift
/// A VIPSTarget represents a data destination for saving images in libvips.
/// 
/// Targets can write to various destinations including files, memory buffers,
/// file descriptors, and custom writers. Targets support both seekable
/// operations (for files and memory) and streaming operations (for pipes and
/// network connections).
/// 
/// # Target Types
/// 
/// Different target types have different capabilities:
/// - **File targets**: Support seeking and random access for formats that require it (like TIFF)
/// - **Memory targets**: Store output in memory, accessible via steal() methods
/// - **Pipe targets**: Support only sequential writing, suitable for streaming
/// - **Custom targets**: Behavior depends on the custom implementation
/// 
/// # Usage Patterns
/// 
/// ```swift
/// // Save to file
/// let target = try VIPSTarget(toFile: "/path/to/output.jpg")
/// try image.write(to: target)
/// 
/// // Save to memory
/// let target = try VIPSTarget(toMemory: ())
/// try image.write(to: target)
/// let data = try target.steal()
/// 
/// // Custom target with callback
/// let customTarget = VIPSTargetCustom()
/// customTarget.onWrite { bytes in
///     // Process the written bytes
///     return bytes.count  // Return bytes processed
/// }
/// ```
/// 
/// # Thread Safety
/// 
/// VIPSTarget instances are not thread-safe. Each target should be used
/// from a single thread, or access should be synchronized externally.
public class VIPSTarget: VIPSObject, PointerWrapper, VIPSObjectProtocol {
  /// Returns true if the target has been ended.
  /// 
  /// Once a target is ended, no further write operations should be performed.
  /// This is set to true after calling end().
  public var isEnded: Bool { get }

  /// Returns true if this is a memory target.
  /// 
  /// Memory targets accumulate written data in an internal buffer
  /// that can be retrieved with steal() methods.
  public var isMemory: Bool { get }

  /// Creates a target that writes to memory.
  /// 
  /// Data written to this target is accumulated in an internal buffer.
  /// Use steal() or stealText() to retrieve the accumulated data.
  /// 
  /// - Throws: VIPSError if the target cannot be created
  public static func toMemory() throws -> VIPSTarget

  /// Ends the target and flushes all remaining data.
  /// 
  /// This finalizes the target, ensuring all buffered data is written
  /// and any cleanup is performed. After calling this method, no further
  /// write operations should be performed on this target.
  /// 
  /// Note: This replaces the deprecated finish() method.
  /// 
  /// - Throws: VIPSError if the end operation fails
  public func end() throws

  public required init(_ ptr: UnsafeMutableRawPointer)

  /// Creates a temporary target based on another target.
  /// 
  /// This creates a temporary target that can be used for intermediate
  /// operations before writing to the final target.
  /// 
  /// - Parameter basedOn: The target to base the temporary target on
  /// - Throws: VIPSError if the target cannot be created
  public init(temp basedOn: VIPSTarget) throws

  /// Creates a target from a file descriptor.
  /// 
  /// The file descriptor is not closed when the target is destroyed.
  /// The caller is responsible for managing the file descriptor's lifecycle.
  /// 
  /// - Parameter descriptor: An open file descriptor to write to
  /// - Throws: VIPSError if the target cannot be created
  public init(toDescriptor descriptor: Int32) throws

  /// Creates a target that will write to the named file.
  /// 
  /// The file is created immediately. If the file already exists, it will be
  /// truncated. The directory containing the file must exist.
  /// 
  /// - Parameter path: Path to the file to write to
  /// - Throws: VIPSError if the target cannot be created
  public init(toFile path: String) throws

  /// Writes a single character to the target.
  /// 
  /// - Parameter character: The character to write (as an ASCII value)
  /// - Throws: VIPSError if the write operation fails
  public func putc(_ character: Int) throws

  public func read(into span: inout OutputRawSpan) throws

  /// Changes the current position within the target.
  /// 
  /// This operation is only supported on seekable targets (like files).
  /// Some formats (like TIFF) require the ability to seek within the target.
  /// 
  /// The whence parameter determines how the offset is interpreted:
  /// - SEEK_SET (0): Absolute position from start
  /// - SEEK_CUR (1): Relative to current position
  /// - SEEK_END (2): Relative to end of target
  /// 
  public @discardableResult func seek(offset: Int64, whence: Whence) throws -> Int64

  /// Sets the current position to an absolute position from the start.
  /// 
  /// This is a convenience wrapper for seek(offset:whence:) with SEEK_SET.
  /// 
  /// - Parameter position: The absolute position from the start
  /// - Returns: The new position (should equal the input position)
  /// - Throws: VIPSError if seeking fails or is not supported
  public @discardableResult func setPosition(_ position: Int64) throws -> Int64

  /// Steals the accumulated data from a memory target.
  /// 
  /// This extracts all data that has been written to the target.
  /// This can only be used on memory targets created with init(toMemory:).
  /// The target should be ended before calling this method.
  /// 
  /// - Returns: Array containing all the written bytes
  /// - Throws: VIPSError if the target is not a memory target or steal fails
  public func steal() throws -> [UInt8]

  /// Steals the accumulated data from a memory target.
  /// 
  /// This extracts all data that has been written to the target.
  /// This can only be used on memory targets created with init(toMemory:).
  /// The target should be ended before calling this method.
  /// 
  /// - Parameter work: Closure that receives the stolen data buffer. The buffer
  ///             may not escape the closure.
  /// - Returns: The result of the work closure
  /// - Throws: VIPSError if the target is not a memory target or steal fails
  public func steal<Result>(_ work: (UnsafeRawBufferPointer) throws -> Result) throws -> Result

  /// Steals the accumulated data as a UTF-8 string from a memory target.
  /// 
  /// This extracts all data that has been written to the target and
  /// interprets it as a UTF-8 string. This can only be used on memory
  /// targets created with init(toMemory:). The target should be ended
  /// before calling this method.
  /// 
  /// - Returns: String containing all the written data
  /// - Throws: VIPSError if the target is not a memory target or steal fails
  public func stealText() throws -> String

  /// Reads data from the target into the provided buffer.
  /// 
  /// This operation is only supported on seekable targets (like files).
  /// Some formats (like TIFF) require the ability to read back data
  /// that has been written.
  /// 
  /// - Parameter buffer: Buffer to read data into
  /// - Returns: Number of bytes actually read
  /// - Throws: VIPSError if the read operation fails or is not supported
  public @discardableResult func unsafeRead(into buffer: UnsafeMutableRawBufferPointer) throws -> Int

  /// Writes raw data from a pointer to the target.
  /// 
  /// This allows writing data from unsafe pointers without copying.
  /// The memory must remain valid for the duration of the call.
  /// 
  public @discardableResult func write(_ data: UnsafeRawBufferPointer) throws -> Int

  /// Writes a string with XML-style entity encoding.
  /// 
  /// This writes a string while encoding XML entities like &, <, >, etc.
  /// This is useful when writing XML or HTML content.
  /// 
  /// - Parameter string: The string to write with entity encoding
  /// - Throws: VIPSError if the write operation fails
  public func writeAmp(_ string: String) throws

  /// Writes a string to the target.
  /// 
  /// The string is written as UTF-8 encoded bytes without a null terminator.
  /// 
  /// - Parameter string: The string to write
  /// - Throws: VIPSError if the write operation fails
  public func writes(_ string: String) throws
}
```

#### class VIPSTargetCustom

```swift
/// A custom VIPSTarget that allows you to implement your own write behavior.
/// 
/// This class provides a way to create targets with custom write, seek, and
/// read implementations. You can use this to write to custom destinations
/// like network streams, compressed files, or any other custom storage.
/// 
/// # Usage Example
/// 
/// ```swift
/// let customTarget = VIPSTargetCustom()
/// 
/// // Set up write handler
/// customTarget.onWrite { bytes in
///     // Write bytes to your custom destination
///     // Return the number of bytes actually written
///     return writeToCustomDestination(bytes)
/// }
/// 
/// // Set up end handler (replaces deprecated finish)
/// customTarget.onEnd {
///     // Finalize your custom destination
///     finalizeCustomDestination()
///     return 0  // 0 for success
/// }
/// 
/// // For seekable custom targets, also implement:
/// customTarget.onSeek { offset, whence in
///     return seekInCustomDestination(offset, whence)
/// }
/// 
/// customTarget.onRead { length in
///     return readFromCustomDestination(length)
/// }
/// ```
/// 
/// # Callback Requirements
/// 
/// - **Write callback**: Must consume as many bytes as possible and return the actual count
/// - **End callback**: Should finalize the destination and release resources
/// - **Seek callback**: Should change position and return new absolute position (-1 for error)
/// - **Read callback**: Should read up to the requested bytes and return actual data read
public final class VIPSTargetCustom: VIPSTarget, PointerWrapper, VIPSObjectProtocol {
  /// Creates a new custom target with default (no-op) implementations.
  /// 
  /// After creation, set up the appropriate callback handlers using
  /// onWrite(), onEnd(), onSeek(), and onRead() methods.
  public init()

  public required init(_ ptr: UnsafeMutableRawPointer)

  /// Sets the end handler for this custom target.
  /// 
  /// The end handler will be called when the target is being ended.
  /// Use this for cleanup operations like closing files or network connections.
  /// This replaces the deprecated finish handler.
  /// 
  /// - Parameter handler: A closure called when the target is ended
  ///   - Returns: 0 for success, non-zero for error
  public @discardableResult func onEnd(_ handler: @escaping () -> Int) -> Int

  /// Adds a read handler to this custom target.
  /// 
  /// The read handler enables reading back data that was previously written,
  /// which is required by some image formats (like TIFF). If your custom
  /// target doesn't support reading, don't set this handler.
  /// 
  /// - Parameter handler: A closure that handles read operations
  ///   - Parameter outputSpan: The destination span to read bytes into.
  public @discardableResult func onRead(_ handler: @escaping (inout OutputRawSpan) -> Void) -> Int

  /// Sets the seek handler for this custom target.
  /// 
  /// The seek handler enables random access within the target, which is
  /// required by some image formats (like TIFF). If your custom target
  /// doesn't support seeking, don't set this handler.
  /// 
  /// - Parameter handler: A closure that handles seek operations
  ///   - Parameter offset: Byte offset for the seek operation
  ///   - Parameter whence: How to interpret offset (SEEK_SET=0, SEEK_CUR=1, SEEK_END=2)
  ///   - Returns: New absolute position, or -1 for error
  public @discardableResult func onSeek(_ handler: @escaping (Int64, Whence) -> Int64) -> Int

  /// Adds a read handler to this custom target.
  /// 
  /// The read handler enables reading back data that was previously written,
  /// which is required by some image formats (like TIFF). If your custom
  /// target doesn't support reading, don't set this handler.
  /// 
  /// - Parameter handler: A closure that handles read operations
  ///   - Parameter buffer: The destination buffer to read bytes into.
  ///   - Returns: The actual number of bytes written to buffer.
  public @discardableResult func onUnsafeRead(_ handler: @escaping (UnsafeMutableRawBufferPointer) -> (Int)) -> Int

  /// Sets the write handler for this custom target.
  /// 
  /// The write handler will be called whenever data needs to be written
  /// to the target. It should consume as many bytes as possible and
  /// return the actual number of bytes written.
  /// 
  /// - Parameter handler: A closure that receives data and returns bytes written
  ///   - Parameter data: Buffer to write
  ///   - Returns: Number of bytes actually written (should be <= data.count)
  public @discardableResult func onUnsafeWrite(_ handler: @escaping (UnsafeRawBufferPointer) -> Int) -> Int

  public @discardableResult func onWrite(_ handler: @escaping (RawSpan) -> Int) -> Int
}
```

#### struct UnownedVIPSObjectRef

```swift
public struct UnownedVIPSObjectRef: PointerWrapper, VIPSObjectProtocol {
  public let ptr: UnsafeMutableRawPointer!

  public init(_ ptr: UnsafeMutableRawPointer)

  public func ref() -> UnownedVIPSObjectRef

  public func unref()
}
```

#### struct VIPSError

```swift
public struct VIPSError: Error, Sendable, SendableMetatype {
  /// A textual representation of this instance.
  /// 
  /// Calling this property directly is discouraged. Instead, convert an
  /// instance of any type to a string by using the `String(describing:)`
  /// initializer. This initializer works with any type, and uses the custom
  /// `description` property for types that conform to
  /// `CustomStringConvertible`:
  /// 
  ///     struct Point: CustomStringConvertible {
  ///         let x: Int, y: Int
  /// 
  ///         var description: String {
  ///             return "(\(x), \(y))"
  ///         }
  ///     }
  /// 
  ///     let p = Point(x: 21, y: 30)
  ///     let s = String(describing: p)
  ///     print(s)
  ///     // Prints "(21, 30)"
  /// 
  /// The conversion of `p` to a string in the assignment to `s` uses the
  /// `Point` type's `description` property.
  public var description: String { get }

  public let message: String
}
```

#### struct VIPSImageRef

```swift
public struct VIPSImageRef: PointerWrapper, VIPSImageProtocol, VIPSObjectProtocol {
  public var ptr: UnsafeMutableRawPointer!

  public init(_ ptr: UnsafeMutableRawPointer)
}
```

#### struct VIPSObjectRef

```swift
public struct VIPSObjectRef: PointerWrapper, VIPSObjectProtocol {
  public let ptr: UnsafeMutableRawPointer!

  public init(_ ptr: UnsafeMutableRawPointer)

  public consuming func unref()
}
```

#### struct VIPSOption

```swift
public struct VIPSOption {
  public init()

  public mutating func set<V>(_ name: String, value: V) where V : RawRepresentable, V.RawValue : BinaryInteger

  public mutating func setAny(_ name: String, value: Any) throws
}
```

#### struct Whence

```swift
public struct Whence: RawRepresentable, Sendable, SendableMetatype {
  public static var current: Whence { get }

  public static var end: Whence { get }

  public static var set: Whence { get }

  /// The corresponding value of the raw type.
  /// 
  /// A new instance initialized with `rawValue` will be equivalent to this
  /// instance. For example:
  /// 
  ///     enum PaperSize: String {
  ///         case A4, A5, Letter, Legal
  ///     }
  /// 
  ///     let selectedSize = PaperSize.Letter
  ///     print(selectedSize.rawValue)
  ///     // Prints "Letter"
  /// 
  ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
  ///     // Prints "true"
  public var rawValue: Int32

  /// Creates a new instance with the specified raw value.
  /// 
  /// If there is no value of the type that corresponds with the specified raw
  /// value, this initializer returns `nil`. For example:
  /// 
  ///     enum PaperSize: String {
  ///         case A4, A5, Letter, Legal
  ///     }
  /// 
  ///     print(PaperSize(rawValue: "Legal"))
  ///     // Prints "Optional(PaperSize.Legal)"
  /// 
  ///     print(PaperSize(rawValue: "Tabloid"))
  ///     // Prints "nil"
  /// 
  /// - Parameter rawValue: The raw value to use for the new instance.
  public init?(rawValue: Int32)
}
```

#### enum VIPS

```swift
public enum VIPS {
  public static func findLoader<Buffer>(buffer: Buffer) throws -> String where Buffer : Sequence, Buffer.Element == UInt8

  public static func findLoader(filename: String) -> String?

  public static func shutdown()

  public static func start(concurrency: Int = 0, logger: Logger = Logger(label: "VIPS"), loggingDelegate: VIPSLoggingDelegate? = nil) throws
}
```

#### protocol PointerWrapper

```swift
public protocol PointerWrapper : ~Copyable {
  public var ptr: UnsafeMutableRawPointer! { get }

  public init(_ ptr: UnsafeMutableRawPointer)
}
```

#### protocol VIPSImageProtocol

```swift
public protocol VIPSImageProtocol : VIPSObjectProtocol {
  public var bands: Int { get }

  public var height: Int { get }

  public var width: Int { get }
}
```

#### protocol VIPSLoggingDelegate

```swift
public protocol VIPSLoggingDelegate : AnyObject {
  public func debug(_ message: String)

  public func error(_ message: String)

  public func info(_ message: String)

  public func warning(_ message: String)
}
```

#### protocol VIPSObjectProtocol

```swift
public protocol VIPSObjectProtocol : PointerWrapper, ~Copyable {
  public var type: GType { get }

  public func disconnect(signalHandler: Int)

  public @discardableResult func onPreClose(_ handler: @escaping (UnownedVIPSObjectRef) -> Void) -> Int

  public func ref() -> Self

  public func unref()
}
```

#### Array extension

```swift
extension Array {
}
```

#### Collection extension

```swift
extension Collection {
  public func vips_findLoader() throws -> String
}
```

#### Globals

```swift
public func vipsFindLoader(path: String) -> String?

public typealias VIPSProgress = Cvips.VipsProgress

public typealias VipsAccess = Cvips.VipsAccess

public typealias VipsBandFormat = Cvips.VipsBandFormat

public typealias VipsIntent = Cvips.VipsIntent

public typealias VipsInteresting = Cvips.VipsInteresting

public typealias VipsInterpretation = Cvips.VipsInterpretation

public typealias VipsKernel = Cvips.VipsKernel

public typealias VipsOperationBoolean = Cvips.VipsOperationBoolean

public typealias VipsOperationComplex = Cvips.VipsOperationComplex

public typealias VipsOperationComplex2 = Cvips.VipsOperationComplex2

public typealias VipsOperationComplexget = Cvips.VipsOperationComplexget

public typealias VipsOperationMath = Cvips.VipsOperationMath

public typealias VipsOperationMath2 = Cvips.VipsOperationMath2

public typealias VipsOperationRelational = Cvips.VipsOperationRelational

public typealias VipsOperationRound = Cvips.VipsOperationRound

public typealias VipsPCS = Cvips.VipsPCS

public typealias VipsPrecision = Cvips.VipsPrecision

public typealias VipsSize = Cvips.VipsSize
```

<!-- Generated by interfazzle.swift on 2025-11-14 12:20:00 +0100 -->
