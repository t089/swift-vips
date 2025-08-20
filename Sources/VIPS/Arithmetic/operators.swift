//
//  File.swift
//  
//
//  Created by Tobias Haeberle on 29.10.21.
//

import Cvips

extension VIPSImage {
    /// Pass an image through a linear transform, ie. (out = in * a + b). Output is float 
    /// for integer input, double for double input, complex for complex input and double 
    /// complex for double complex input. Set uchar to output uchar pixels.
    /// 
    /// If the arrays of constants have just one element, that constant is used for all image 
    /// bands. If the arrays have more than one element and they have the same number of elements 
    /// as there are bands in the image, then one array element is used for each band. If the 
    /// arrays have more than one element and the image only has a single band, the result is 
    /// a many-band image where each band corresponds to one array element.
    public func linear(_ a: Double = 1.0, _ b: Double = 0, uchar: Bool? = nil) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("a", value: [ a ])
            opt.set("b", value: [ b ])
            opt.set("out", value: &out)
            if let uchar = uchar {
                opt.set("uchar", value: uchar)
            }

            try VIPSImage.call("linear", options: &opt)
        }
    }
    
    public func linear(_ a: Int = 1, _ b: Int = 0, uchar: Bool? = nil) throws -> VIPSImage {
        return try linear(Double(a), Double(b), uchar: uchar)
    }

    public func linear(_ a: [Double], _ b: [Double], uchar: Bool? = nil) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("a", value: a)
            opt.set("b", value: b)
            opt.set("out", value: &out)
            if let uchar = uchar {
                opt.set("uchar", value: uchar)
            }

            try VIPSImage.call("linear", options: &opt)
        }
    }
    
    public func subtract(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("subtract", options: &opt)
        }
    }
    
    public func add(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("add", options: &opt)
        }
    }
    
    public func multiply(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("multiply", options: &opt)
        }
    }
    
    /// Divide two images.
    ///
    /// This operation calculates `left / right` and writes the result to a new image.
    /// If any pixels in the divisor are zero, the corresponding pixel in the output is also zero.
    ///
    /// If the images differ in size, the smaller image is enlarged to match the larger by adding
    /// zero pixels along the bottom and right.
    ///
    /// If the number of bands differs, one of the images must have one band. In this case,
    /// an n-band image is formed from the one-band image by joining n copies together,
    /// and then the two n-band images are operated upon.
    ///
    /// The output type is promoted to at least float to hold the whole range of possible values:
    /// - uchar, char, ushort, short, uint, int → float
    /// - float → float
    /// - double → double
    /// - complex → complex
    /// - double complex → double complex
    ///
    /// - Parameter rhs: The divisor image
    /// - Returns: A new image with each pixel being the quotient of the corresponding pixels
    /// - Throws: `VIPSError` if the operation fails
    public func divide(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("divide", options: &opt)
        }
    }
    
    public func max() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("max", options: &opt)
        
        return out
    }
    
    public func min() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("min", options: &opt)
        
        return out
    }
    
    public func avg() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("avg", options: &opt)
        
        return out
    }

    public func deviate() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("deviate", options: &opt)
        
        return out
    }
    
    /// Calculate the absolute value of an image.
    ///
    /// This operation finds the absolute value of each pixel in the input image.
    /// For unsigned integer formats, this operation returns the input unchanged.
    /// For signed integer and float formats, negative values are negated.
    /// For complex images, this returns the modulus (magnitude).
    ///
    /// The output format is the same as the input format for non-complex images.
    /// Complex images are converted to the corresponding real format.
    ///
    /// - Returns: A new image with the absolute value of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func abs() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("abs", options: &opt)
        }
    }
    
    /// Calculate the unit vector in the direction of the pixel value.
    ///
    /// This operation finds the unit vector in the direction of each pixel value.
    /// For non-complex images, this returns:
    /// - `-1` for negative values
    /// - `0` for zero values
    /// - `1` for positive values
    ///
    /// For complex images, this returns a complex number with modulus 1 and the same
    /// argument as the input, or (0, 0) for zero input.
    ///
    /// - Returns: A new image with the sign of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func sign() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("sign", options: &opt)
        }
    }
    
    /// Perform a rounding operation on an image.
    ///
    /// This operation rounds each pixel value according to the specified rounding mode.
    /// The operation does not change the image format.
    ///
    /// - Parameter round: The rounding mode to use (default: `.rint`)
    ///   - `.rint`: Round to nearest integer using round-to-even
    ///   - `.floor`: Round down (towards negative infinity)
    ///   - `.ceil`: Round up (towards positive infinity)
    ///   - `.round`: Round to nearest integer, ties away from zero
    /// - Returns: A new image with rounded pixel values
    /// - Throws: `VIPSError` if the operation fails
    public func round(_ round: VipsOperationRound = .rint) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("round", value: round)
            opt.set("out", value: &out)
            
            try VIPSImage.call("round", options: &opt)
        }
    }
    
    /// Round an image down.
    ///
    /// This operation rounds each pixel value down towards negative infinity.
    /// For example: 2.7 → 2.0, -2.7 → -3.0
    ///
    /// - Returns: A new image with all pixel values rounded down
    /// - Throws: `VIPSError` if the operation fails
    public func floor() throws -> VIPSImage {
        return try self.round(.floor)
    }
    
    /// Round an image up.
    ///
    /// This operation rounds each pixel value up towards positive infinity.
    /// For example: 2.3 → 3.0, -2.3 → -2.0
    ///
    /// - Returns: A new image with all pixel values rounded up
    /// - Throws: `VIPSError` if the operation fails
    public func ceil() throws -> VIPSImage {
        return try self.round(.ceil)
    }
    
    /// Round an image to the nearest integer.
    ///
    /// This operation rounds each pixel value to the nearest integer using round-to-even
    /// (banker's rounding). When a value is exactly halfway between two integers,
    /// it rounds to the nearest even integer.
    /// For example: 2.5 → 2.0, 3.5 → 4.0
    ///
    /// - Returns: A new image with all pixel values rounded to nearest integer
    /// - Throws: `VIPSError` if the operation fails
    public func rint() throws -> VIPSImage {
        return try self.round(.rint)
    }
    
    /// Perform a relational comparison between two images.
    ///
    /// This operation compares corresponding pixels from two images using the specified
    /// relational operator. The result is a uchar image where 255 represents true
    /// and 0 represents false.
    ///
    /// If the images differ in size, the smaller image is enlarged to match the
    /// larger by adding zero pixels along the bottom and right.
    ///
    /// If the number of bands differs, one of the images must have one band.
    /// In this case, an n-band image is formed from the one-band image by joining
    /// n copies together.
    ///
    /// - Parameters:
    ///   - right: The right-hand side image for comparison
    ///   - relational: The comparison operation to perform
    /// - Returns: A new uchar image with 255 for true pixels, 0 for false pixels
    /// - Throws: `VIPSError` if the operation fails
    public func relational(_ right: VIPSImage, _ relational: VipsOperationRelational) throws -> VIPSImage {
        return try VIPSImage([self, right]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: right.image)
            opt.set("relational", value: relational)
            opt.set("out", value: &out)
            
            try VIPSImage.call("relational", options: &opt)
        }
    }
    
    /// Perform a relational comparison between an image and a constant.
    ///
    /// This operation compares each pixel in the image with a constant value or array of values.
    /// The result is a uchar image where 255 represents true and 0 represents false.
    ///
    /// If a single constant is provided, it is compared with all bands.
    /// If an array is provided, constants are applied to corresponding bands.
    ///
    /// - Parameters:
    ///   - relational: The comparison operation to perform
    ///   - c: An array of constants to compare against
    /// - Returns: A new uchar image with 255 for true pixels, 0 for false pixels
    /// - Throws: `VIPSError` if the operation fails
    public func relational(_ relational: VipsOperationRelational, _ c: [Double]) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("relational", value: relational)
            opt.set("c", value: c)
            opt.set("out", value: &out)
            
            try VIPSImage.call("relational_const", options: &opt)
        }
    }
    
    /// Perform a relational comparison between an image and a single constant.
    ///
    /// This is a convenience method that compares all pixels in the image with a single constant value.
    ///
    /// - Parameters:
    ///   - relational: The comparison operation to perform
    ///   - c: A constant value to compare against
    /// - Returns: A new uchar image with 255 for true pixels, 0 for false pixels
    /// - Throws: `VIPSError` if the operation fails
    public func relational(_ relational: VipsOperationRelational, _ c: Double) throws -> VIPSImage {
        return try self.relational(relational, [c])
    }
    
    /// Test equality of two images.
    ///
    /// Compares corresponding pixels from two images for equality.
    /// The result is 255 where pixels are equal, 0 where they differ.
    ///
    /// - Parameter right: The image to compare with
    /// - Returns: A uchar image with 255 for equal pixels, 0 for unequal pixels
    /// - Throws: `VIPSError` if the images cannot be compared
    public func equal(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .equal)
    }
    
    /// Test inequality of two images.
    ///
    /// Compares corresponding pixels from two images for inequality.
    /// The result is 255 where pixels differ, 0 where they are equal.
    ///
    /// - Parameter right: The image to compare with
    /// - Returns: A uchar image with 255 for unequal pixels, 0 for equal pixels
    /// - Throws: `VIPSError` if the images cannot be compared
    public func notequal(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .noteq)
    }
    
    /// Test if one image is less than another.
    ///
    /// Performs pixel-wise less-than comparison between two images.
    /// The result is 255 where left < right, 0 otherwise.
    ///
    /// - Parameter right: The image to compare with
    /// - Returns: A uchar image with 255 where left < right, 0 otherwise
    /// - Throws: `VIPSError` if the images cannot be compared
    public func less(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .less)
    }
    
    /// Test if one image is less than or equal to another.
    ///
    /// Performs pixel-wise less-than-or-equal comparison between two images.
    /// The result is 255 where left <= right, 0 otherwise.
    ///
    /// - Parameter right: The image to compare with
    /// - Returns: A uchar image with 255 where left <= right, 0 otherwise
    /// - Throws: `VIPSError` if the images cannot be compared
    public func lesseq(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .lesseq)
    }
    
    /// Test if one image is greater than another.
    ///
    /// Performs pixel-wise greater-than comparison between two images.
    /// The result is 255 where left > right, 0 otherwise.
    ///
    /// - Parameter right: The image to compare with
    /// - Returns: A uchar image with 255 where left > right, 0 otherwise
    /// - Throws: `VIPSError` if the images cannot be compared
    public func more(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .more)
    }
    
    /// Test if one image is greater than or equal to another.
    ///
    /// Performs pixel-wise greater-than-or-equal comparison between two images.
    /// The result is 255 where left >= right, 0 otherwise.
    ///
    /// - Parameter right: The image to compare with
    /// - Returns: A uchar image with 255 where left >= right, 0 otherwise
    /// - Throws: `VIPSError` if the images cannot be compared
    public func moreeq(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .moreeq)
    }
    
    /// Test if image pixels equal a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel == constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 for equal pixels, 0 for unequal pixels
    /// - Throws: `VIPSError` if the operation fails
    public func equal(_ c: Double) throws -> VIPSImage {
        return try self.relational(.equal, c)
    }
    
    /// Test if image pixels are not equal to a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel != constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 for unequal pixels, 0 for equal pixels
    /// - Throws: `VIPSError` if the operation fails
    public func notequal(_ c: Double) throws -> VIPSImage {
        return try self.relational(.noteq, c)
    }
    
    /// Test if image pixels are less than a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel < constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel < constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func less(_ c: Double) throws -> VIPSImage {
        return try self.relational(.less, c)
    }
    
    /// Test if image pixels are less than or equal to a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel <= constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel <= constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func lesseq(_ c: Double) throws -> VIPSImage {
        return try self.relational(.lesseq, c)
    }
    
    /// Test if image pixels are greater than a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel > constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel > constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func more(_ c: Double) throws -> VIPSImage {
        return try self.relational(.more, c)
    }
    
    /// Test if image pixels are greater than or equal to a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel >= constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel >= constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func moreeq(_ c: Double) throws -> VIPSImage {
        return try self.relational(.moreeq, c)
    }
    
    // MARK: - Trigonometric Operations
    
    /// Calculate sine of an image.
    ///
    /// Perform pixel-wise sine operation, where each pixel is treated as an angle in degrees.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the sine of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func sin() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.sin)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate cosine of an image.
    ///
    /// Perform pixel-wise cosine operation, where each pixel is treated as an angle in degrees.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the cosine of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func cos() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.cos)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate tangent of an image.
    ///
    /// Perform pixel-wise tangent operation, where each pixel is treated as an angle in degrees.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the tangent of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func tan() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.tan)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate arcsine of an image.
    ///
    /// Perform pixel-wise arcsine operation. Input values should be in the range [-1, 1].
    /// The result is the angle in degrees whose sine is the input value.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the arcsine of each pixel in degrees
    /// - Throws: `VIPSError` if the operation fails
    public func asin() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.asin)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate arccosine of an image.
    ///
    /// Perform pixel-wise arccosine operation. Input values should be in the range [-1, 1].
    /// The result is the angle in degrees whose cosine is the input value.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the arccosine of each pixel in degrees
    /// - Throws: `VIPSError` if the operation fails
    public func acos() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.acos)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate arctangent of an image.
    ///
    /// Perform pixel-wise arctangent operation.
    /// The result is the angle in degrees whose tangent is the input value.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the arctangent of each pixel in degrees
    /// - Throws: `VIPSError` if the operation fails
    public func atan() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.atan)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    // MARK: - Hyperbolic Functions
    
    /// Calculate hyperbolic sine of an image.
    ///
    /// Perform pixel-wise hyperbolic sine operation.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the hyperbolic sine of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func sinh() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.sinh)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate hyperbolic cosine of an image.
    ///
    /// Perform pixel-wise hyperbolic cosine operation.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the hyperbolic cosine of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func cosh() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.cosh)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate hyperbolic tangent of an image.
    ///
    /// Perform pixel-wise hyperbolic tangent operation.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the hyperbolic tangent of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func tanh() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.tanh)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate inverse hyperbolic sine of an image.
    ///
    /// Perform pixel-wise inverse hyperbolic sine operation.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the inverse hyperbolic sine of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func asinh() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.asinh)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate inverse hyperbolic cosine of an image.
    ///
    /// Perform pixel-wise inverse hyperbolic cosine operation.
    /// Input values should be >= 1 for real results.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the inverse hyperbolic cosine of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func acosh() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.acosh)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate inverse hyperbolic tangent of an image.
    ///
    /// Perform pixel-wise inverse hyperbolic tangent operation.
    /// Input values should be in the range (-1, 1) for real results.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the inverse hyperbolic tangent of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func atanh() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.atanh)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    // MARK: - Exponential and Logarithmic Operations
    
    /// Calculate e^x for each pixel.
    ///
    /// Perform pixel-wise exponential operation, calculating e raised to the power of each pixel value.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with e^x for each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func exp() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.exp)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate natural logarithm of an image.
    ///
    /// Perform pixel-wise natural logarithm (base e). 
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the natural logarithm of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func log() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.log)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate base-10 logarithm of an image.
    ///
    /// Perform pixel-wise base-10 logarithm.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with the base-10 logarithm of each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func log10() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.log10)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    /// Calculate 10^x for each pixel.
    ///
    /// Perform pixel-wise base-10 exponential operation, calculating 10 raised to the power of each pixel value.
    /// Non-complex images are cast to float before the operation. Complex images are not supported.
    ///
    /// - Returns: A new image with 10^x for each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func exp10() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("math", value: VipsOperationMath.exp10)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math", options: &opt)
        }
    }
    
    // MARK: - Math2 Operations (Two arguments)
    
    /// Raise an image to a power of another image.
    ///
    /// This operation calculates left^right pixel-wise and writes the result to a new image.
    /// If the images differ in size, the smaller image is enlarged to match the larger.
    /// Non-complex images are cast to float before the operation.
    ///
    /// - Parameter exponent: The exponent image
    /// - Returns: A new image with each pixel being base^exponent
    /// - Throws: `VIPSError` if the operation fails
    public func pow(_ exponent: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, exponent]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: exponent.image)
            opt.set("math2", value: VipsOperationMath2.pow)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math2", options: &opt)
        }
    }
    
    /// Raise an image to a constant power.
    ///
    /// This operation calculates pixel^exponent for each pixel and writes the result to a new image.
    /// Non-complex images are cast to float before the operation.
    ///
    /// - Parameter exponent: The constant exponent  
    /// - Returns: A new image with each pixel raised to the given power
    /// - Throws: `VIPSError` if the operation fails
    public func pow(_ exponent: Double) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [exponent])
            opt.set("math2", value: VipsOperationMath2.pow)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math2_const", options: &opt)
        }
    }
    
    /// Calculate two-argument arctangent.
    ///
    /// This operation calculates atan2(left, right) pixel-wise.
    /// The result is the angle in degrees whose tangent is left/right, 
    /// using the signs of both to determine the quadrant.
    ///
    /// - Parameter x: The x-coordinate image
    /// - Returns: A new image with atan2(y, x) in degrees for each pixel pair
    /// - Throws: `VIPSError` if the operation fails
    public func atan2(_ x: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, x]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: x.image)
            opt.set("math2", value: VipsOperationMath2.atan2)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math2", options: &opt)
        }
    }
    
    /// Raise another image to the power of this image (swapped power).
    ///
    /// This operation calculates right^left pixel-wise, which is the opposite of pow().
    /// Useful when you want to use the current image as the exponent.
    /// Non-complex images are cast to float before the operation.
    ///
    /// - Parameter base: The base image  
    /// - Returns: A new image with each pixel being base^exponent (where exponent is from self)
    /// - Throws: `VIPSError` if the operation fails
    public func wop(_ base: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, base]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: base.image)
            opt.set("math2", value: VipsOperationMath2.wop)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math2", options: &opt)
        }
    }
    
    /// Raise a constant to the power of this image.
    ///
    /// This operation calculates base^pixel for each pixel.
    /// Non-complex images are cast to float before the operation.
    ///
    /// - Parameter base: The constant base
    /// - Returns: A new image with each pixel value being base^pixel
    /// - Throws: `VIPSError` if the operation fails
    public func wop(_ base: Double) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [base])
            opt.set("math2", value: VipsOperationMath2.wop)
            opt.set("out", value: &out)
            
            try VIPSImage.call("math2_const", options: &opt)
        }
    }
    
    /// Calculate remainder after division.
    ///
    /// This operation calculates the remainder after dividing left by right.
    /// The result has the same sign as the dividend (left operand).
    /// If the images differ in size, the smaller image is enlarged to match the larger.
    ///
    /// - Parameter divisor: The divisor image
    /// - Returns: A new image with the remainder of left/right for each pixel pair
    /// - Throws: `VIPSError` if the operation fails
    public func remainder(_ divisor: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, divisor]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: divisor.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("remainder", options: &opt)
        }
    }
    
    /// Calculate remainder after division by a constant.
    ///
    /// This operation calculates the remainder after dividing each pixel by a constant.
    /// The result has the same sign as the dividend (pixel value).
    ///
    /// - Parameter divisor: The constant divisor
    /// - Returns: A new image with the remainder of pixel/divisor for each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func remainder(_ divisor: Double) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [divisor])
            opt.set("out", value: &out)
            
            try VIPSImage.call("remainder_const", options: &opt)
        }
    }
    
    /// Calculate remainder after division by a constant.
    ///
    /// Convenience method that accepts an integer divisor.
    ///
    /// - Parameter divisor: The constant divisor
    /// - Returns: A new image with the remainder of pixel/divisor for each pixel
    /// - Throws: `VIPSError` if the operation fails
    public func remainder(_ divisor: Int) throws -> VIPSImage {
        return try self.remainder(Double(divisor))
    }
    
    // MARK: - Boolean/Bitwise Operations
    
    /// Perform bitwise AND with another image.
    ///
    /// This operation performs bitwise AND on corresponding pixels from two images.
    /// If the images differ in size, the smaller image is enlarged to match the larger.
    ///
    /// - Parameter right: The right-hand side image
    /// - Returns: A new image with bitwise AND of each pixel pair
    /// - Throws: `VIPSError` if the operation fails
    public func andimage(_ right: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, right]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: right.image)
            opt.set("boolean", value: VipsOperationBoolean.and)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean", options: &opt)
        }
    }
    
    /// Perform bitwise AND with a constant.
    ///
    /// This operation performs bitwise AND between each pixel and a constant value.
    ///
    /// - Parameter c: The constant value to AND with
    /// - Returns: A new image with bitwise AND of each pixel and the constant
    /// - Throws: `VIPSError` if the operation fails
    public func andimage(_ c: Double) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [c])
            opt.set("boolean", value: VipsOperationBoolean.and)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean_const", options: &opt)
        }
    }
    
    /// Perform bitwise OR with another image.
    ///
    /// This operation performs bitwise OR on corresponding pixels from two images.
    /// If the images differ in size, the smaller image is enlarged to match the larger.
    ///
    /// - Parameter right: The right-hand side image
    /// - Returns: A new image with bitwise OR of each pixel pair
    /// - Throws: `VIPSError` if the operation fails
    public func orimage(_ right: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, right]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: right.image)
            opt.set("boolean", value: VipsOperationBoolean.or)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean", options: &opt)
        }
    }
    
    /// Perform bitwise OR with a constant.
    ///
    /// This operation performs bitwise OR between each pixel and a constant value.
    ///
    /// - Parameter c: The constant value to OR with
    /// - Returns: A new image with bitwise OR of each pixel and the constant
    /// - Throws: `VIPSError` if the operation fails
    public func orimage(_ c: Double) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [c])
            opt.set("boolean", value: VipsOperationBoolean.or)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean_const", options: &opt)
        }
    }
    
    /// Perform bitwise XOR with another image.
    ///
    /// This operation performs bitwise exclusive OR on corresponding pixels from two images.
    /// If the images differ in size, the smaller image is enlarged to match the larger.
    ///
    /// - Parameter right: The right-hand side image
    /// - Returns: A new image with bitwise XOR of each pixel pair
    /// - Throws: `VIPSError` if the operation fails
    public func eorimage(_ right: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, right]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: right.image)
            opt.set("boolean", value: VipsOperationBoolean.eor)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean", options: &opt)
        }
    }
    
    /// Perform bitwise XOR with a constant.
    ///
    /// This operation performs bitwise exclusive OR between each pixel and a constant value.
    ///
    /// - Parameter c: The constant value to XOR with
    /// - Returns: A new image with bitwise XOR of each pixel and the constant
    /// - Throws: `VIPSError` if the operation fails
    public func eorimage(_ c: Double) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [c])
            opt.set("boolean", value: VipsOperationBoolean.eor)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean_const", options: &opt)
        }
    }
    
    /// Perform bitwise left shift.
    ///
    /// This operation shifts each pixel value left by n bits.
    ///
    /// - Parameter right: An image containing the shift amounts
    /// - Returns: A new image with left-shifted pixel values
    /// - Throws: `VIPSError` if the operation fails
    public func lshift(_ right: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, right]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: right.image)
            opt.set("boolean", value: VipsOperationBoolean.lshift)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean", options: &opt)
        }
    }
    
    /// Perform bitwise left shift by a constant.
    ///
    /// This operation shifts each pixel value left by n bits.
    ///
    /// - Parameter n: The number of bits to shift
    /// - Returns: A new image with left-shifted pixel values
    /// - Throws: `VIPSError` if the operation fails
    public func lshift(_ n: Int) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [Double(n)])
            opt.set("boolean", value: VipsOperationBoolean.lshift)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean_const", options: &opt)
        }
    }
    
    /// Perform bitwise right shift.
    ///
    /// This operation shifts each pixel value right by n bits.
    ///
    /// - Parameter right: An image containing the shift amounts
    /// - Returns: A new image with right-shifted pixel values
    /// - Throws: `VIPSError` if the operation fails
    public func rshift(_ right: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, right]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: right.image)
            opt.set("boolean", value: VipsOperationBoolean.rshift)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean", options: &opt)
        }
    }
    
    /// Perform bitwise right shift by a constant.
    ///
    /// This operation shifts each pixel value right by n bits.
    ///
    /// - Parameter n: The number of bits to shift
    /// - Returns: A new image with right-shifted pixel values
    /// - Throws: `VIPSError` if the operation fails
    public func rshift(_ n: Int) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("c", value: [Double(n)])
            opt.set("boolean", value: VipsOperationBoolean.rshift)
            opt.set("out", value: &out)
            
            try VIPSImage.call("boolean_const", options: &opt)
        }
    }
    
}


