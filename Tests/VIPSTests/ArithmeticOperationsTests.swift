@testable import VIPS
import Cvips
import Testing
import Foundation

@Suite(.serialized)
struct ArithmeticOperationsTests {
    init() {
        try! VIPS.start()
    }
    
    // MARK: - Trigonometric Operations Tests
    
    @Test
    func testSin() throws {
        // Create a simple test image with known values
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(1.0, 0.0) // Create values [0, 0, 0, 0, 0, 0, 0, 0, 0]
            .linear(0.0, 90.0) // Create values [90, 90, 90, 90, 90, 90, 90, 90, 90]
        
        let result = try image.sin()
        
        // sin(90 degrees) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    @Test
    func testCos() throws {
        // Create a test image with 0 degrees
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.cos()
        
        // cos(0 degrees) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    @Test
    func testTan() throws {
        // Create a test image with 45 degrees
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 45.0)
        
        let result = try image.tan()
        
        // tan(45 degrees) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    // MARK: - Exponential and Logarithmic Operations Tests
    
    @Test
    func testExp() throws {
        // Create image with value 1
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        let result = try image.exp()
        
        // e^1 ≈ 2.71828
        let avg = try result.avg()
        #expect(abs(avg - 2.71828) < 0.01)
    }
    
    @Test
    func testLog() throws {
        // Create image with value e
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 2.71828)
        
        let result = try image.log()
        
        // ln(e) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    @Test
    func testLog10() throws {
        // Create image with value 100
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 100.0)
        
        let result = try image.log10()
        
        // log10(100) = 2.0
        let avg = try result.avg()
        #expect(abs(avg - 2.0) < 0.01)
    }
    
    // MARK: - Math2 Operations Tests
    
    @Test
    func testPowImage() throws {
        // Create base image with value 2
        let base = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 2.0)
        
        // Create exponent image with value 3
        let exponent = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
        
        let result = try base.pow(exponent)
        
        // 2^3 = 8
        let avg = try result.avg()
        #expect(abs(avg - 8.0) < 0.01)
    }
    
    @Test
    func testPowConstant() throws {
        // Create base image with value 3
        let base = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
        
        let result = try base.pow(2.0)
        
        // 3^2 = 9
        let avg = try result.avg()
        #expect(abs(avg - 9.0) < 0.01)
    }
    
    @Test
    func testAtan2() throws {
        // Create y image with value 1
        let y = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        // Create x image with value 1
        let x = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        let result = try y.atan2(x)
        
        // atan2(1, 1) = 45 degrees
        let avg = try result.avg()
        #expect(abs(avg - 45.0) < 0.01)
    }
    
    // MARK: - Bitwise Operations Tests
    
    @Test
    func testAndImage() throws {
        // Create image with value 12 (binary: 1100)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 12.0)
            .cast(.uchar)
        
        // Create image with value 10 (binary: 1010)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 10.0)
            .cast(.uchar)
        
        let result = try left.andimage(right)
        
        // 12 & 10 = 8 (binary: 1000)
        let avg = try result.avg()
        #expect(abs(avg - 8.0) < 0.01)
    }
    
    @Test
    func testAndImageOperator() throws {
        // Create image with value 15 (binary: 1111)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 15.0)
            .cast(.uchar)
        
        // Create image with value 7 (binary: 0111)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 7.0)
            .cast(.uchar)
        
        let result = try left & right
        
        // 15 & 7 = 7 (binary: 0111)
        let avg = try result.avg()
        #expect(abs(avg - 7.0) < 0.01)
    }
    
    @Test
    func testOrImage() throws {
        // Create image with value 12 (binary: 1100)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 12.0)
            .cast(.uchar)
        
        // Create image with value 10 (binary: 1010)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 10.0)
            .cast(.uchar)
        
        let result = try left.orimage(right)
        
        // 12 | 10 = 14 (binary: 1110)
        let avg = try result.avg()
        #expect(abs(avg - 14.0) < 0.01)
    }
    
