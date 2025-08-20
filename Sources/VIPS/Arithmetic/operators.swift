//
//  File.swift
//  
//
//  Created by Tobias Haeberle on 29.10.21.
//



extension VIPSImage {
    public func linear(_ a: Double = 1.0, _ b: Double = 0) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("a", value: [ a ])
            opt.set("b", value: [ b ])
            opt.set("out", value: &out)
            
            try VIPSImage.call("linear", options: &opt)
        }
    }
    
    public func linear(_ a: Int = 1, _ b: Int = 0) throws -> VIPSImage {
        return try linear(Double(a), Double(b))
    }

    public func linear(_ a: [Double], _ b: [Double]) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("a", value: a)
            opt.set("b", value: b)
            opt.set("out", value: &out)
            
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
    public func relational_const(_ relational: VipsOperationRelational, _ c: [Double]) throws -> VIPSImage {
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
    public func relational_const(_ relational: VipsOperationRelational, _ c: Double) throws -> VIPSImage {
        return try self.relational_const(relational, [c])
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
    public func equal_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.equal, c)
    }
    
    /// Test if image pixels are not equal to a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel != constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 for unequal pixels, 0 for equal pixels
    /// - Throws: `VIPSError` if the operation fails
    public func notequal_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.noteq, c)
    }
    
    /// Test if image pixels are less than a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel < constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel < constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func less_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.less, c)
    }
    
    /// Test if image pixels are less than or equal to a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel <= constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel <= constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func lesseq_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.lesseq, c)
    }
    
    /// Test if image pixels are greater than a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel > constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel > constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func more_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.more, c)
    }
    
    /// Test if image pixels are greater than or equal to a constant.
    ///
    /// Compares each pixel in the image with a constant value.
    /// The result is 255 where pixel >= constant, 0 otherwise.
    ///
    /// - Parameter c: The constant value to compare against
    /// - Returns: A uchar image with 255 where pixel >= constant, 0 otherwise
    /// - Throws: `VIPSError` if the operation fails
    public func moreeq_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.moreeq, c)
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
        return try lhs.equal_const(rhs)
    }
    
    public static func !=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.notequal_const(rhs)
    }
    
    public static func <(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.less_const(rhs)
    }
    
    public static func <=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.lesseq_const(rhs)
    }
    
    public static func >(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.more_const(rhs)
    }
    
    public static func >=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.moreeq_const(rhs)
    }
    
    // Reverse order for constants
    public static func ==(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.equal_const(lhs)
    }
    
    public static func !=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.notequal_const(lhs)
    }
    
    public static func <(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.more_const(lhs)  // Note: reversed
    }
    
    public static func <=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.moreeq_const(lhs)  // Note: reversed
    }
    
    public static func >(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.less_const(lhs)  // Note: reversed
    }
    
    public static func >=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.lesseq_const(lhs)  // Note: reversed
    }
}
