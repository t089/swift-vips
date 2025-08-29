import Cvips
import CvipsShim

open class VIPSImage {

    internal var other: Any? = nil

    @usableFromInline
    private(set) var image: UnsafeMutablePointer<VipsImage>

    func withVipsImage<R>(_ body: (UnsafeMutablePointer<VipsImage>) -> R) -> R {
        return body(self.image)
    }

    /// This function creates a VIPSImage from a memory area.
    /// The memory area must be a simple array, for example RGBRGBRGB, left-to-right, top-to-bottom.
    /// The memory will be copied into the image.
    @inlinable
    public init(
        data: some Collection<UInt8>,
        width: Int,
        height: Int,
        bands: Int,
        format: VipsBandFormat
    ) throws {

        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    format
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from signed 8-bit integer data with memory copy.
    ///
    /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
    ///
    /// - Parameters:
    ///   - data: Collection containing Int8 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    @inlinable
    public init(
        data: some Collection<Int8>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    .char
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from unsigned 16-bit integer data with memory copy.
    ///
    /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
    ///
    /// - Parameters:
    ///   - data: Collection containing UInt16 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    @inlinable
    public init(
        data: some Collection<UInt16>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    .ushort
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from signed 16-bit integer data with memory copy.
    ///
    /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
    ///
    /// - Parameters:
    ///   - data: Collection containing Int16 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    @inlinable
    public init(
        data: some Collection<Int16>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    .short
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from unsigned 32-bit integer data with memory copy.
    ///
    /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
    ///
    /// - Parameters:
    ///   - data: Collection containing UInt32 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    @inlinable
    public init(
        data: some Collection<UInt32>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    .uint
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from signed 32-bit integer data with memory copy.
    ///
    /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
    ///
    /// - Parameters:
    ///   - data: Collection containing Int32 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    @inlinable
    public init(
        data: some Collection<Int32>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    .int
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from 32-bit floating point data with memory copy.
    ///
    /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
    ///
    /// - Parameters:
    ///   - data: Collection containing Float pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    @inlinable
    public init(
        data: some Collection<Float>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    .float
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from 64-bit floating point data with memory copy.
    ///
    /// This function creates a VipsImage from a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom. The memory will be copied into the image.
    ///
    /// - Parameters:
    ///   - data: Collection containing Double pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    @inlinable
    public init(
        data: some Collection<Double>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        func createImage(from buffer: UnsafeRawBufferPointer) throws -> UnsafeMutablePointer<
            VipsImage
        > {
            guard
                let image = vips_image_new_from_memory_copy(
                    buffer.baseAddress,
                    buffer.count,
                    .init(width),
                    .init(height),
                    .init(bands),
                    .double
                )
            else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }

        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            try createImage(from: .init(buffer))
        }

        if let maybe = maybe {
            self.image = maybe
        } else {
            self.image = try Array(data)
                .withUnsafeBufferPointer { buffer in
                    try createImage(from: .init(buffer))
                }
        }
    }

    /// Creates a VIPSImage from a memory area containing unsigned 8-bit integer data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing UInt8 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<UInt8>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .uchar
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a VIPSImage from a memory area containing signed 8-bit integer data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing Int8 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<Int8>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .char
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a VIPSImage from a memory area containing unsigned 16-bit integer data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing UInt16 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<UInt16>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .ushort
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a VIPSImage from a memory area containing signed 16-bit integer data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing Int16 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<Int16>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .short
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a VIPSImage from a memory area containing unsigned 32-bit integer data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing UInt32 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<UInt32>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .uint
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a VIPSImage from a memory area containing signed 32-bit integer data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing Int32 pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<Int32>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .int
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a VIPSImage from a memory area containing 32-bit floating point data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing Float pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<Float>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .float
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a VIPSImage from a memory area containing 64-bit floating point data.
    ///
    /// This function wraps a VipsImage around a memory area. The memory area must be a simple array,
    /// for example RGBRGBRGB, left-to-right, top-to-bottom.
    ///
    /// **DANGER**: VIPS does not take responsibility for the memory area. The memory will NOT be copied
    /// into the image. You must ensure the memory remains valid for the lifetime of the image and all
    /// its descendants. Use the copy variant if you are unsure about memory management.
    ///
    /// - Parameters:
    ///   - buffer: Buffer containing Double pixel data
    ///   - width: Image width in pixels
    ///   - height: Image height in pixels
    ///   - bands: Number of bands per pixel
    /// - Throws: VIPSError if image creation fails
    public init(
        unsafeData buffer: UnsafeBufferPointer<Double>,
        width: Int,
        height: Int,
        bands: Int
    ) throws {
        guard
            let image = vips_image_new_from_memory(
                buffer.baseAddress,
                buffer.count,
                .init(width),
                .init(height),
                .init(bands),
                .double
            )
        else {
            throw VIPSError()
        }

        self.image = image
    }

    /// Creates a new image by loading the given data.
    ///
    /// The image will NOT copy the data into its own memory.
    /// You need to ensure that the data remains valid for the lifetime of the image and all its descendants.
    ///
    /// - Parameters:
    ///   - bufferNoCopy: The image data to load
    ///   - loader: The loader to use (optional)
    ///   - options: The options to use (optional)
    convenience public init(
        bufferNoCopy data: UnsafeRawBufferPointer,
        loader: String? = nil,
        options: String? = nil
    ) throws {

        func findLoader() throws -> String {
            guard let loader = vips_foreign_find_load_buffer(data.baseAddress, data.count) else {
                throw VIPSError()
            }
            return String(cString: loader)
        }

        let loader = try loader ?? findLoader()

        let blob = vips_blob_new(nil, data.baseAddress, data.count)
        defer {
            vips_area_unref(shim_vips_area(blob))
        }

        try self.init(nil) { out in
            var option = VIPSOption()
            option.set("buffer", value: blob)
            option.set("out", value: &out)
            try VIPSImage.call(loader, optionsString: options, options: &option)
        }
    }

    /// Creates a new image by loading the given data
    ///
    /// The image will copy the data into its own memory.
    ///
    /// - Parameters:
    ///   - data: The image data to load
    ///   - loader: The loader to use (optional)
    ///   - options: The options to use (optional)
    @inlinable
    convenience public init(
        data: some Collection<UInt8>,
        loader: String? = nil,
        options: String? = nil
    ) throws {
        guard
            let (loader, blob) = try data.withContiguousStorageIfAvailable({
                storage -> (String, UnsafeMutablePointer<VipsBlob>) in
                guard
                    let loader = loader
                        ?? vips_foreign_find_load_buffer(storage.baseAddress, storage.count)
                        .flatMap(String.init(cString:))
                else {
                    throw VIPSError()
                }

                return (loader, vips_blob_copy(storage.baseAddress, storage.count))
            })
        else {
            try self.init(data: Array(data), options: options)
            return
        }

        defer {
            vips_area_unref(shim_vips_area(blob))
        }

        try self.init(nil) { out in
            var option = VIPSOption()
            option.set("buffer", value: blob)
            option.set("out", value: &out)
            try VIPSImage.call(loader, optionsString: options, options: &option)
        }
    }

    public init(fromFilePath path: String, access: VipsAccess = .random) throws {
        guard let image = shim_vips_image_new_from_file(path, access) else {
            throw VIPSError(vips_error_buffer())
        }

        self.image = image
    }

    public convenience init(
        fromSource source: VIPSSource,
        loader: String? = nil,
        options: String? = nil
    ) throws {

        let loader = try loader ?? source.findLoader()

        try self.init(source) { out in
            var option = VIPSOption()
            option.set("source", value: source.source)
            option.set("out", value: &out)
            try VIPSImage.call(loader, optionsString: options, options: &option)
        }
    }

    /// Wraps a VipsImage pointer taking ownership of the pointer
    public init(_ image: UnsafeMutablePointer<VipsImage>) {
        self.image = image
    }

    @usableFromInline
    init(_ other: Any?, _ block: (inout UnsafeMutablePointer<VipsImage>?) throws -> Void) rethrows {
        let image: UnsafeMutablePointer<UnsafeMutablePointer<VipsImage>?> = .allocate(capacity: 1)
        image.initialize(to: nil)
        defer {
            image.deallocate()
        }
        try block(&image.pointee)
        precondition(image.pointee != nil, "Image pointer cannot be nil after init.")
        self.image = image.pointee!
        self.other = other
    }

    func withUnsafeMutablePointer<T>(_ block: (inout UnsafeMutablePointer<VipsImage>) throws -> (T))
        rethrows -> T
    {
        return try block(&self.image)
    }

    deinit {
        g_object_unref(self.image)
    }

    @usableFromInline
    static func call(
        _ name: UnsafePointer<CChar>!,
        optionsString: String? = nil,
        options: inout VIPSOption
    ) throws {
        try self.call(String(cString: name), optionsString: optionsString, options: &options)
    }

    @usableFromInline
    static func call(_ name: String, optionsString: String? = nil, options: inout VIPSOption) throws
    {
        let op = try VIPSOperation(name: name)

        if let options = optionsString {
            try op.setFromString(options: options)
        }

        op.set(option: options)

        guard vips_cache_operation_buildp(&op.op) == 0 else {
            throw VIPSError()
        }

        op.get(option: &options)
    }

    public func write(toFilePath path: String, quality: Int? = nil) throws {
        guard let opName = vips_foreign_find_save(path) else {
            throw VIPSError()
        }

        var option = VIPSOption()

        option.set("filename", value: path)
        if let q = quality {
            option.set("Q", value: q)
        }
        option.set("in", value: self.image)

        try VIPSImage.call(opName, options: &option)
    }

    public func gamma(_ exponent: Double) throws -> VIPSImage {
        try self.gamma(exponent: exponent)
    }
}

extension VIPSImage {
    public func new(_ colors: [Double]) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var c = colors
            out = vips_image_new_from_image(self.image, &c, Int32(c.count))
            if out == nil { throw VIPSError() }
        }
    }

    /// Create a matrix image from a double array
    /// - Parameters:
    ///   - width: Width of the matrix
    ///   - height: Height of the matrix
    ///   - data: Array of doubles, must have width * height elements
    /// - Returns: A new VIPSImage matrix
    /// - Note: The data is copied by libvips, so the input array does not need to remain alive
    public static func matrix(width: Int, height: Int, data: [Double]) throws -> VIPSImage {
        guard data.count == width * height else {
            throw VIPSError(
                "Data array size (\(data.count)) must match width * height (\(width * height))"
            )
        }

        // libvips copies the data synchronously in vips_image_new_matrix_from_array,
        // so the pointer only needs to be valid for the duration of this call
        let image = data.withUnsafeBufferPointer { buffer in
            vips_image_new_matrix_from_array(
                Int32(width),
                Int32(height),
                buffer.baseAddress,
                Int32(data.count)
            )
        }

        guard let image else {
            throw VIPSError()
        }

        return VIPSImage(image)
    }

    /// Create an empty matrix image
    /// - Parameters:
    ///   - width: Width of the matrix
    ///   - height: Height of the matrix
    /// - Returns: A new VIPSImage matrix filled with zeros
    public static func matrix(width: Int, height: Int) throws -> VIPSImage {
        guard let image = vips_image_new_matrix(Int32(width), Int32(height)) else {
            throw VIPSError()
        }

        return VIPSImage(image)
    }

    /// This function allocates memory, renders image into it, builds a new image
    /// around the memory area, and returns that.
    ///
    /// If the image is already a simple area of memory, it just refs image and
    /// returns it.
    public func copyMemory() throws -> VIPSImage {
        return try VIPSImage(nil) { out in
            out = vips_image_copy_memory(self.image)
            if out == nil { throw VIPSError() }
        }
    }
}