extension VIPSImage {
    public static func *(lhs: Double, image: VIPSImage) throws -> VIPSImage {
        return try image.linear(lhs)
    }
    
    public static func *(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.linear(rhs)
    }

    public static func *(lhs: VIPSImage, rhs: [Double]) throws -> VIPSImage {
        return try lhs.linear(rhs, [Double].init(repeating: 0, count: rhs.count))
    }
    
    public static func *(lhs: Int, image: VIPSImage) throws -> VIPSImage {
        return try image.linear(lhs)
    }
    
    public static func *(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.linear(rhs)
    }
    
    public static func +(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.linear(1.0, lhs)
    }
    
    public static func +(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.linear(1.0, rhs)
    }

    public static func +(lhs: VIPSImage, rhs: [Double]) throws -> VIPSImage {
        return try lhs.linear([Double].init(repeating: 1.0, count: rhs.count), rhs)
    }
    
    
    public static func +(lhs: Int, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.linear(1, lhs)
    }
    
    public static func +(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.linear(1, rhs)
    }
    
    public static func -(lhs: Int, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.linear(1, -lhs)
    }
    
    public static func -(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.linear(1, -rhs)
    }
    
    
    public static func +(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.add(rhs)
    }
    
    public static func -(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.subtract(rhs)
    }
    
