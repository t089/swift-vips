import Cvips

extension VIPSImage {
    public static func text(
        _ text: String,
        font: String? = nil,
        fontFile: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        align: VipsAlign? = nil,
        justify: Bool? = nil,
        dpi: Int? = nil,
        autofitDpi: Int? = nil,
        rgba: Bool? = nil,
        spacing: Int? = nil,
        wrap: VipsTextWrap? = nil,
        options: String? = nil
    ) throws -> VIPSImage {
        try VIPSImage(nil) { out in 
            var opt = VIPSOption()
            opt.set("text", value: text)
            if let font {
                opt.set("font", value: font)
            }
            if let fontFile {
                opt.set("fontFile", value: fontFile)
            }
            if let width {
                opt.set("width", value: width)
            }
            if let height {
                opt.set("height", value: height)
            }
            if let align {
                opt.set("align", value: align)
            }
            if let justify {
                opt.set("justify", value: justify)
            }
            if let dpi {
                opt.set("dpi", value: dpi)
            }
            if let autofitDpi {
                opt.set("autofit_dpi", value: autofitDpi)
            }
            if let rgba {
                opt.set("rgba", value: rgba)
            }
            if let spacing {
                opt.set("spacing", value: spacing)
            }
            if let wrap {
                opt.set("wrap", value: wrap)
            }

            opt.set("out", value: &out)

            return try call("text", optionsString: options, options: &opt)
        }
    }
}

extension VIPSImage {
    /// Creates an identity lookup table, ie. one which will leave an image unchanged when applied with vips_maplut(). Each entry in the table has a value equal to its position.
    ///
    /// Use the arithmetic operations on these tables to make LUTs representing arbitrary functions.
    ///
    /// Normally LUTs are 8-bit. Set ushort to create a 16-bit table.
    ///
    /// Normally 16-bit tables have 65536 entries. You can set this smaller with size.
    public static func identity(bands: Int? = nil, ushort: Bool = false, size: Int? = nil) throws -> VIPSImage {
        try VIPSImage(nil) { out in
            var opt = VIPSOption()
            if let bands {
                opt.set("bands", value: bands)
            }
            if ushort {
                opt.set("ushort", value: ushort)
            }
            if let size {
                opt.set("size", value: size)
            }

            opt.set("out", value: &out)

            return try call("identity", optionsString: nil, options: &opt)
        }
    }
    
    /// Make a black image.
    ///
    /// Creates an image where all pixels are zero. The image is a one-band float image
    /// by default. Use `cast` to convert to a different format, or `linear` to add
    /// an offset and scale.
    ///
    /// - Parameters:
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels  
    ///   - bands: Number of bands in the image (default: 1)
    /// - Returns: A new black (all zeros) image
    /// - Throws: `VIPSError` if the operation fails
    ///
    /// ## Example
    /// ```swift
    /// // Create a 100x100 black image
    /// let black = try VIPSImage.black(100, 100)
    ///
    /// // Create a 256x256 RGB black image
    /// let blackRGB = try VIPSImage.black(256, 256, bands: 3)
    /// ```
    public static func black(_ width: Int, _ height: Int, bands: Int = 1) throws -> VIPSImage {
        try VIPSImage(nil) { out in
            var opt = VIPSOption()
            opt.set("width", value: width)
            opt.set("height", value: height)
            opt.set("bands", value: bands)
            opt.set("out", value: &out)
            
            return try call("black", optionsString: nil, options: &opt)
        }
    }
}