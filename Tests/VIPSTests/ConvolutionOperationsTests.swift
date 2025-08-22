@testable import VIPS
import Cvips
import Testing

@Suite(.serialized)
struct ConvolutionOperationsTests {
    init() {
        try! VIPS.start()
    }
    
    // MARK: - Blur Operations
    
    @Test
    func testGaussblur() throws {
        // Create a sharp image with a white square on black background
        let image = try VIPSImage.black(20, 20, bands: 1)
        let white = try VIPSImage.black(4, 4, bands: 1).linear(0.0, 255.0)
        let sharp = try image.insert(sub: white, x: 8, y: 8)
        
        // Apply Gaussian blur
        let blurred = try sharp.gaussblur(sigma: 2.0)
        
        #expect(blurred.width == 20)
        #expect(blurred.height == 20)
        
        // Blurred image should have smoother transitions
        // Max value should be less than original due to spreading
        let maxSharp = try sharp.max()
        let maxBlurred = try blurred.max()
        
        #expect(maxBlurred < maxSharp)
        #expect(maxBlurred > 0) // Should still have some signal
        
        // Test with different sigma values
        let lessBlurred = try sharp.gaussblur(sigma: 0.5)
        let moreBlurred = try sharp.gaussblur(sigma: 5.0)
        
        let maxLess = try lessBlurred.max()
        let maxMore = try moreBlurred.max()
        
        // More blur should reduce the maximum more
        #expect(maxLess > maxMore)
    }
    
    @Test
    func testBlur() throws {
        // Create a test image
        let image = try VIPSImage.eye(20, 20)
        
        // Apply box blur (should be available through conv with appropriate mask)
        // Note: blur might be implemented as a special case of convolution
        let blurred = try image.blur()
        
        #expect(blurred.width == 20)
        #expect(blurred.height == 20)
        
        // Blurred image should have reduced contrast
        let stdOriginal = try image.deviate()
        let stdBlurred = try blurred.deviate()
        
        #expect(stdBlurred < stdOriginal)
    }
    
    // MARK: - Sharpening Operations
    
    @Test
    func testSharpen() throws {
        // Create a slightly blurred image first
        let image = try VIPSImage.eye(20, 20)
        let blurred = try image.gaussblur(sigma: 1.0)
        
        // Apply sharpening
        let sharpened = try blurred.sharpen()
        
        #expect(sharpened.width == 20)
        #expect(sharpened.height == 20)
        
        // Sharpened image should have increased contrast at edges
        let stdBlurred = try blurred.deviate()
        let stdSharpened = try sharpened.deviate()
        
        #expect(stdSharpened > stdBlurred)
        
        // Test with parameters
        let customSharpened = try blurred.sharpen(
            radius: 3,
            x1: 2.0,
            y2: 10.0,
            y3: 20.0,
            m1: 0.0,
            m2: 2.0
        )
        
        #expect(customSharpened.width == 20)
        #expect(customSharpened.height == 20)
    }
    
    // MARK: - Edge Detection Operations
    
    @Test
    func testSobel() throws {
        // Create an image with clear edges
        let image = try VIPSImage.black(20, 20, bands: 1)
        let white = try VIPSImage.black(10, 10, bands: 1).linear(0.0, 255.0)
        let withEdge = try image.insert(sub: white, x: 5, y: 5)
        
        // Apply Sobel edge detection
        let edges = try withEdge.sobel()
        
        #expect(edges.width == 20)
        #expect(edges.height == 20)
        
        // Should detect edges (non-zero values)
        let max = try edges.max()
        let avg = try edges.avg()
        
        #expect(max > 0)
        #expect(avg > 0) // Should have detected some edges
    }
    
    @Test
    func testCanny() throws {
        // Create an image with edges
        let image = try VIPSImage.black(20, 20, bands: 1)
        let white = try VIPSImage.black(8, 8, bands: 1).linear(0.0, 255.0)
        let withEdge = try image.insert(sub: white, x: 6, y: 6)
        
        // Apply Canny edge detection
        let edges = try withEdge.canny()
        
        #expect(edges.width == 20)
        #expect(edges.height == 20)
        
        // Canny produces binary edge map
        let max = try edges.max()
        let min = try edges.min()
        
        #expect(max > 0) // Should have found edges
        #expect(min == 0) // Background should be 0
        
        // Test with custom parameters
        let customEdges = try withEdge.canny(
            sigma: 1.4,
            precision: .integer
        )
        
        #expect(customEdges.width == 20)
        #expect(customEdges.height == 20)
    }
    
    @Test
    func testScharr() throws {
        // Create test image with edges
        let image = try VIPSImage.grey(20, 20)
        
        // Apply Scharr edge detection
        let edges = try image.scharr()
        
        #expect(edges.width == 20)
        #expect(edges.height == 20)
        
        // Should produce edge response
        let max = try edges.max()
        #expect(max > 0)
    }
    
    @Test
    func testCompass() throws {
        // Create an image with directional edges
        let image = try VIPSImage.black(20, 20, bands: 1)
        
        // Add a vertical edge
        let verticalLine = try VIPSImage.black(1, 10, bands: 1).linear(0.0, 255.0)
        let withVertical = try image.insert(sub: verticalLine, x: 10, y: 5)
        
        // Apply compass edge detection with custom mask
        let mask = try VIPSImage.maskIdeal(3, 3, frequencyCutoff: 0.5)
        let edges = try withVertical.compass(mask: mask)
        
        #expect(edges.width == 20)
        #expect(edges.height == 20)
        
        // Should detect the edge
        let max = try edges.max()
        #expect(max > 0)
    }
    