    public static func *(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.multiply(rhs)
    }
    
    public static func /(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.divide(rhs)
    }
    
    // MARK: - Comparison Operators (Element-wise)
    // Note: These return VIPSImage with 255 for true, 0 for false per pixel
    // Cannot conform to Comparable protocol as that requires Bool return type
    
    public static func ==(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.equal(rhs)
    }
    
    public static func !=(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.notequal(rhs)
    }
    
    public static func <(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.less(rhs)
    }
    
    public static func <=(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.lesseq(rhs)
    }
    
    public static func >(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.more(rhs)
    }
    
    public static func >=(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.moreeq(rhs)
    }
    
    // MARK: - Comparison with constants
    
    public static func ==(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.equal(rhs)
    }
    
    public static func !=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.notequal(rhs)
    }
    
    public static func <(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.less(rhs)
    }
    
    public static func <=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.lesseq(rhs)
    }
    
    public static func >(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.more(rhs)
    }
    
    public static func >=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.moreeq(rhs)
    }
    
    // Reverse order for constants
    public static func ==(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.equal(lhs)
    }
    
    public static func !=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.notequal(lhs)
    }
    
    public static func <(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.more(lhs)  // Note: reversed
    }
    
    public static func <=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.moreeq(lhs)  // Note: reversed
    }
    
    public static func >(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.less(lhs)  // Note: reversed
    }
    
    public static func >=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.lesseq(lhs)  // Note: reversed
    }
    
    // MARK: - Bitwise Operators
    
    public static func &(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.andimage(rhs)
    }
    
    public static func |(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.orimage(rhs)
    }
    
    public static func ^(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.eorimage(rhs)
    }
    
    public static func <<(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.lshift(rhs)
    }
    
    public static func >>(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.rshift(rhs)
    }
}

