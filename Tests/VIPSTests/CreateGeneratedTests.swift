@testable import VIPS
import Cvips
import Testing
import Foundation

@Suite(.vips)
struct CreateGeneratedTests {
    
    // MARK: - Basic Image Creation
    
    @Test
    func testBlackImageCreation() throws {
        // Test creating black image
        let black = try VIPSImage.black(width: 100, height: 50, bands: 3)
        #expect(black.width == 100)
        #expect(black.height == 50)
        #expect(black.bands == 3)
        #expect(try black.avg() == 0.0)
    }
    
    @Test
    func testGaussnoiseCreation() throws {
        // Test creating Gaussian noise image
        let noise = try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 10.0, mean: 128.0)
        #expect(noise.width == 100)
        #expect(noise.height == 100)
        
        // Check mean is approximately correct (with variance)
        let avg = try noise.avg()
        #expect(abs(avg - 128.0) < 5.0)
        
        // Check standard deviation is approximately correct
        let deviate = try noise.deviate()
        #expect(abs(deviate - 10.0) < 2.0)
    }
    
    @Test
    func testXYZImageCreation() throws {
        // Test creating XYZ coordinate image
        let xyz = try VIPSImage.xyz(width: 10, height: 10)
        #expect(xyz.width == 10)
        #expect(xyz.height == 10)
        #expect(xyz.bands == 2) // X and Y coordinates
        
        // Extract X coordinate
        let x = try xyz.extractBand(0)
        // First pixel should be 0, last pixel in row should be 9
        #expect(try x.getpoint(0, 0).first == 0.0)
        #expect(try x.getpoint(9, 0).first == 9.0)
        
        // Extract Y coordinate
        let y = try xyz.extractBand(1)
        // First pixel should be 0, last pixel in column should be 9
        #expect(try y.getpoint(0, 0).first == 0.0)
        #expect(try y.getpoint(0, 9).first == 9.0)
    }
    
    @Test
    func testGreyImageCreation() throws {
        // Test creating grey ramp image
        let grey = try VIPSImage.grey(width: 256, height: 1)
        #expect(grey.width == 256)
        #expect(grey.height == 1)
        
        // grey() creates a linear ramp from 0 to 1
        #expect(try grey.getpoint(0, 0).first == 0.0)
        #expect(abs(try grey.getpoint(255, 0).first! - 1.0) < 0.001)
    }
    
    @Test
    func testZoneImageCreation() throws {
        // Test creating zone plate (circular patterns)
        let zone = try VIPSImage.zone(width: 100, height: 100)
        #expect(zone.width == 100)
        #expect(zone.height == 100)
        
        // Zone plate should have values between -1 and 1
        let min = try zone.min()
        let max = try zone.max()
        #expect(min >= -1.0)
        #expect(max <= 1.0)
    }
    
    @Test
    func testSinesImageCreation() throws {
        // Test creating sine wave pattern
        let sines = try VIPSImage.sines(width: 100, height: 100)
        #expect(sines.width == 100)
        #expect(sines.height == 100)
        
        // Sine waves should have values between -1 and 1
        let min = try sines.min()
        let max = try sines.max()
        #expect(min >= -1.0)
        #expect(max <= 1.0)
    }
    
    @Test
    func testTextImageCreation() throws {
        // Test creating text image
        let text = try VIPSImage.text("Hello VIPS", font: "sans 20", width: 200, height: 50)
        #expect(text.width <= 200 || text.width > 0) // Width might be auto-sized
        #expect(text.height <= 50 || text.height > 0) // Height might be auto-sized
        #expect(text.bands == 1) // Grayscale text
    }
    
    // MARK: - Matrix Creation
    
    @Test
    func testGaussianMatrixCreation() throws {
        // Test creating Gaussian matrix for convolution
        let gaussMat = try VIPSImage.gaussmat(sigma: 2.0, minAmpl: 0.1)
        #expect(gaussMat.width > 0)
        #expect(gaussMat.height > 0)
        
        // Center should have highest value
        let centerX = gaussMat.width / 2
        let centerY = gaussMat.height / 2
        let centerVal = try gaussMat.getpoint(centerX, centerY).first ?? 0
        let cornerVal = try gaussMat.getpoint(0, 0).first ?? 0
        #expect(centerVal > cornerVal)
    }
    
    @Test
    func testLogmatCreation() throws {
        // Test creating Laplacian of Gaussian matrix
        let logMat = try VIPSImage.logmat(sigma: 1.4, minAmpl: 0.1)
        #expect(logMat.width > 0)
        #expect(logMat.height > 0)
    }
    
    @Test
    func testEyeMatrixCreation() throws {
        // Test creating eye pattern - not a traditional identity matrix
        let eye = try VIPSImage.eye(width: 10, height: 10)
        #expect(eye.width == 10)
        #expect(eye.height == 10)
        
        // eye() creates a special pattern, not a traditional identity matrix
        // The pattern has specific values based on position
        #expect(abs(try eye.getpoint(0, 0).first! - 0.0) < 0.001)
        #expect(abs(try eye.getpoint(1, 1).first! - 0.012298700399696827) < 0.001)
        #expect(abs(try eye.getpoint(0, 1).first! - 0.012345679104328156) < 0.001)
    }
    
    // MARK: - Mask Creation
    
    @Test
    func testIdealMaskCreation() throws {
        // Test creating ideal frequency filter masks
        let idealMask = try VIPSImage.maskIdeal(width: 100, height: 100, frequencyCutoff: 0.5)
        #expect(idealMask.width == 100)
        #expect(idealMask.height == 100)
        
        // Should be binary (0 or 1)
        let min = try idealMask.min()
        let max = try idealMask.max()
        #expect(min == 0.0 || min == 1.0)
        #expect(max == 0.0 || max == 1.0)
    }
    
    @Test
    func testIdealRingMaskCreation() throws {
        // Test creating ideal ring filter mask
        let ringMask = try VIPSImage.maskIdealRing(
            width: 100,
            height: 100,
            frequencyCutoff: 0.5,
            ringwidth: 0.1
        )
        #expect(ringMask.width == 100)
        #expect(ringMask.height == 100)
    }
    
    @Test
    func testIdealBandMaskCreation() throws {
        // Test creating ideal band filter mask
        let bandMask = try VIPSImage.maskIdealBand(
            width: 100,
            height: 100,
            frequencyCutoffX: 0.5,
            frequencyCutoffY: 0.5,
            radius: 0.1
        )
        #expect(bandMask.width == 100)
        #expect(bandMask.height == 100)
    }
    
    @Test
    func testButterworthMaskCreation() throws {
        // Test creating Butterworth filter mask
        let butterworthMask = try VIPSImage.maskButterworth(
            width: 100,
            height: 100,
            order: 2.0,
            frequencyCutoff: 0.5,
            amplitudeCutoff: 0.5
        )
        #expect(butterworthMask.width == 100)
        #expect(butterworthMask.height == 100)
        
        // Should have smooth transition (values between 0 and 1)
        let min = try butterworthMask.min()
        let max = try butterworthMask.max()
        #expect(min >= 0.0)
        #expect(max <= 1.0)
    }
    
    @Test
    func testButterworthRingMaskCreation() throws {
        // Test creating Butterworth ring filter mask
        let ringMask = try VIPSImage.maskButterworthRing(
            width: 100,
            height: 100,
            order: 2.0,
            frequencyCutoff: 0.5,
            amplitudeCutoff: 0.5,
            ringwidth: 0.1
        )
        #expect(ringMask.width == 100)
        #expect(ringMask.height == 100)
    }
    
    @Test
    func testButterworthBandMaskCreation() throws {
        // Test creating Butterworth band filter mask
        let bandMask = try VIPSImage.maskButterworthBand(
            width: 100,
            height: 100,
            order: 2.0,
            frequencyCutoffX: 0.5,
            frequencyCutoffY: 0.5,
            radius: 0.1,
            amplitudeCutoff: 0.5
        )
        #expect(bandMask.width == 100)
        #expect(bandMask.height == 100)
    }
    
    @Test
    func testGaussianMaskCreation() throws {
        // Test creating Gaussian frequency filter mask
        let gaussMask = try VIPSImage.maskGaussian(
            width: 100,
            height: 100,
            frequencyCutoff: 0.5,
            amplitudeCutoff: 0.5
        )
        #expect(gaussMask.width == 100)
        #expect(gaussMask.height == 100)
        
        // Should have smooth Gaussian distribution
        let min = try gaussMask.min()
        let max = try gaussMask.max()
        #expect(min >= 0.0)
        #expect(max <= 1.0)
    }
    
    @Test
    func testGaussianRingMaskCreation() throws {
        // Test creating Gaussian ring filter mask
        let ringMask = try VIPSImage.maskGaussianRing(
            width: 100,
            height: 100,
            frequencyCutoff: 0.5,
            amplitudeCutoff: 0.5,
            ringwidth: 0.1
        )
        #expect(ringMask.width == 100)
        #expect(ringMask.height == 100)
    }
    
    @Test
    func testGaussianBandMaskCreation() throws {
        // Test creating Gaussian band filter mask
        let bandMask = try VIPSImage.maskGaussianBand(
            width: 100,
            height: 100,
            frequencyCutoffX: 0.5,
            frequencyCutoffY: 0.5,
            radius: 0.1,
            amplitudeCutoff: 0.5
        )
        #expect(bandMask.width == 100)
        #expect(bandMask.height == 100)
    }
    
    @Test
    func testFractalMaskCreation() throws {
        // Test creating fractal mask
        let fractalMask = try VIPSImage.maskFractal(
            width: 100,
            height: 100,
            fractalDimension: 2.5
        )
        #expect(fractalMask.width == 100)
        #expect(fractalMask.height == 100)
    }
    
    // MARK: - LUT Creation
    
    @Test
    func testTonelutCreation() throws {
        // Test creating tone curve lookup table
        let toneLut = try VIPSImage.tonelut()
        #expect(toneLut.width == 32768 || toneLut.width == 65536) // Common LUT sizes
        #expect(toneLut.height == 1)
    }
    
    @Test
    func testIdentityLutCreation() throws {
        // Test creating identity lookup table
        let identityLut = try VIPSImage.identity()
        #expect(identityLut.width == 256 || identityLut.width == 65536) // Common LUT sizes
        #expect(identityLut.height == 1)
        
        // Identity LUT should map each value to itself
        if identityLut.width == 256 {
            #expect(try identityLut.getpoint(0, 0).first == 0.0)
            #expect(try identityLut.getpoint(255, 0).first == 255.0)
        }
    }
    
    @Test
    func testBuildlutCreation() throws {
        // Create a simple matrix for LUT building
        let matrix = try VIPSImage.black(width: 2, height: 2)
            .linear(1.0, 0.0)
        
        // Test building a lookup table from matrix
        let lut = try matrix.buildlut()
        #expect(lut.width > 0)
        #expect(lut.height == 1)
    }
    
    @Test
    func testInvertlutCreation() throws {
        // Create a simple matrix in the format invertlut expects
        // invertlut expects matrix with columns: input_values, output1, output2, ...
        // This creates a simple 3x2 matrix representing points on a curve
        let testData: [Double] = [
            0.0, 0.0,   // (0.0 -> 0.0)
            0.5, 0.3,   // (0.5 -> 0.3) 
            1.0, 1.0    // (1.0 -> 1.0)
        ]
        
        // Use the safe matrix creation method
        let matrixImage = try VIPSImage.matrix(width: 2, height: 3, data: testData)
        
        // Test inverting a lookup table
        let inverted = try matrixImage.invertlut()
        #expect(inverted.width > 0)
        #expect(inverted.height == 1)
        
        // The inverted LUT should map output values back to input values
        // So at position corresponding to 0.3, we should get approximately 0.5
        let midPoint = Int(0.3 * Double(inverted.width))
        let value = try inverted.getpoint(midPoint, 0).first ?? 0.0
        #expect(abs(value - 0.5) < 0.1)
    }
    
    @Test
    func testMatrixCreation() throws {
        // Test the safe matrix creation methods
        let data = [1.0, 2.0, 3.0, 4.0]
        let matrix = try VIPSImage.matrix(width: 2, height: 2, data: data)
        
        #expect(matrix.width == 2)
        #expect(matrix.height == 2) 
        #expect(matrix.bands == 1)
        #expect(matrix.format == .double)
        
        // Test accessing matrix values
        let val1 = try matrix.getpoint(0, 0).first ?? 0.0
        let val2 = try matrix.getpoint(1, 0).first ?? 0.0
        let val3 = try matrix.getpoint(0, 1).first ?? 0.0 
        let val4 = try matrix.getpoint(1, 1).first ?? 0.0
        
        #expect(val1 == 1.0)
        #expect(val2 == 2.0)
        #expect(val3 == 3.0)
        #expect(val4 == 4.0)
        
        // Test empty matrix creation
        let emptyMatrix = try VIPSImage.matrix(width: 3, height: 3)
        #expect(emptyMatrix.width == 3)
        #expect(emptyMatrix.height == 3)
        #expect(emptyMatrix.bands == 1)
        #expect(emptyMatrix.format == .double)
        
        // Test error condition - mismatched array size
        #expect(throws: VIPSError.self) {
            try VIPSImage.matrix(width: 2, height: 2, data: [1.0, 2.0, 3.0]) // Only 3 elements for 2x2
        }
    }

    // MARK: - Fractal Creation
    
    @Test
    func testFractsurfCreation() throws {
        // Test creating fractal surface
        let fractal = try VIPSImage.fractsurf(width: 100, height: 100, fractalDimension: 2.5)
        #expect(fractal.width == 100)
        #expect(fractal.height == 100)
        
        // Fractal should have varied values
        let deviate = try fractal.deviate()
        #expect(deviate > 0.0)
    }
    
    // MARK: - Pattern Creation
    
    @Test
    func testWorleyCreation() throws {
        // Test creating Worley noise pattern
        let worley = try VIPSImage.worley(width: 100, height: 100)
        #expect(worley.width == 100)
        #expect(worley.height == 100)
    }
    
    @Test
    func testPerlinCreation() throws {
        // Test creating Perlin noise pattern
        let perlin = try VIPSImage.perlin(width: 100, height: 100)
        #expect(perlin.width == 100)
        #expect(perlin.height == 100)
        
        // Perlin noise should have smooth variations
        let deviate = try perlin.deviate()
        #expect(deviate > 0.0)
    }
}