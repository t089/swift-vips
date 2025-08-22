import Cvips
import CvipsShim

open class VIPSImage {
    
    internal var other: Any? = nil
    
    private(set) var image: UnsafeMutablePointer<VipsImage>
    
    convenience public init(bufferNoCopy data: UnsafeRawBufferPointer, loader: String? = nil, options: String? = nil) throws {
        
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

    func withVipsImage<R>(_ body: (UnsafeMutablePointer<VipsImage>) -> R) -> R {
        return body(self.image)
    }

    public init(data: some Collection<UInt8>, width: Int, height: Int, bands: Int, format: VipsBandFormat) throws {
        
        let maybe = try data.withContiguousStorageIfAvailable { buffer in
            guard let image = vips_image_new_from_memory_copy(buffer.baseAddress, buffer.count, .init(width), .init(height), .init(bands), format) else {
                throw VIPSError(vips_error_buffer())
            }
            return image
        }
        if let maybe = maybe {
            self.image = maybe
        } else {
            let image = Array(data).withUnsafeBufferPointer { buffer in
                vips_image_new_from_memory_copy(buffer.baseAddress, buffer.count, .init(width), .init(height), .init(bands), format)
            }
            guard let image else {
                throw VIPSError()
            }
            self.image = image
        }

    }
    
    convenience public init<C: Collection>(data: C, loader: String? = nil, options: String? = nil) throws where C.Element == UInt8 {
        guard let (loader, blob) = try data.withContiguousStorageIfAvailable({ storage -> (String, UnsafeMutablePointer<VipsBlob>) in
            guard let loader = loader ?? vips_foreign_find_load_buffer(storage.baseAddress, storage.count).flatMap(String.init(cString:)) else {
                throw VIPSError()
            }
            
            
            
            return ( loader, vips_blob_copy(storage.baseAddress, storage.count) )
        }) else {
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
    
    public convenience  init(fromSource source: VIPSSource, loader: String? = nil, options: String? = nil) throws {
        
        let loader = try loader ?? source.findLoader()
        
        try self.init(source) { out in
            var option = VIPSOption()
            option.set("source", value: source.source)
            option.set("out", value: &out)
            try VIPSImage.call(loader, optionsString: options, options: &option)
        }
    }
    
    public init(_ image: UnsafeMutablePointer<VipsImage>) {
        self.image = image
    }
    
    @usableFromInline
    init(_ other: Any?, _ block: (inout UnsafeMutablePointer<VipsImage>?) throws -> ()) rethrows {
        let image : UnsafeMutablePointer<UnsafeMutablePointer<VipsImage>?> = .allocate(capacity: 1)
        image.initialize(to: nil)
        defer {
            image.deallocate()
        }
        try block(&image.pointee)
        precondition(image.pointee != nil, "Image pointer cannot be nil after init.")
        self.image = image.pointee!
        self.other = other
    }
    
    func withUnsafeMutablePointer<T>(_ block: (inout UnsafeMutablePointer<VipsImage>) throws -> (T)) rethrows -> T {
        return try block(&self.image)
    }
    
    deinit {
        g_object_unref(self.image)
    }
    
    @usableFromInline
    static func call(_ name: UnsafePointer<CChar>!, optionsString: String? = nil, options: inout VIPSOption) throws {
        try self.call(String(cString: name), optionsString: optionsString, options: &options)
    }
    
    @usableFromInline
    static func call(_ name: String, optionsString: String? = nil, options: inout VIPSOption) throws {
        let op = try VIPSOperation(name: name)
        
        if let options = optionsString {
            try op.setFromString(options: options)
        }
        
        op.set(option: options)
        
        guard vips_cache_operation_buildp( &op.op ) == 0 else {
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
            if (out == nil) { throw VIPSError() }
        }
    }
}