// MARK: - Complex Number Operations

extension VIPSImage {
    /// Combine two images as a complex image.
    ///
    /// This operation combines two real images to create a complex image.
    /// The first image becomes the real part and the second image becomes the imaginary part.
    /// Both images must have the same dimensions and number of bands.
    ///
    /// - Parameter imaginary: The image to use as the imaginary part
    /// - Returns: A new complex image
    /// - Throws: `VIPSError` if the operation fails or images are incompatible
    public func complex(_ imaginary: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, imaginary]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: imaginary.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("complexform", options: &opt)
        }
    }
    
    /// Convert real and imaginary images to complex form.
    ///
    /// This is an alias for `complex(_:)` to match the libvips naming.
    ///
    /// - Parameter imaginary: The image to use as the imaginary part
    /// - Returns: A new complex image
    /// - Throws: `VIPSError` if the operation fails
    public func complexform(_ imaginary: VIPSImage) throws -> VIPSImage {
        return try complex(imaginary)
    }
    
    /// Perform a complex operation on an image.
    ///
    /// This operation performs various transformations on complex images:
    /// - `.polar`: Convert complex to polar form (magnitude and phase)
    /// - `.rect`: Convert polar to rectangular form (real and imaginary)
    /// - `.conj`: Complex conjugate
    ///
    /// - Parameter operation: The complex operation to perform
    /// - Returns: A new image with the operation applied
    /// - Throws: `VIPSError` if the operation fails
    public func complex(_ operation: VipsOperationComplex) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("cmplx", value: operation)
            opt.set("out", value: &out)
            
            try VIPSImage.call("complex", options: &opt)
        }
    }
    
    /// Convert complex image to polar form.
    ///
    /// Converts a complex image from rectangular (real, imaginary) to polar (magnitude, phase) form.
    /// The output has two bands: magnitude and phase (in degrees).
    ///
    /// - Returns: A new image in polar form
    /// - Throws: `VIPSError` if the operation fails
    public func polar() throws -> VIPSImage {
        return try complex(.polar)
    }
    
    /// Convert polar image to rectangular form.
    ///
    /// Converts a complex image from polar (magnitude, phase) to rectangular (real, imaginary) form.
    /// The input should have two bands: magnitude and phase (in degrees).
    ///
    /// - Returns: A new complex image in rectangular form
    /// - Throws: `VIPSError` if the operation fails
    public func rect() throws -> VIPSImage {
        return try complex(.rect)
    }
    
    /// Calculate the complex conjugate.
    ///
    /// For a complex number a + bi, returns a - bi.
    /// This operation negates the imaginary part while keeping the real part unchanged.
    ///
    /// - Returns: A new image with the complex conjugate
    /// - Throws: `VIPSError` if the operation fails
    public func conj() throws -> VIPSImage {
        return try complex(.conj)
    }
    
    /// Extract a component from a complex image.
    ///
    /// This operation extracts either the real or imaginary component from a complex image.
    ///
    /// - Parameter get: The component to extract (.real or .imag)
    /// - Returns: A new real-valued image containing the specified component
    /// - Throws: `VIPSError` if the operation fails
    public func complexget(_ get: VipsOperationComplexget) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("get", value: get)
            opt.set("out", value: &out)
            
            try VIPSImage.call("complexget", options: &opt)
        }
    }
    
    /// Extract the real part from a complex image.
    ///
    /// Returns a real-valued image containing only the real component of the complex input.
    ///
    /// - Returns: A new image containing the real part
    /// - Throws: `VIPSError` if the operation fails
    public func real() throws -> VIPSImage {
        return try complexget(.real)
    }
    
    /// Extract the imaginary part from a complex image.
    ///
    /// Returns a real-valued image containing only the imaginary component of the complex input.
    ///
    /// - Returns: A new image containing the imaginary part
    /// - Throws: `VIPSError` if the operation fails
    public func imag() throws -> VIPSImage {
        return try complexget(.imag)
    }
    
    /// Perform a binary complex operation on two images.
    ///
    /// Currently supports cross-phase operation for comparing phase between two complex images.
    ///
    /// - Parameters:
    ///   - other: The second complex image
    ///   - operation: The complex operation to perform
    /// - Returns: A new image with the operation result
    /// - Throws: `VIPSError` if the operation fails
    public func complex2(_ other: VIPSImage, operation: VipsOperationComplex2) throws -> VIPSImage {
        return try VIPSImage([self, other]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: other.image)
            opt.set("cmplx", value: operation)
            opt.set("out", value: &out)
            
            try VIPSImage.call("complex2", options: &opt)
        }
    }
    
    /// Calculate the cross-phase of two complex images.
    ///
    /// Computes the phase difference between two complex images.
    /// Useful for phase correlation and related signal processing tasks.
    ///
    /// - Parameter other: The second complex image
    /// - Returns: A new image containing the cross-phase
    /// - Throws: `VIPSError` if the operation fails
    public func crossPhase(_ other: VIPSImage) throws -> VIPSImage {
        return try complex2(other, operation: .crossPhase)
    }
}