    // MARK: - Convolution Operations
    
    @Test
    func testConv() throws {
        // Create a simple image
        let image = try VIPSImage.eye(20, 20)
        
        // Create a simple 3x3 averaging kernel
        let kernel = try VIPSImage(fromMemory: Data([
            1.0/9.0, 1.0/9.0, 1.0/9.0,
            1.0/9.0, 1.0/9.0, 1.0/9.0,
            1.0/9.0, 1.0/9.0, 1.0/9.0
        ].flatMap { $0.data(using: .littleEndian)! }), width: 3, height: 3, bands: 1, format: .double)
        
        // Apply convolution
        let convolved = try image.conv(mask: kernel)
        
        #expect(convolved.width == 20)
        #expect(convolved.height == 20)
        
        // Convolution with averaging kernel should reduce contrast
        let stdOriginal = try image.deviate()
        let stdConvolved = try convolved.deviate()
        
        #expect(stdConvolved < stdOriginal)
        
        // Test with precision parameter
        let convolvedInt = try image.conv(mask: kernel, precision: .integer)
        #expect(convolvedInt.width == 20)
    }
    
    @Test
    func testConvf() throws {
        // Create test image
        let image = try VIPSImage.grey(10, 10)
        
        // Create a float kernel
        let kernel = try VIPSImage.gaussmat(sigma: 1.0)
        
        // Apply float convolution
        let convolved = try image.convf(mask: kernel)
        
        #expect(convolved.width == 10)
        #expect(convolved.height == 10)
        
        // Should produce smooth result
        let std = try convolved.deviate()
        #expect(std > 0)
    }
    
    @Test
    func testConvi() throws {
        // Create test image
        let image = try VIPSImage.grey(10, 10)
        
        // Create an integer kernel (Laplacian)
        let kernel = try VIPSImage(fromMemory: Data([
            0.0, -1.0, 0.0,
            -1.0, 4.0, -1.0,
            0.0, -1.0, 0.0
        ].flatMap { $0.data(using: .littleEndian)! }), width: 3, height: 3, bands: 1, format: .double)
        
        // Apply integer convolution
        let convolved = try image.convi(mask: kernel)
        
        #expect(convolved.width == 10)
        #expect(convolved.height == 10)
    }
    
    @Test
    func testConvsep() throws {
        // Create test image
        let image = try VIPSImage.eye(20, 20)
        
        // Create a separable kernel (1D Gaussian)
        let kernel1d = try VIPSImage(fromMemory: Data([
            0.25, 0.5, 0.25
        ].flatMap { $0.data(using: .littleEndian)! }), width: 3, height: 1, bands: 1, format: .double)
        
        // Apply separable convolution
        let convolved = try image.convsep(mask: kernel1d)
        
        #expect(convolved.width == 20)
        #expect(convolved.height == 20)
        
        // Should produce smoothing effect
        let stdOriginal = try image.deviate()
        let stdConvolved = try convolved.deviate()
        
        #expect(stdConvolved < stdOriginal)
    }
    
    @Test
    func testConva() throws {
        // Create test image
        let image = try VIPSImage.grey(20, 20)
        
        // Create a kernel
        let kernel = try VIPSImage.gaussmat(sigma: 1.0)
        
        // Apply approximate convolution (faster but less accurate)
        let convolved = try image.conva(mask: kernel)
        
        #expect(convolved.width == 20)
        #expect(convolved.height == 20)
        
        // Test with layers parameter for accuracy control
        let moreAccurate = try image.conva(mask: kernel, layers: 10)
        #expect(moreAccurate.width == 20)
    }
    
    @Test
    func testConvasep() throws {
        // Create test image
        let image = try VIPSImage.eye(20, 20)
        
        // Create a 1D kernel
        let kernel1d = try VIPSImage(fromMemory: Data([
            0.25, 0.5, 0.25
        ].flatMap { $0.data(using: .littleEndian)! }), width: 3, height: 1, bands: 1, format: .double)
        
        // Apply approximate separable convolution
        let convolved = try image.convasep(mask: kernel1d)
        
        #expect(convolved.width == 20)
        #expect(convolved.height == 20)
    }
    
    // MARK: - Correlation Operations
    
    @Test
    func testFastcor() throws {
        // Create a reference image
        let reference = try VIPSImage.black(5, 5, bands: 1)
            .linear(0.0, 100.0)
        
        // Create a larger image containing the reference
        let image = try VIPSImage.black(20, 20, bands: 1)
        let withRef = try image.insert(sub: reference, x: 10, y: 10)
        
        // Perform fast correlation
        let correlation = try withRef.fastcor(ref: reference)
        
        #expect(correlation.width == 20)
        #expect(correlation.height == 20)
        
        // Should have high correlation at the location of reference
        let max = try correlation.max()
        #expect(max > 0)
    }
    
    @Test
    func testSpcor() throws {
        // Create a reference pattern
        let reference = try VIPSImage.eye(5, 5)
        
        // Create an image with the pattern
        let image = try VIPSImage.black(20, 20, bands: 1)
        let withPattern = try image.insert(sub: reference, x: 7, y: 7)
        
        // Perform spatial correlation
        let correlation = try withPattern.spcor(ref: reference)
        
        #expect(correlation.width == 20)
        #expect(correlation.height == 20)
        
        // Should find the pattern
        let max = try correlation.max()
        #expect(max > 0)
    }
}

// Helper extension for creating data from Double
extension Double {
    func data(using endianness: Endianness) -> Data {
        var value = self
        return Data(bytes: &value, count: MemoryLayout<Double>.size)
    }
}

enum Endianness {
    case littleEndian
    case bigEndian
}