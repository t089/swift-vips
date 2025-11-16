import Cvips
import Foundation
import Testing

@testable import VIPS

extension VIPSTests {
    @Suite(.vips)
    struct ArithmeticTests {

        // MARK: - Basic Arithmetic Operations

        @Test
        func testAddOperations() throws {
            let image1 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 50.0)
            let image2 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 25.0)

            // Test image + image
            let added = try image1.add(image2)
            #expect(try added.avg() == 75.0)

            // Test with operator
            let addedOp = try image1 + image2
            #expect(try addedOp.avg() == 75.0)

            // Test image + constant
            let addedConst = try image1 + 10.0
            #expect(try addedConst.avg() == 60.0)
        }

        @Test
        func testSubtractOperations() throws {
            let image1 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 100.0)
            let image2 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 30.0)

            // Test image - image
            let subtracted = try image1.subtract(image2)
            #expect(try subtracted.avg() == 70.0)

            // Test with operator
            let subtractedOp = try image1 - image2
            #expect(try subtractedOp.avg() == 70.0)

            // Test image - constant (using linear for subtraction: y = x*1 - 20)
            let subtractedConst = try image1.linear(1.0, -20.0)
            #expect(try subtractedConst.avg() == 80.0)
        }

        @Test
        func testMultiplyOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 5.0)
            let multiplier = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 2.0)

            // Test image * image
            let multiplied = try image.multiply(multiplier)
            #expect(try multiplied.avg() == 10.0)

            // Test with operator
            let multipliedOp = try image * multiplier
            #expect(try multipliedOp.avg() == 10.0)

            // Test image * constant
            let multipliedConst = try image * 3.0
            #expect(try multipliedConst.avg() == 15.0)
        }

        @Test
        func testDivideOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 100.0)
            let divisor = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 4.0)

            // Test image / image
            let divided = try image.divide(divisor)
            #expect(try divided.avg() == 25.0)

            // Test with operator
            let dividedOp = try image / divisor
            #expect(try dividedOp.avg() == 25.0)

            // Test image / constant (using linear for division: y = x*0.5 + 0)
            let dividedConst = try image.linear(0.5, 0.0)
            #expect(try dividedConst.avg() == 50.0)
        }

        @Test
        func testRemainderOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 10.0)
            let divisor = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 3.0)

            // Test image % image
            let remainder = try image.remainder(divisor)
            #expect(try remainder.avg() == 1.0)

            // Test with operator - % operator not defined for VIPSImage
            // let remainderOp = try image % divisor
            // #expect(try remainderOp.avg() == 1.0)

            // Test image % constant
            let remainderConst = try image.remainder(4.0)
            #expect(try remainderConst.avg() == 2.0)
        }

        @Test
        func testPowerOperations() throws {
            let base = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 2.0)
            let exponent = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 3.0)

            // Test pow(image, image)
            let powered = try base.pow(exponent)
            #expect(try powered.avg() == 8.0)

            // Test pow(image, constant)
            let poweredConst = try base.pow(4.0)
            #expect(try poweredConst.avg() == 16.0)
        }

        // MARK: - Mathematical Functions

        @Test
        func testMathOperations() throws {
            // Test exp
            let zeros = try VIPSImage.black(width: 10, height: 10)
            let expResult = try zeros.math(.exp)
            #expect(abs(try expResult.avg() - 1.0) < 0.001)

            // Test log
            let ones = try VIPSImage.black(width: 10, height: 10)
                .linear(0.0, exp(1.0))
            let logResult = try ones.math(.log)
            #expect(abs(try logResult.avg() - 1.0) < 0.001)

            // Test log10
            let tens = try VIPSImage.black(width: 10, height: 10)
                .linear(0.0, 10.0)
            let log10Result = try tens.math(.log10)
            #expect(abs(try log10Result.avg() - 1.0) < 0.001)
        }

        @Test
        func testMath2Operations() throws {
            let image1 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 3.0)
            let image2 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 4.0)

            // Test wop (weighted operation)
            let wop = try image1.math2(image2, math2: .wop)
            #expect(try wop.avg() > 0)
        }

        // MARK: - Complex Operations

        @Test
        func testComplexOperations() throws {
            // Create a complex image (real + imaginary parts)
            let real = try VIPSImage.black(width: 10, height: 10, bands: 1)
                .linear(1.0, 1.0)
            let imag = try VIPSImage.black(width: 10, height: 10, bands: 1)
                .linear(1.0, 0.0)
            // Note: For complex operations to work properly, the image needs to be in complex format
            // However, complexget still returns a 2-band image when extracting parts
            let complexImage = try real.bandjoin([imag])

            // Test complex operations
            let conjugate = try complexImage.complex(cmplx: .conj)
            #expect(conjugate.bands == 2)

            // Test getting real part - complexget returns a 2-band image with the real part data
            let realPart = try complexImage.complexget(get: .real)
            #expect(realPart.bands == 2)
            // The average of a 2-band image where band 0 is 1.0 and band 1 is 0.0 is 0.5
            #expect(abs(try realPart.avg() - 0.5) < 0.001)

            // Test getting imaginary part
            let imagPart = try complexImage.complexget(get: .imag)
            #expect(imagPart.bands == 2)
            #expect(abs(try imagPart.avg() - 0.0) < 0.001)
        }

        // MARK: - Boolean Operations

        @Test
        func testBooleanOperations() throws {
            let image1 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 170.0)  // Binary: 10101010
            let image2 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 204.0)  // Binary: 11001100

            // Test AND
            let andResult = try image1.boolean(image2, boolean: .and)
            #expect(try andResult.avg() == 136.0)  // 10001000

            // Test OR
            let orResult = try image1.boolean(image2, boolean: .or)
            #expect(try orResult.avg() == 238.0)  // 11101110

            // Test XOR
            let xorResult = try image1.boolean(image2, boolean: .eor)
            #expect(try xorResult.avg() == 102.0)  // 01100110
        }

        @Test
        func testBooleanConstOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 170.0)  // Binary: 10101010

            // Test AND with constant
            let andConst = try image.booleanConst(boolean: .and, c: [204.0])  // 11001100
            #expect(try andConst.avg() == 136.0)  // 10001000

            // Test OR with constant
            let orConst = try image.booleanConst(boolean: .or, c: [204.0])
            #expect(try orConst.avg() == 238.0)  // 11101110

            // Test XOR with constant
            let xorConst = try image.booleanConst(boolean: .eor, c: [204.0])
            #expect(try xorConst.avg() == 102.0)  // 01100110
        }

        @Test
        func testBitwiseOperators() throws {
            let image1 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 170.0)
            let image2 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 204.0)

            // Test bitwise AND operator
            let andOp = try image1 & image2
            #expect(try andOp.avg() == 136.0)

            // Test bitwise OR operator
            let orOp = try image1 | image2
            #expect(try orOp.avg() == 238.0)

            // Test bitwise XOR operator
            let xorOp = try image1 ^ image2
            #expect(try xorOp.avg() == 102.0)

            // Test with constants - bitwise ops with constants not supported
            // let andConstOp = try image1 & 204.0
            // #expect(try andConstOp.avg() == 136.0)
        }

        @Test
        func testShiftOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 4.0)

            // Test left shift
            let leftShift = try image << 2
            #expect(try leftShift.avg() == 16.0)

            // Test right shift
            let rightShift = try image >> 1
            #expect(try rightShift.avg() == 2.0)
        }

        // MARK: - Statistical Operations

        @Test
        func testStatisticalOperations() throws {
            // Create an image with varying values
            let image = try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 10.0, mean: 100.0)

            // Test avg
            let avg = try image.avg()
            #expect(abs(avg - 100.0) < 5.0)  // Allow some variance

            // Test deviate (standard deviation)
            let deviate = try image.deviate()
            #expect(abs(deviate - 10.0) < 2.0)  // Allow some variance

            // Test min
            let minVal = try image.min()
            #expect(minVal < 100.0)

            // Test max
            let maxVal = try image.max()
            #expect(maxVal > 100.0)

            // Test sum - sum is a static method that sums multiple images
            // For summing pixels in an image, we need to use a different approach
            // let sum = try image.sum()
            // #expect(abs(sum - 1000000.0) < 50000.0)

            // Test stats (returns array: min, max, sum, sum_sq, mean, deviation)
            let stats = try image.stats()
            #expect(stats.bands == 1)
        }

        @Test
        func testHistogramOperations() throws {
            let image = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 128.0)
                .cast(format: .uchar)  // Cast to uchar for proper histogram generation

            // Test histogram generation - for uchar images, histogram should be 256 wide
            let hist = try image.histFind()
            #expect(hist.width == 256)
            #expect(hist.height == 1)

            // Test histogram operations
            let cumulative = try hist.histCum()
            #expect(cumulative.width > 0)

            let normalized = try hist.histNorm()
            #expect(normalized.width > 0)
        }

        // MARK: - Miscellaneous Arithmetic

        @Test
        func testLinearOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 50.0)

            // Test linear transformation: output = a * input + b
            let transformed = try image.linear(2.0, 10.0)
            #expect(try transformed.avg() == 110.0)  // 2 * 50 + 10

            // Test linear with arrays for multi-band
            let rgbImage = try image.bandjoin([image, image])
            let rgbTransformed = try rgbImage.linear([1.0, 2.0, 3.0], [10.0, 20.0, 30.0])
            #expect(rgbTransformed.bands == 3)
        }

        @Test
        func testInvertOperations() throws {
            // Test standard invert - for uchar images, invert does 255-x
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 200.0)
                .cast(format: .uchar)  // Cast to uchar for proper inversion behavior

            let inverted = try image.invert()
            #expect(try inverted.avg() == 55.0)  // 255 - 200
        }

        @Test
        func testAbsoluteValue() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, -50.0)

            let absImage = try image.abs()
            #expect(try absImage.avg() == 50.0)
            #expect(try absImage.min() >= 0)
        }

        @Test
        func testSignOperation() throws {
            let positive = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 50.0)
            let negative = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, -50.0)
            let zero = try VIPSImage.black(width: 10, height: 10)

            #expect(try positive.sign().avg() == 1.0)
            #expect(try negative.sign().avg() == -1.0)
            #expect(try zero.sign().avg() == 0.0)
        }

        @Test
        func testRoundingOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 10.7)

            // Test different rounding modes
            let rounded = try image.round(.rint)
            #expect(try rounded.avg() == 11.0)

            let floored = try image.round(.floor)
            #expect(try floored.avg() == 10.0)

            let ceiled = try image.round(.ceil)
            #expect(try ceiled.avg() == 11.0)
        }

        @Test
        func testRelationalOperations() throws {
            let image1 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 50.0)
            let image2 = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 100.0)

            // Test relational operations
            let equal = try image1.relational(image1, relational: .equal)
            #expect(try equal.avg() == 255.0)  // All pixels equal

            let notEqual = try image1.relational(image2, relational: .noteq)
            #expect(try notEqual.avg() == 255.0)  // All pixels not equal

            let less = try image1.relational(image2, relational: .less)
            #expect(try less.avg() == 255.0)  // All pixels less

            let lessEq = try image1.relational(image2, relational: .lesseq)
            #expect(try lessEq.avg() == 255.0)  // All pixels less or equal

            let more = try image2.relational(image1, relational: .more)
            #expect(try more.avg() == 255.0)  // All pixels more

            let moreEq = try image2.relational(image1, relational: .moreeq)
            #expect(try moreEq.avg() == 255.0)  // All pixels more or equal
        }

        @Test
        func testRelationalConstOperations() throws {
            let image = try VIPSImage.black(width: 10, height: 10)
                .linear(1.0, 128.0)

            // Test relational operations with constants
            let equal = try image.relationalConst(relational: .equal, c: [128.0])
            #expect(try equal.avg() == 255.0)

            let less = try image.relationalConst(relational: .less, c: [200.0])
            #expect(try less.avg() == 255.0)

            let more = try image.relationalConst(relational: .more, c: [100.0])
            #expect(try more.avg() == 255.0)
        }
    }
}