// MARK: - Statistical Operations

extension VIPSImage {
    /// Sum an array of images element-wise.
    ///
    /// This operation sums an array of images pixel by pixel.
    /// All images must have the same dimensions. If the images have different numbers of bands,
    /// images with fewer bands are expanded by duplicating the last band.
    ///
    /// - Parameter images: Array of images to sum
    /// - Returns: A new image containing the element-wise sum
    /// - Throws: `VIPSError` if the operation fails or images are incompatible
    public static func sum(_ images: [VIPSImage]) throws -> VIPSImage {
        guard !images.isEmpty else {
            throw VIPSError("Cannot sum empty array of images")
        }
        
        guard images.count > 1 else {
            // If only one image, return it directly
            return images[0]
        }
        
        return try VIPSImage(images) { out in
            var opt = VIPSOption()
            
            // vips_sum expects an array of images
            opt.set("in", value: images)
            opt.set("out", value: &out)
            
            try VIPSImage.call("sum", options: &opt)
        }
    }
    
    /// Calculate comprehensive statistics for an image.
    ///
    /// Returns an image containing statistics for each band:
    /// - Row 0: minimum values
    /// - Row 1: maximum values  
    /// - Row 2: sum of all values
    /// - Row 3: sum of squares
    /// - Row 4: mean values
    /// - Row 5: standard deviation
    /// 
    /// Additional rows may contain x and y coordinates of min/max values.
    ///
    /// - Returns: A new image containing statistics (width = number of bands, height = 10)
    /// - Throws: `VIPSError` if the operation fails
    public func stats() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("stats", options: &opt)
        }
    }
    
    /// Measure labeled regions in an image.
    ///
    /// This operation assumes the image contains labeled regions (connected components)
    /// where each region has a unique integer label. It calculates statistics for each region.
    ///
    /// - Parameters:
    ///   - h: Number of horizontal patches to divide the image into
    ///   - v: Number of vertical patches to divide the image into
    /// - Returns: A new image containing measurements for each region
    /// - Throws: `VIPSError` if the operation fails
    public func measure(h: Int = 1, v: Int = 1) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("h", value: h)
            opt.set("v", value: v)
            
            try VIPSImage.call("measure", options: &opt)
        }
    }
    
    /// Extract profiles from an image.
    ///
    /// Creates 1D profiles by averaging across rows and columns.
    /// Returns two images: column profile (vertical average) and row profile (horizontal average).
    ///
    /// - Returns: A tuple containing (columns profile, rows profile)
    /// - Throws: `VIPSError` if the operation fails
    public func profile() throws -> (columns: VIPSImage, rows: VIPSImage) {
        var columnsOut: UnsafeMutablePointer<VipsImage>?
        var rowsOut: UnsafeMutablePointer<VipsImage>?
        
        var opt = VIPSOption()
        
        opt.set("in", value: self.image)
        opt.set("columns", value: &columnsOut)
        opt.set("rows", value: &rowsOut)
        
        try VIPSImage.call("profile", options: &opt)
        
        guard let colsPtr = columnsOut, let rowsPtr = rowsOut else {
            throw VIPSError("Failed to get profile outputs")
        }
        
        let columns = VIPSImage(colsPtr)
        let rows = VIPSImage(rowsPtr)
        
        return (columns, rows)
    }
    
    /// Project rows and columns to get sums.
    ///
    /// Returns two 1D images containing the sum of each row and column.
    /// Useful for creating projections and histograms.
    ///
    /// - Returns: A tuple containing (row sums, column sums)
    /// - Throws: `VIPSError` if the operation fails
    public func project() throws -> (rows: VIPSImage, columns: VIPSImage) {
        var rowsOut: UnsafeMutablePointer<VipsImage>?
        var columnsOut: UnsafeMutablePointer<VipsImage>?
        
        var opt = VIPSOption()
        
        opt.set("in", value: self.image)
        opt.set("rows", value: &rowsOut)
        opt.set("columns", value: &columnsOut)
        
        try VIPSImage.call("project", options: &opt)
        
        guard let rowsPtr = rowsOut, let colsPtr = columnsOut else {
            throw VIPSError("Failed to get projection outputs")
        }
        
        let rows = VIPSImage(rowsPtr)
        let columns = VIPSImage(colsPtr)
        
        return (rows, columns)
    }
}

