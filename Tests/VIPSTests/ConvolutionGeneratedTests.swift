@testable import VIPS
import Cvips
import Testing

@Suite(.vips)
struct ConvolutionGeneratedTests {
    
    // MARK: - Basic Convolution Operations
    
    @Test
    func testConvOperations() throws {
        // Create a simple test image
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create a simple blur kernel (3x3 box filter)
        // Start with a black image and add a constant value to create uniform kernel
        let kernel = try VIPSImage.black(width: 3, height: 3)
            .linear(1.0, 1.0) // This creates a 3x3 kernel filled with 1.0
        
        // Test basic convolution
        let convolved = try image.conv(mask: kernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
        #expect(abs(try convolved.avg() - 1152.0) < 10.0) // 128 * 9 = 1152
        
        // Test with precision parameter
        let convolvedInt = try image.conv(mask: kernel, precision: .integer)
        #expect(convolvedInt.width == image.width)
        
        let convolvedFloat = try image.conv(mask: kernel, precision: .float)
        #expect(convolvedFloat.width == image.width)
        
        let convolvedApprox = try image.conv(mask: kernel, precision: .approximate)
        #expect(convolvedApprox.width == image.width)
    }
    
    @Test
    func testConvaOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create integer kernel
        let kernel = try VIPSImage.black(width: 3, height: 3)
            .linear(0.0, 1.0)
            .cast(.int)
        
        // Test approximate integer convolution
        let convolved = try image.conva(mask: kernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
        
        // Test with layers parameter
        let convolvedLayers = try image.conva(mask: kernel, layers: 5)
        #expect(convolvedLayers.width == image.width)
        
        // Test with cluster parameter
        let convolvedCluster = try image.conva(mask: kernel, cluster: 2)
        #expect(convolvedCluster.width == image.width)
    }
    
    @Test
    func testConvasepOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create a separable kernel (should be a 1D kernel)
        let kernel = try VIPSImage.black(width: 1, height: 5)
            .linear(0.0, 1.0)
            .cast(.int)
        
        // Test approximate separable convolution
        let convolved = try image.convasep(mask: kernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
        
        // Test with layers
        let convolvedLayers = try image.convasep(mask: kernel, layers: 3)
        #expect(convolvedLayers.width == image.width)
    }
    
    @Test
    func testConvfOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create float kernel
        let kernel = try VIPSImage.black(width: 3, height: 3)
            .linear(0.0, 1.0 / 9.0)
            .cast(.float)
        
        // Test float convolution
        let convolved = try image.convf(mask: kernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
        #expect(abs(try convolved.avg() - 128.0) < 1.0)
    }
    
    @Test
    func testConviOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create integer kernel
        let kernel = try VIPSImage.black(width: 3, height: 3)
            .linear(0.0, 1.0)
            .cast(.int)
        
        // Test integer convolution
        let convolved = try image.convi(mask: kernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
    }
    
    @Test
    func testConvsepOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create a separable kernel
        let kernel = try VIPSImage.black(width: 1, height: 5)
            .linear(0.0, 0.2)
        
        // Test separable convolution
        let convolved = try image.convsep(mask: kernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
        
        // Test with different precision
        let convolvedInt = try image.convsep(mask: kernel, precision: .integer)
        #expect(convolvedInt.width == image.width)
        
        let convolvedFloat = try image.convsep(mask: kernel, precision: .float)
        #expect(convolvedFloat.width == image.width)
    }
    
    // MARK: - Blur Operations
    
    @Test
    func testGaussblurOperations() throws {
        let image = try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 30.0, mean: 128.0)
        
        // Test basic gaussian blur
        let blurred = try image.gaussblur(sigma: 2.0)
        #expect(blurred.width == image.width)
        #expect(blurred.height == image.height)
        
        // The blurred image should have less variance than the original
        let originalDev = try image.deviate()
        let blurredDev = try blurred.deviate()
        #expect(blurredDev < originalDev)
        
        // Test with minimum amplitude
        let blurredMinAmpl = try image.gaussblur(sigma: 2.0, minAmpl: 0.1)
        #expect(blurredMinAmpl.width == image.width)
        
        // Test with different precision
        let blurredInt = try image.gaussblur(sigma: 2.0, precision: .integer)
        #expect(blurredInt.width == image.width)
        
        let blurredFloat = try image.gaussblur(sigma: 2.0, precision: .float)
        #expect(blurredFloat.width == image.width)
    }
    
