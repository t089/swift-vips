@testable import VIPS
import Cvips
import Testing

@Suite(.serialized)
struct CreateOperationsTests {
    init() {
        try! VIPS.start()
    }
    
    // MARK: - Basic Create Operations
    
    @Test
    func testBlack() throws {
        // Create a black image
        let image = try VIPSImage.black(10, 20, bands: 3)
        
        #expect(image.width == 10)
        #expect(image.height == 20)
        #expect(image.bands == 3)
        
        // All pixels should be 0
        let avg = try image.avg()
        #expect(avg == 0.0)
    }
    
    @Test
    func testGrey() throws {
        // Create a grey ramp
        let image = try VIPSImage.grey(10, 10)
        
        #expect(image.width == 10)
        #expect(image.height == 10)
        #expect(image.bands == 1)
        
        // Should create a horizontal gradient from 0 to 255
        let min = try image.min()
        let max = try image.max()
        
        #expect(min == 0.0)
        #expect(max > 200.0) // Should be close to 255
    }
    
    @Test
    func testXyz() throws {
        // Create XYZ coordinate image
        let image = try VIPSImage.xyz(5, 5)
        
        #expect(image.width == 5)
        #expect(image.height == 5)
        #expect(image.bands == 2) // X and Y coordinates
        
        // Extract X and Y bands
        let xBand = try image.extractBand(band: 0)
        let yBand = try image.extractBand(band: 1)
        
        // X should range from 0 to 4
        let xMin = try xBand.min()
        let xMax = try xBand.max()
        #expect(xMin == 0.0)
        #expect(xMax == 4.0)
        
        // Y should range from 0 to 4
        let yMin = try yBand.min()
        let yMax = try yBand.max()
        #expect(yMin == 0.0)
        #expect(yMax == 4.0)
    }
    
    @Test
    func testIdentity() throws {
        // Create identity LUT
        let image = try VIPSImage.identity()
        
        #expect(image.width == 256)
        #expect(image.height == 1)
        #expect(image.bands == 1)
        
        // Should contain values 0-255
        let min = try image.min()
        let max = try image.max()
        
        #expect(min == 0.0)
        #expect(max == 255.0)
        
        // Test with custom size
        let custom = try VIPSImage.identity(bands: 3, size: 512)
        #expect(custom.width == 512)
        #expect(custom.bands == 3)
    }
    
    @Test
    func testBuildlut() throws {
        // Create a simple matrix for buildlut
        let matrix = try VIPSImage.identity(bands: 1, size: 256)
            .linear(0.5, 0.0) // Scale by 0.5
        
        // Build LUT from matrix
        let lut = try matrix.buildlut()
        
        #expect(lut.width == 256)
        #expect(lut.height == 1)
    }
    
    @Test
    func testInvertlut() throws {
        // Create a simple LUT
        let lut = try VIPSImage.identity()
        
        // Invert it
        let inverted = try lut.invertlut()
        
        #expect(inverted.width == 256)
        #expect(inverted.height == 1)
    }
    
    @Test
    func testTonelut() throws {
        // Create a tone curve LUT
        let lut = try VIPSImage.tonelut()
        
        #expect(lut.width == 32768)
        #expect(lut.height == 1)
        #expect(lut.bands == 1)
    }
    
    // MARK: - Pattern Generation
    
    @Test
    func testEye() throws {
        // Create eye test pattern
        let image = try VIPSImage.eye(100, 100)
        
        #expect(image.width == 100)
        #expect(image.height == 100)
        #expect(image.bands == 1)
        
        // Should have varying values (not all same)
        let min = try image.min()
        let max = try image.max()
        #expect(min != max)
    }
    
    @Test
    func testZone() throws {
        // Create zone plate
        let image = try VIPSImage.zone(100, 100)
        
        #expect(image.width == 100)
        #expect(image.height == 100)
        #expect(image.bands == 1)
        
        // Zone plate should have values between -1 and 1
        let min = try image.min()
        let max = try image.max()
        #expect(min >= -1.0)
        #expect(max <= 1.0)
    }
    
    @Test
    func testSines() throws {
        // Create sine wave pattern
        let image = try VIPSImage.sines(100, 100)
        
        #expect(image.width == 100)
        #expect(image.height == 100)
        #expect(image.bands == 1)
        
        // Should create a sine wave pattern
        let min = try image.min()
        let max = try image.max()
        #expect(min < 0)
        #expect(max > 0)
    }
    
    // MARK: - Noise Generation
    
    @Test
    func testGaussnoise() throws {
        // Create Gaussian noise
        let image = try VIPSImage.gaussnoise(50, 50, mean: 128.0, sigma: 20.0)
        
        #expect(image.width == 50)
        #expect(image.height == 50)
        #expect(image.bands == 1)
        
        // Average should be close to mean
        let avg = try image.avg()
        #expect(abs(avg - 128.0) < 10.0) // Some variation expected
        
        // Should have variation (not all same value)
        let min = try image.min()
        let max = try image.max()
        #expect(min != max)
        #expect(max - min > 10.0) // Should have reasonable spread
    }
    