    @Test
    func testOrImageOperator() throws {
        // Create image with value 8 (binary: 1000)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 8.0)
            .cast(.uchar)
        
        // Create image with value 4 (binary: 0100)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 4.0)
            .cast(.uchar)
        
        let result = try left | right
        
        // 8 | 4 = 12 (binary: 1100)
        let avg = try result.avg()
        #expect(abs(avg - 12.0) < 0.01)
    }
    
    @Test
    func testAndImageConst() throws {
        // Create image with value 15 (binary: 1111)
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 15.0)
            .cast(.uchar)
        
        let result = try image.andimage(3.0)
        
        // 15 & 3 = 3 (binary: 0011)
        let avg = try result.avg()
        #expect(abs(avg - 3.0) < 0.01)
    }
    
    @Test
    func testOrImageConst() throws {
        // Create image with value 8 (binary: 1000)
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 8.0)
            .cast(.uchar)
        
        let result = try image.orimage(3.0)
        
        // 8 | 3 = 11 (binary: 1011)
        let avg = try result.avg()
        #expect(abs(avg - 11.0) < 0.01)
    }
    
    // MARK: - Bit Shift Operations Tests
    
    @Test
    func testLShiftConst() throws {
        // Create image with value 3
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(.uchar)
        
        let result = try image.lshift(2)
        
        // 3 << 2 = 12
        let avg = try result.avg()
        #expect(abs(avg - 12.0) < 0.01)
    }
    
    @Test
    func testLShiftOperator() throws {
        // Create image with value 5
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 5.0)
            .cast(.uchar)
        
        let result = try image << 1
        
        // 5 << 1 = 10
        let avg = try result.avg()
        #expect(abs(avg - 10.0) < 0.01)
    }
    
    @Test
    func testRShiftConst() throws {
        // Create image with value 12
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 12.0)
            .cast(.uchar)
        
        let result = try image.rshift(2)
        
        // 12 >> 2 = 3
        let avg = try result.avg()
        #expect(abs(avg - 3.0) < 0.01)
    }
    
    @Test
    func testRShiftOperator() throws {
        // Create image with value 20
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 20.0)
            .cast(.uchar)
        
        let result = try image >> 2
        
        // 20 >> 2 = 5
        let avg = try result.avg()
        #expect(abs(avg - 5.0) < 0.01)
    }
    
    @Test
    func testLShiftImage() throws {
        // Create image with value 3
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(.uchar)
        
        // Create shift amount image with value 3
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(.uchar)
        
        let result = try left.lshift(right)
        
        // 3 << 3 = 24
        let avg = try result.avg()
        #expect(abs(avg - 24.0) < 0.01)
    }
    
    @Test
    func testRShiftImage() throws {
        // Create image with value 32
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 32.0)
            .cast(.uchar)
        
        // Create shift amount image with value 3
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(.uchar)
        
        let result = try left.rshift(right)
        
        // 32 >> 3 = 4
        let avg = try result.avg()
        #expect(abs(avg - 4.0) < 0.01)
    }
    
    // MARK: - Linear Operation Tests
    
    @Test
    func testLinearBasic() throws {
        // Create a test image with value 2
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 2.0)
        
        // Apply linear transform: out = in * 3 + 5
        let result = try image.linear(3.0, 5.0)
        
        // 2 * 3 + 5 = 11
        let avg = try result.avg()
        #expect(abs(avg - 11.0) < 0.01)
    }
    
    @Test
    func testLinearInteger() throws {
        // Create a test image with value 4
        let image = try VIPSImage.black(2, 2, bands: 1)
            .linear(0, 4)
        
        // Apply linear transform with integers: out = in * 2 + 3
        let result = try image.linear(2, 3)
        
        // 4 * 2 + 3 = 11
        let avg = try result.avg()
        #expect(abs(avg - 11.0) < 0.01)
    }
    
    @Test
    func testLinearArrays() throws {
        // Create a 3-band image with values [1, 2, 3]
        let r = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 1.0)
        let g = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 2.0)
        let b = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 3.0)
        let image = try r.bandjoin([g, b])
        
        // Apply different linear transforms per band
        let a = [2.0, 3.0, 4.0]  // multipliers
        let b_vals = [1.0, 2.0, 3.0]  // addends
        let result = try image.linear(a, b_vals)
        
        // Expected: [1*2+1, 2*3+2, 3*4+3] = [3, 8, 15]
        
        // Check each band average
        let band0 = try result.extractBand(0)
        let band1 = try result.extractBand(1)
        let band2 = try result.extractBand(2)
        
        #expect(abs(try band0.avg() - 3.0) < 0.01)
        #expect(abs(try band1.avg() - 8.0) < 0.01)
        #expect(abs(try band2.avg() - 15.0) < 0.01)
    }
    
    @Test
    func testLinearDefaults() throws {
        // Create a test image with value 5
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 5.0)
        
        // Apply linear with default parameters (a=1.0, b=0)
        let result = try image.linear(1.0, 0.0)
        
        // 5 * 1 + 0 = 5 (should be unchanged)
        let avg = try result.avg()
        #expect(abs(avg - 5.0) < 0.01)
    }
    
    @Test
    func testLinearMultiplyOnly() throws {
        // Create a test image with value 7
        let image = try VIPSImage.black(2, 2, bands: 1)
            .linear(0.0, 7.0)
        
        // Apply linear with only multiplication (b=0 by default)
        let result = try image.linear(0.5)
        
        // 7 * 0.5 + 0 = 3.5
        let avg = try result.avg()
        #expect(abs(avg - 3.5) < 0.01)
    }
    
    @Test
    func testLinearAddOnly() throws {
        // Create a test image with value 10
        let image = try VIPSImage.black(2, 2, bands: 1)
            .linear(0.0, 10.0)
        
        // Apply linear with only addition (a=1.0 by default)
        let result = try image.linear(1.0, -3.0)
        
        // 10 * 1 + (-3) = 7
        let avg = try result.avg()
        #expect(abs(avg - 7.0) < 0.01)
    }
    
    @Test
    func testLinearUchar() throws {
        // Create a test image that would overflow uchar without the uchar parameter
        let image = try VIPSImage.black(2, 2, bands: 1)
            .linear(0.0, 100.0)
        
        // Apply linear transform that would create value > 255
        let result = try image.linear(3.0, 0.0, uchar: true)
        
        // 100 * 3 = 300, but should be clamped to 255 with uchar: true
        let max = try result.max()
        #expect(max <= 255.0)
        
        // Verify the type is actually uchar
        let format = result.format
        #expect(format == .uchar)
    }
    
    // MARK: - Inverse Trigonometric Operations Tests
    
    @Test
    func testAsin() throws {
        // Create a test image with value 1.0
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        let result = try image.asin()
        
        // asin(1.0) = 90 degrees
        let avg = try result.avg()
        #expect(abs(avg - 90.0) < 0.01)
    }
    
    @Test
    func testAcos() throws {
        // Create a test image with value 0.0
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.acos()
        
        // acos(0.0) = 90 degrees
        let avg = try result.avg()
        #expect(abs(avg - 90.0) < 0.01)
    }
    
    @Test
    func testAtan() throws {
        // Create a test image with value 1.0
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        let result = try image.atan()
        
        // atan(1.0) = 45 degrees
        let avg = try result.avg()
        #expect(abs(avg - 45.0) < 0.01)
    }
    
    // MARK: - Hyperbolic Functions Tests
    
    @Test
    func testSinh() throws {
        // Create a test image with value 0
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.sinh()
        
        // sinh(0) = 0
        let avg = try result.avg()
        #expect(abs(avg) < 0.01)
    }
    
    @Test
    func testCosh() throws {
        // Create a test image with value 0
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.cosh()
        
        // cosh(0) = 1
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    @Test
    func testTanh() throws {
        // Create a test image with value 0
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.tanh()
        
        // tanh(0) = 0
        let avg = try result.avg()
        #expect(abs(avg) < 0.01)
    }
    
    // MARK: - Inverse Hyperbolic Functions Tests
    
    @Test
    func testAsinh() throws {
        // Create a test image with value 0
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.asinh()
        
        // asinh(0) = 0
        let avg = try result.avg()
        #expect(abs(avg) < 0.01)
    }
    
    @Test
    func testAcosh() throws {
        // Create a test image with value 1.0
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        let result = try image.acosh()
        
        // acosh(1) = 0
        let avg = try result.avg()
        #expect(abs(avg) < 0.01)
    }
    
    @Test
    func testAtanh() throws {
        // Create a test image with value 0
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.atanh()
        
        // atanh(0) = 0
        let avg = try result.avg()
        #expect(abs(avg) < 0.01)
    }
    
    // MARK: - Additional Exponential Operations Tests
    
    @Test
    func testExp10() throws {
        // Create a test image with value 2
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 2.0)
        
        let result = try image.exp10()
        
        // 10^2 = 100
        let avg = try result.avg()
        #expect(abs(avg - 100.0) < 0.01)
    }
    
    // MARK: - Math2 Operations Tests
    
    @Test
    func testWopImage() throws {
        // Create exponent image with value 2
        let exponent = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 2.0)
        
        // Create base image with value 3
        let base = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
        
        let result = try exponent.wop(base)
        
        // 3^2 = 9 (wop swaps the arguments)
        let avg = try result.avg()
        #expect(abs(avg - 9.0) < 0.01)
    }
    
    @Test
    func testWopConst() throws {
        // Create exponent image with value 3
        let exponent = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
        
        let result = try exponent.wop(2.0)
        
        // 2^3 = 8
        let avg = try result.avg()
        #expect(abs(avg - 8.0) < 0.01)
    }
    
    @Test
    func testRemainderImage() throws {
        // Create dividend image with value 13
        let dividend = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 13.0)
        
        // Create divisor image with value 5
        let divisor = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 5.0)
        
        let result = try dividend.remainder(divisor)
        
        // 13 % 5 = 3
        let avg = try result.avg()
        #expect(abs(avg - 3.0) < 0.01)
    }
    
    @Test
    func testRemainderConst() throws {
        // Create dividend image with value 17
        let dividend = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 17.0)
        
        let result = try dividend.remainder(7.0)
        
        // 17 % 7 = 3
        let avg = try result.avg()
        #expect(abs(avg - 3.0) < 0.01)
    }
    
    @Test
    func testRemainderConstInt() throws {
        // Create dividend image with value 20
        let dividend = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 20.0)
        
        let result = try dividend.remainder(6)
        
        // 20 % 6 = 2
        let avg = try result.avg()
        #expect(abs(avg - 2.0) < 0.01)
    }
    
    // MARK: - Bitwise XOR Operations Tests
    
    @Test
    func testEorImage() throws {
        // Create image with value 12 (binary: 1100)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 12.0)
            .cast(.uchar)
        
        // Create image with value 5 (binary: 0101)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 5.0)
            .cast(.uchar)
        
        let result = try left.eorimage(right)
        
        // 12 ^ 5 = 9 (binary: 1001)
        let avg = try result.avg()
        #expect(abs(avg - 9.0) < 0.01)
    }
    
    @Test
    func testEorImageConst() throws {
        // Create image with value 15 (binary: 1111)
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 15.0)
            .cast(.uchar)
        
        let result = try image.eorimage(10.0)
        
        // 15 ^ 10 = 5 (binary: 0101)
        let avg = try result.avg()
        #expect(abs(avg - 5.0) < 0.01)
    }
    
    @Test
    func testXorOperator() throws {
        // Create image with value 7 (binary: 0111)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 7.0)
            .cast(.uchar)
        
        // Create image with value 3 (binary: 0011)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(.uchar)
        
        let result = try left ^ right
        
        // 7 ^ 3 = 4 (binary: 0100)
        let avg = try result.avg()
        #expect(abs(avg - 4.0) < 0.01)
    }
}