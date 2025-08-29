@testable import VIPS
import Testing
import Foundation

// MARK: - Format Groups

let allFormats: [VipsBandFormat] = [.uchar, .char, .ushort, .short, .uint, .int, .float, .double, .complex, .dpcomplex]
let intFormats: [VipsBandFormat] = [.uchar, .char, .ushort, .short, .uint, .int]
let nonComplexFormats: [VipsBandFormat] = [.uchar, .char, .ushort, .short, .uint, .int, .float, .double]
let floatFormats: [VipsBandFormat] = [.float, .double]
let complexFormats: [VipsBandFormat] = [.complex, .dpcomplex]
let signedFormats: [VipsBandFormat] = [.char, .short, .int, .float, .double, .complex, .dpcomplex]
let unsignedFormats: [VipsBandFormat] = [.uchar, .ushort, .uint]

// MARK: - Color Spaces - commented out for now
let colourColourspaces: [VipsInterpretation] = [.xyz, .lab, .lch, .cmc, .labs, .scrgb, .hsv, .srgb, .yxy]
let monoColourspaces: [VipsInterpretation] = [.bw] 
let codedColourspaces: [VipsInterpretation] = [.labq]
let sixteenbitColourspaces: [VipsInterpretation] = [.grey16, .rgb16]
let cmykColourspaces: [VipsInterpretation] = [.cmyk]

// MARK: - Test Utilities

/// Assert that two doubles are approximately equal
func assertAlmostEqual(_ a: Double, _ b: Double, threshold: Double = 0.01, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(abs(a - b) < threshold, "Values \(a) and \(b) differ by more than \(threshold)", sourceLocation: sourceLocation)
}

/// Assert that two images are equal within a tolerance
func assertImagesEqual(_ a: VIPSImage, _ b: VIPSImage, maxDiff: Double = 0.01, sourceLocation: SourceLocation = #_sourceLocation) throws {
    #expect(a.width == b.width, "Width mismatch: \(a.width) != \(b.width)", sourceLocation: sourceLocation)
    #expect(a.height == b.height, "Height mismatch: \(a.height) != \(b.height)", sourceLocation: sourceLocation)
    #expect(a.bands == b.bands, "Bands mismatch: \(a.bands) != \(b.bands)", sourceLocation: sourceLocation)
    
    let diff = try (a - b).abs().max()
    #expect(diff <= maxDiff, "Max difference \(diff) exceeds threshold \(maxDiff)", sourceLocation: sourceLocation)
}

/// Create a test image with specified dimensions and value
func makeTestImage(width: Int = 100, height: Int = 100, bands: Int = 1, value: Double = 0.0) throws -> VIPSImage {
    return try VIPSImage.black(width: width, height: height, bands: bands)
        .linear(0.0, value)
}

/// Create a gradient test image
func makeGradientImage(width: Int = 100, height: Int = 100) throws -> VIPSImage {
    return try VIPSImage.xyz(width: width, height: height)
        .extractBand(0) // Just X coordinate for horizontal gradient
}

/// Create a test image with multiple regions of different values
func makeRegionTestImage(regionSize: Int = 50) throws -> VIPSImage {
    let region1 = try makeTestImage(width: regionSize, height: regionSize, value: 10)
    let region2 = try makeTestImage(width: regionSize, height: regionSize, value: 20)
    let region3 = try makeTestImage(width: regionSize, height: regionSize, value: 30)
    let region4 = try makeTestImage(width: regionSize, height: regionSize, value: 40)
    
    let top = try region1.join(in2: region2, direction: .horizontal)
    let bottom = try region3.join(in2: region4, direction: .horizontal)
    return try top.join(in2: bottom, direction: .vertical)
}

/// Test Paths
struct TestImages {
    static let testDataPath = Bundle.module.resourceURL!.appendingPathComponent("data")
    
    // Standard test images
    static let colour = testDataPath.appendingPathComponent("sample.jpg")
    static let mono = testDataPath.appendingPathComponent("bay.jpg")
    static let cmyk = testDataPath.appendingPathComponent("cmyk.pdf")
    static let transparency = testDataPath.appendingPathComponent("transparency.png")
    static let multiPage = testDataPath.appendingPathComponent("multipage.tif")
    static let mythicalGiant = testDataPath.appendingPathComponent("mythical_giant.jpg")
    
    // Format-specific test images
    static let tiff = testDataPath.appendingPathComponent("sample.tif")
    static let png = testDataPath.appendingPathComponent("sample.png")
    static let webp = testDataPath.appendingPathComponent("sample.webp")
    static let gif = testDataPath.appendingPathComponent("cogs.gif")
    static let svg = testDataPath.appendingPathComponent("sample.svg")
    static let avif = testDataPath.appendingPathComponent("sample.avif")
    static let exr = testDataPath.appendingPathComponent("sample.exr")
    static let hdr = testDataPath.appendingPathComponent("sample.hdr")
}

// MARK: - Max Values for Different Formats

let maxValue: [String: Double] = [
    "uchar": 255,
    "char": 127,
    "ushort": 65535,
    "short": 32767,
    "uint": 4294967295,
    "int": 2147483647
]