// MARK: - Band Operations

extension VIPSImage {
    /// Perform a boolean operation across bands.
    ///
    /// Reduces multiple bands to a single band by performing the specified
    /// boolean operation on corresponding pixels across all bands.
    ///
    /// - Parameter operation: The boolean operation to perform
    /// - Returns: A new single-band image
    /// - Throws: `VIPSError` if the operation fails
    public func bandbool(_ operation: VipsOperationBoolean) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("boolean", value: operation)
            opt.set("out", value: &out)
            
            try VIPSImage.call("bandbool", options: &opt)
        }
    }
    
    /// Perform bitwise AND operation across bands.
    ///
    /// Reduces multiple bands to a single band by performing bitwise AND
    /// on corresponding pixels across all bands.
    ///
    /// - Returns: A new single-band image
    /// - Throws: `VIPSError` if the operation fails
    public func bandand() throws -> VIPSImage {
        return try bandbool(.and)
    }
    
    /// Perform bitwise OR operation across bands.
    ///
    /// Reduces multiple bands to a single band by performing bitwise OR
    /// on corresponding pixels across all bands.
    ///
    /// - Returns: A new single-band image
    /// - Throws: `VIPSError` if the operation fails
    public func bandor() throws -> VIPSImage {
        return try bandbool(.or)
    }
    
    /// Perform bitwise XOR (exclusive OR) operation across bands.
    ///
    /// Reduces multiple bands to a single band by performing bitwise XOR
    /// on corresponding pixels across all bands.
    ///
    /// - Returns: A new single-band image
    /// - Throws: `VIPSError` if the operation fails
    public func bandeor() throws -> VIPSImage {
        return try bandbool(.eor)
    }
}