    // MARK: - Sharpening Operations
    
    @Test
    func testSharpenOperations() throws {
        // Create a slightly blurred image to sharpen
        // Ensure it has a proper color interpretation for sharpen to work
        let original = try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 10.0, mean: 128.0)
            .colourspace(space: .srgb)
        let blurred = try original.gaussblur(sigma: 1.0)
        
        // Test basic sharpen
        let sharpened = try blurred.sharpen()
        #expect(sharpened.width == blurred.width)
        #expect(sharpened.height == blurred.height)
        
        // Test with custom parameters
        let sharpenedCustom = try blurred.sharpen(
            sigma: 1.5,
            x1: 2.0,
            y2: 10.0,
            y3: 20.0,
            m1: 0.0,
            m2: 3.0
        )
        #expect(sharpenedCustom.width == blurred.width)
        #expect(sharpenedCustom.height == blurred.height)
    }
    
    // MARK: - Edge Detection Operations
    
    @Test
    func testSobelOperations() throws {
        // Create an image with edges (a white square on black background)
        let background = try VIPSImage.black(width: 100, height: 100)
        let square = try VIPSImage.black(width: 50, height: 50)
            .linear(1.0, 255.0)
        let image = try background.insert(sub: square, x: 25, y: 25)
        
        // Test Sobel edge detection
        let edges = try image.sobel()
        #expect(edges.width == image.width)
        #expect(edges.height == image.height)
        
        // Edge image should have non-zero values where edges are
        #expect(try edges.max() > 0)
    }
    
    @Test
    func testCannyOperations() throws {
        // Create an image with edges
        let background = try VIPSImage.black(width: 100, height: 100)
        let square = try VIPSImage.black(width: 50, height: 50)
            .linear(1.0, 255.0)
        let image = try background.insert(sub: square, x: 25, y: 25)
        
        // Test Canny edge detection
        let edges = try image.canny()
        #expect(edges.width == image.width)
        #expect(edges.height == image.height)
        
        // Test with custom sigma
        let edgesCustom = try image.canny(sigma: 2.0)
        #expect(edgesCustom.width == image.width)
        
        // Test with precision
        let edgesInt = try image.canny(precision: .integer)
        #expect(edgesInt.width == image.width)
        
        let edgesFloat = try image.canny(precision: .float)
        #expect(edgesFloat.width == image.width)
    }
    
    // MARK: - Using Generated Kernels
    
    @Test
    func testConvolutionWithGaussianKernel() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create Gaussian kernel
        let gaussKernel = try VIPSImage.gaussmat(sigma: 2.0, minAmpl: 0.2)
        
        // Convolve with Gaussian kernel
        let convolved = try image.conv(mask: gaussKernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
        #expect(abs(try convolved.avg() - 128.0) < 1.0)
    }
    
    @Test
    func testConvolutionWithLaplacianKernel() throws {
        let image = try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 20.0, mean: 128.0)
        
        // Create Laplacian of Gaussian kernel
        let logKernel = try VIPSImage.logmat(sigma: 1.5, minAmpl: 0.1)
        
        // Convolve with LoG kernel
        let convolved = try image.conv(mask: logKernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
    }
    
    // MARK: - Edge Cases
    
    @Test
    func testConvolutionWithSmallImages() throws {
        // Test with very small image
        let smallImage = try VIPSImage.black(width: 5, height: 5)
            .linear(1.0, 100.0)
        
        let kernel = try VIPSImage.black(width: 3, height: 3)
            .linear(0.0, 1.0 / 9.0)
        
        let convolved = try smallImage.conv(mask: kernel)
        #expect(convolved.width == smallImage.width)
        #expect(convolved.height == smallImage.height)
    }
    
    @Test
    func testConvolutionWithLargeKernels() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create a large kernel
        let largeKernel = try VIPSImage.black(width: 15, height: 15)
            .linear(0.0, 1.0 / 225.0)
        
        let convolved = try image.conv(mask: largeKernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
    }
    
    @Test
    func testConvolutionWithAsymmetricKernels() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Create asymmetric kernels
        let horizontalKernel = try VIPSImage.black(width: 5, height: 1)
            .linear(0.0, 0.2)
        
        let verticalKernel = try VIPSImage.black(width: 1, height: 5)
            .linear(0.0, 0.2)
        
        let hConvolved = try image.conv(mask: horizontalKernel)
        #expect(hConvolved.width == image.width)
        
        let vConvolved = try image.conv(mask: verticalKernel)
        #expect(vConvolved.width == image.width)
    }
    
    // MARK: - Enhanced Convolution Tests
    
    @Test
    func testCustomKernelTypes() throws {
        let testImage = try makeTestImage(width: 50, height: 50, value: 100.0)
        
        // Test identity kernel (should preserve image)
        let identity = try VIPSImage.black(width: 3, height: 3)
        let _ = try identity.getpoint(x: 1, y: 1)
        let identityKernel = try identity.linear(0.0, 0.0).insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, 1.0), x: 1, y: 1)
        
        let identityConv = try testImage.conv(mask: identityKernel)
        assertAlmostEqual(try identityConv.avg(), 100.0, threshold: 1.0)
        
        // Test edge detection kernels
        // Sobel X kernel: [-1, 0, 1; -2, 0, 2; -1, 0, 1]
        let sobelX = try VIPSImage.black(width: 3, height: 3)
        var sobelXData = try sobelX.linear(0.0, 0.0) // Start with zeros
        sobelXData = try sobelXData.insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, -1.0), x: 0, y: 0)
        sobelXData = try sobelXData.insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, 1.0), x: 2, y: 0)
        sobelXData = try sobelXData.insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, -2.0), x: 0, y: 1)
        sobelXData = try sobelXData.insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, 2.0), x: 2, y: 1)
        sobelXData = try sobelXData.insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, -1.0), x: 0, y: 2)
        sobelXData = try sobelXData.insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, 1.0), x: 2, y: 2)
        
        // Create gradient test image
        let gradient = try makeGradientImage(width: 50, height: 50)
        let edgeResult = try gradient.conv(mask: sobelXData)
        
        #expect(edgeResult.width == 50)
        #expect(edgeResult.height == 50)
        #expect(try edgeResult.max() > 0) // Should detect edges in gradient
    }
    
    @Test
    func testSeparableConvolutionVsRegular() throws {
        let testImage = try makeTestImage(width: 80, height: 80, value: 128.0)
        
        // Create a separable Gaussian-like kernel
        let sigma = 1.5
        let size = 7
        let center = size / 2
        
        // Create 1D Gaussian kernel
        let kernel1D = try VIPSImage.black(width: 1, height: size)
        var gaussianKernel = try kernel1D.linear(0.0, 0.0)
        
        var sum = 0.0
        for i in 0..<size {
            let x = Double(i - center)
            let value = exp(-(x * x) / (2.0 * sigma * sigma))
            gaussianKernel = try gaussianKernel.insert(sub: VIPSImage.black(width: 1, height: 1).linear(0.0, value), x: 0, y: i)
            sum += value
        }
        
        // Normalize the kernel
        gaussianKernel = try gaussianKernel.linear(1.0 / sum, 0.0)
        
        // Test separable convolution
        let sepResult = try testImage.convsep(mask: gaussianKernel)
        
        // Create equivalent 2D kernel for comparison
        let gauss2D = try VIPSImage.gaussmat(sigma: sigma, minAmpl: 0.01)
        let regularResult = try testImage.conv(mask: gauss2D)
        
        #expect(sepResult.width == testImage.width)
        #expect(sepResult.height == testImage.height)
        #expect(regularResult.width == testImage.width)
        
        // Results should be similar (but not identical due to implementation differences)
        assertAlmostEqual(try sepResult.avg(), try regularResult.avg(), threshold: 5.0)
    }
    
    @Test
    func testBlurParameterEffects() throws {
        let noisyImage = try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 50.0, mean: 128.0)
        let originalDeviation = try noisyImage.deviate()
        
        // Test different sigma values
        let blur1 = try noisyImage.gaussblur(sigma: 0.5)
        let blur2 = try noisyImage.gaussblur(sigma: 2.0)
        let blur3 = try noisyImage.gaussblur(sigma: 5.0)
        
        let dev1 = try blur1.deviate()
        let dev2 = try blur2.deviate()
        let dev3 = try blur3.deviate()
        
        // Higher sigma should result in more smoothing (lower deviation)
        #expect(dev1 > dev2)
        #expect(dev2 > dev3)
        #expect(dev3 < originalDeviation)
        
        // All blurred images should preserve the mean approximately
        assertAlmostEqual(try blur1.avg(), 128.0, threshold: 5.0)
        assertAlmostEqual(try blur2.avg(), 128.0, threshold: 5.0)
        assertAlmostEqual(try blur3.avg(), 128.0, threshold: 5.0)
    }
    
    @Test(.disabled())
    func testConvolutionBoundaryHandling() throws {
        // Create image with distinct regions to test boundary handling
        let testImage = try makeRegionTestImage(regionSize: 25)
        
        // Use a simple 3x3 averaging kernel
        let avgKernel = try VIPSImage.black(width: 3, height: 3).linear(0.0, 1.0/9.0)
        
        let convolved = try testImage.conv(mask: avgKernel)
        
        #expect(convolved.width == testImage.width)
        #expect(convolved.height == testImage.height)
        
        // Center of uniform regions should be unchanged
        let centerValue = try convolved.getpoint(x: 25, y: 25)[0]
        assertAlmostEqual(centerValue, 10.0, threshold: 0.1) // First region value
        
        // Boundary regions should show blending
        let boundaryValue = try convolved.getpoint(x: 25, y: 24)[0] // Just across boundary
        #expect(boundaryValue != 10.0) // Should be different due to mixing
        #expect(boundaryValue > 10.0 && boundaryValue < 20.0) // Should be between region values
    }
    
    
    @Test
    func testEdgeDetectionCharacteristics() throws {
        // Create test image with known edges
        let background = try VIPSImage.black(width: 100, height: 100)
        let square = try VIPSImage.black(width: 40, height: 40).linear(0.0, 255.0)
        let testImage = try background.insert(sub: square, x: 30, y: 30)
        
        // Test Sobel edge detection
        let sobelResult = try testImage.sobel()
        
        // Edge detection should produce higher values at edges
        let centerValue = try sobelResult.getpoint(x: 50, y: 50)[0] // Inside square
        let edgeValue = try sobelResult.getpoint(x: 30, y: 50)[0] // At left edge
        
        #expect(edgeValue > centerValue)
        #expect(edgeValue > 0)
        
        // Test Canny edge detection with different parameters
        let canny1 = try testImage.canny(sigma: 1.0)
        let canny2 = try testImage.canny(sigma: 2.0)
        
        #expect(canny1.width == testImage.width)
        #expect(canny2.width == testImage.width)
        
        // Different sigma should produce different results
        let diff = try (canny1 - canny2).abs().max()
        #expect(diff > 0) // Should be different
    }
    
    @Test
    func testSharpenEffectiveness() throws {
        // Create slightly blurred test image
        let original = try makeRegionTestImage(regionSize: 25).colourspace(space: .srgb)
        let blurred = try original.gaussblur(sigma: 2.0)
        
        // Apply sharpening
        let sharpened = try blurred.sharpen()
        let sharpenedStrong = try blurred.sharpen(sigma: 1.0, x1: 2.0, y2: 10.0, y3: 20.0)
        
        #expect(sharpened.width == blurred.width)
        #expect(sharpenedStrong.width == blurred.width)
        
        // Sharpened image should have higher variance than blurred
        let blurredDev = try blurred.deviate()
        let sharpenedDev = try sharpened.deviate()
        let sharpenedStrongDev = try sharpenedStrong.deviate()
        
        #expect(sharpenedDev >= blurredDev)
        #expect(sharpenedStrongDev >= sharpenedDev) // Stronger sharpening should increase variance more
    }
    
    @Test
    func testMultiBandConvolution() throws {
        // Test convolution with multi-band images
        let r = try makeTestImage(width: 50, height: 50, value: 100.0)
        let g = try makeTestImage(width: 50, height: 50, value: 150.0)  
        let b = try makeTestImage(width: 50, height: 50, value: 200.0)
        let rgb = try r.bandjoin([g, b])
        
        // Apply blur kernel
        let blurKernel = try VIPSImage.black(width: 5, height: 5).linear(0.0, 1.0/25.0)
        let blurredRGB = try rgb.conv(mask: blurKernel)
        
        #expect(blurredRGB.width == rgb.width)
        #expect(blurredRGB.height == rgb.height)
        #expect(blurredRGB.bands == 3)
        
        // Each band should preserve its average approximately
        let rBlurred = try blurredRGB.extractBand(0)
        let gBlurred = try blurredRGB.extractBand(1)
        let bBlurred = try blurredRGB.extractBand(2)
        
        assertAlmostEqual(try rBlurred.avg(), 100.0, threshold: 2.0)
        assertAlmostEqual(try gBlurred.avg(), 150.0, threshold: 2.0)
        assertAlmostEqual(try bBlurred.avg(), 200.0, threshold: 2.0)
    }
    
    @Test
    func testKernelNormalization() throws {
        let testImage = try makeTestImage(width: 40, height: 40, value: 50.0)
        
        // Test normalized vs unnormalized kernels
        let unnormalizedKernel = try VIPSImage.black(width: 3, height: 3).linear(0.0, 1.0) // Sum = 9
        let normalizedKernel = try unnormalizedKernel.linear(1.0/9.0, 0.0) // Sum = 1
        
        let unnormalizedResult = try testImage.conv(mask: unnormalizedKernel)
        let normalizedResult = try testImage.conv(mask: normalizedKernel)
        
        // Unnormalized should amplify the signal by the kernel sum
        assertAlmostEqual(try unnormalizedResult.avg(), 50.0 * 9.0, threshold: 5.0)
        assertAlmostEqual(try normalizedResult.avg(), 50.0, threshold: 1.0)
    }
    
    @Test 
    func testConvolutionWithDifferentFormats() throws {
        let baseImage = try makeTestImage(width: 30, height: 30, value: 100.0)
        let kernel = try VIPSImage.black(width: 3, height: 3).linear(0.0, 1.0/9.0).cast(.float)
        
        for format in nonComplexFormats {
            let typedImage = try baseImage.cast(format)
            let convolved = try typedImage.conv(mask: kernel)
            
            #expect(convolved.width == typedImage.width)
            #expect(convolved.height == typedImage.height)
            
            // Should preserve value approximately
            let formatName = String(describing: format)
            let expectedMax = maxValue[formatName] ?? 255.0
            let scaledValue = min(100.0, expectedMax)
            let tolerance = max(2.0, expectedMax * 0.02)
            
            assertAlmostEqual(try convolved.avg(), scaledValue, threshold: tolerance)
        }
    }
    
    @Test
    func testLargeKernelPerformance() throws {
        let testImage = try makeTestImage(width: 100, height: 100, value: 128.0)
        
        // Test with increasingly large kernels
        let sizes = [5, 9, 15, 21]
        
        for size in sizes {
            let kernel = try VIPSImage.black(width: size, height: size)
                .linear(0.0, 1.0 / Double(size * size))
            
            let result = try testImage.conv(mask: kernel)
            
            #expect(result.width == testImage.width)
            #expect(result.height == testImage.height)
            assertAlmostEqual(try result.avg(), 128.0, threshold: 2.0)
        }
    }
    
    @Test
    func testConvolutionMemoryConsistency() throws {
        // Test that repeated convolutions produce consistent results
        let testImage = try makeTestImage(width: 50, height: 50, value: 64.0)
        let kernel = try VIPSImage.black(width: 3, height: 3).linear(0.0, 1.0/9.0)
        
        let result1 = try testImage.conv(mask: kernel)
        let result2 = try testImage.conv(mask: kernel)
        let result3 = try testImage.conv(mask: kernel)
        
        // All results should be identical
        try assertImagesEqual(result1, result2, maxDiff: 0.001)
        try assertImagesEqual(result2, result3, maxDiff: 0.001)
        
        assertAlmostEqual(try result1.avg(), try result2.avg(), threshold: 0.001)
        assertAlmostEqual(try result2.avg(), try result3.avg(), threshold: 0.001)
    }
}