    @Test
    func testWorley() throws {
        // Create Worley noise
        let image = try VIPSImage.worley(100, 100)
        
        #expect(image.width == 100)
        #expect(image.height == 100)
        #expect(image.bands == 1)
        
        // Should have cellular pattern
        let min = try image.min()
        let max = try image.max()
        #expect(min >= 0.0)
        #expect(max <= 255.0)
    }
    
    @Test
    func testPerlin() throws {
        // Create Perlin noise
        let image = try VIPSImage.perlin(100, 100)
        
        #expect(image.width == 100)
        #expect(image.height == 100)
        #expect(image.bands == 1)
        
        // Should have smooth noise pattern
        let min = try image.min()
        let max = try image.max()
        #expect(min != max)
    }
    
    // MARK: - Mask Generation
    
    @Test
    func testMaskIdeal() throws {
        // Create ideal frequency mask
        let mask = try VIPSImage.maskIdeal(100, 100, frequencyCutoff: 0.5)
        
        #expect(mask.width == 100)
        #expect(mask.height == 100)
        #expect(mask.bands == 1)
        
        // Should have binary values (0 or 1)
        let min = try mask.min()
        let max = try mask.max()
        #expect(min == 0.0 || min == 1.0)
        #expect(max == 0.0 || max == 1.0)
    }
    
    @Test
    func testMaskButterworth() throws {
        // Create Butterworth frequency mask
        let mask = try VIPSImage.maskButterworth(
            100, 100,
            order: 2.0,
            frequencyCutoff: 0.5,
            amplitudeCutoff: 0.5
        )
        
        #expect(mask.width == 100)
        #expect(mask.height == 100)
        #expect(mask.bands == 1)
        
        // Should have smooth transition
        let min = try mask.min()
        let max = try mask.max()
        #expect(min >= 0.0)
        #expect(max <= 1.0)
    }
    
    @Test
    func testMaskGaussian() throws {
        // Create Gaussian frequency mask
        let mask = try VIPSImage.maskGaussian(
            100, 100,
            frequencyCutoff: 0.5,
            amplitudeCutoff: 0.5
        )
        
        #expect(mask.width == 100)
        #expect(mask.height == 100)
        #expect(mask.bands == 1)
        
        // Should have smooth Gaussian falloff
        let min = try mask.min()
        let max = try mask.max()
        #expect(min >= 0.0)
        #expect(max <= 1.0)
    }
    
    @Test
    func testMaskIdealRing() throws {
        // Create ideal ring mask
        let mask = try VIPSImage.maskIdealRing(
            100, 100,
            frequencyCutoff: 0.5,
            ringwidth: 0.1
        )
        
        #expect(mask.width == 100)
        #expect(mask.height == 100)
        #expect(mask.bands == 1)
        
        // Should create a ring pattern
        let avg = try mask.avg()
        #expect(avg > 0.0)
        #expect(avg < 255.0)
    }
    
    // MARK: - Matrix Generation
    
    @Test
    func testGaussmat() throws {
        // Create Gaussian matrix
        let matrix = try VIPSImage.gaussmat(sigma: 2.0)
        
        // Should create a matrix (size depends on sigma)
        #expect(matrix.width > 0)
        #expect(matrix.height > 0)
        #expect(matrix.bands == 1)
        
        // Center should have highest value
        let max = try matrix.max()
        #expect(max > 0.0)
        
        // Test with min amplitude
        let matrix2 = try VIPSImage.gaussmat(sigma: 2.0, minAmpl: 0.1)
        #expect(matrix2.width > 0)
        #expect(matrix2.height > 0)
    }
    
    @Test
    func testLogmat() throws {
        // Create Laplacian of Gaussian matrix
        let matrix = try VIPSImage.logmat(sigma: 1.4)
        
        // Should create a matrix
        #expect(matrix.width > 0)
        #expect(matrix.height > 0)
        #expect(matrix.bands == 1)
        
        // LoG has both positive and negative values
        let min = try matrix.min()
        let max = try matrix.max()
        #expect(min < 0.0)
        #expect(max > 0.0)
    }
    
    // MARK: - Fractal Generation
    
    @Test
    func testFractsurf() throws {
        // Create fractal surface
        let fractal = try VIPSImage.fractsurf(100, 100, fractalDimension: 2.5)
        
        #expect(fractal.width == 100)
        #expect(fractal.height == 100)
        #expect(fractal.bands == 1)
        
        // Should have fractal-like variation
        let min = try fractal.min()
        let max = try fractal.max()
        #expect(min != max)
    }
    
    // MARK: - Text Rendering
    
    @Test
    func testText() throws {
        // Create text image
        let text = try VIPSImage.text("Hello VIPS")
        
        // Text image should have non-zero dimensions
        #expect(text.width > 0)
        #expect(text.height > 0)
        #expect(text.bands == 1)
        
        // Should have text (not all black)
        let max = try text.max()
        #expect(max > 0.0)
        
        // Test with options
        let styledText = try VIPSImage.text(
            "Styled Text",
            font: "sans 20",
            width: 200,
            height: 50,
            align: .centre
        )
        
        #expect(styledText.width <= 200)
        #expect(styledText.height <= 50)
    }
}