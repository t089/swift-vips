extension VIPSImage {
    public func cast(_ format: VipsBandFormat, shift: Bool? = nil) throws -> VIPSImage {
        try self.cast(format: format, shift: shift)
    }

    /// See VIPSImage.bandjoin(`in`:)
    public func bandjoin(_ other: [VIPSImage]) throws -> VIPSImage {
        return try VIPSImage([self] + other) { out in
            var opt = VIPSOption()

            opt.set("in", value: [self] + other)
            opt.set("out", value: &out)

            try VIPSImage.call("bandjoin", options: &opt)
        }
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
