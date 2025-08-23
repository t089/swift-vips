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
        let kernel = try VIPSImage.black(width: 3, height: 3)
            .linear(0.0, 1.0 / 9.0)
        
        // Test basic convolution
        let convolved = try image.conv(mask: kernel)
        #expect(convolved.width == image.width)
        #expect(convolved.height == image.height)
        #expect(abs(try convolved.avg() - 128.0) < 1.0)
        
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
}