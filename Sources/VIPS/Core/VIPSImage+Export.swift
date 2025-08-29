import Cvips
import CvipsShim

extension VIPSImage {
    public func exportJpeg(quality: Int? = nil, to target: VIPSCustomTarget) throws {
        guard let name = vips_foreign_find_save_target(".jpg") else {
            throw VIPSError()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        if let q = quality { options.set("Q", value: q) }
        options.set("target", value: target.target)
        
        try VIPSImage.call(name, options: &options)
    }
    
    public func exportedJpeg(quality: Int? = nil, optimizeCoding: Bool = false, interlace: Bool = false, strip: Bool = false) throws -> [UInt8] {
        guard let name = vips_foreign_find_save_buffer(".jpg") else {
            throw VIPSError()
        }
        
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>?>.allocate(capacity: 1)
        defer {
            outBuf.deallocate()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        if let q = quality { options.set("Q", value: q) }
        options.set("optimize_coding", value: optimizeCoding)
        options.set("interlace", value: optimizeCoding)
        options.set("strip", value: strip)
        options.set("buffer", value: outBuf)
        
        try VIPSImage.call(name, options: &options)
        
        let blob = outBuf.pointee
        
        let areaPtr = shim_vips_area(blob)
        let buffer = UnsafeRawBufferPointer(start: areaPtr!.pointee.data, count: Int(areaPtr!.pointee.length))
        
        defer { vips_area_unref(shim_vips_area(blob)) }
        
        return Array(buffer)
    }
    
    public func exported(suffix: String, quality: Int? = nil, options additionalOptions: String? = nil) throws -> [UInt8] {
        guard let name = vips_foreign_find_save_buffer(suffix) else {
            throw VIPSError()
        }
        
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>?>.allocate(capacity: 1)
        defer {
            outBuf.deallocate()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        if let q = quality { options.set("Q", value: q) }
        options.set("buffer", value: outBuf)
        
        try VIPSImage.call(name, optionsString: additionalOptions, options: &options)
        
        let blob = outBuf.pointee
        let areaPtr = shim_vips_area(blob)
        let buffer = UnsafeRawBufferPointer(start: areaPtr!.pointee.data, count: Int(areaPtr!.pointee.length))
        
        defer { vips_area_unref(shim_vips_area(blob)) }
        
        return Array(buffer)
    }
    
    public func exportedHeif(quality: Int? = nil, lossless: Bool = false) throws -> [UInt8] {
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>?>.allocate(capacity: 1)
        defer {
            outBuf.deallocate()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        if let q = quality {
            options.set("Q", value: q)
        }
        if lossless {
            options.set("lossless", value: true)
        }
        options.set("buffer", value: outBuf)
        
        try VIPSImage.call("heifsave_buffer", options: &options)
        
        let blob = outBuf.pointee
        let areaPtr = shim_vips_area(blob)
        let buffer = UnsafeRawBufferPointer(start: areaPtr!.pointee.data, count: Int(areaPtr!.pointee.length))
        
        defer { vips_area_unref(shim_vips_area(blob)) }
        
        return Array(buffer)
    }
    
    public func webp(
        quality: Int? = nil,
        lossless: Bool? = nil,
        smartSubsample: Bool? = nil,
        nearLossless: Bool? = nil,
        alphaQ: Int? = nil,
        effort: Int? = nil,
        minimizeSize: Bool? = nil,
        mixed: Bool? = nil,
        kmin: Bool? = nil,
        kmax: Bool? = nil,
        stripMetadata strip: Bool? = nil,
        profile: String? = nil
    ) throws -> [UInt8] {
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>?>.allocate(capacity: 1)
        defer {
            outBuf.deallocate()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        options.set("buffer", value: outBuf)
        if let quality = quality {
            options.set("Q", value: quality)
        }
        if let lossless = lossless {
            options.set("lossless", value: lossless)
        }
        if let smartSubsample = smartSubsample {
            options.set("smart_subsample", value: smartSubsample)
        }
        if let nearLossless = nearLossless {
            options.set("near_lossless", value: nearLossless)
        }
        if let alphaQ = alphaQ {
            options.set("alpha_q", value: alphaQ)
        }
        if let effort = effort {
            options.set("effort", value: effort)
        }
        if let minimizeSize = minimizeSize {
            options.set("min_size", value: minimizeSize)
        }
        if let mixed = mixed {
            options.set("mixed", value: mixed)
        }
        if let kmin = kmin {
            options.set("kmin", value: kmin)
        }
        if let kmax = kmax {
            options.set("kmax", value: kmax)
        }
        if let strip = strip {
            options.set("strip", value: strip)
        }
        if let profile = profile {
            options.set("profile", value: profile)
        }
        
        try VIPSImage.call("webpsave_buffer", options: &options)
        
        let blob = outBuf.pointee
        let areaPtr = shim_vips_area(blob)
        let buffer = UnsafeRawBufferPointer(start: areaPtr!.pointee.data, count: Int(areaPtr!.pointee.length))
        
        defer { vips_area_unref(shim_vips_area(blob)) }
        
        return Array(buffer)
    }

    public func heifsave(
        quality: Int? = nil,
        bitdepth: Int? = nil,
        lossless: Bool? = nil,
        compression: HeifCompression? = nil,
        effort: Int? = nil,
        subsampleMode: ForeignSubsample? = nil,
        encoder: HeifEncoder? = nil
    ) throws -> [UInt8] {
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>?>.allocate(capacity: 1)
        defer {
            outBuf.deallocate()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        options.set("buffer", value: outBuf)
        if let quality = quality {
            options.set("Q", value: quality)
        }
        if let bitdepth = bitdepth {
            options.set("bitdepth", value: bitdepth)
        }
        if let lossless = lossless {
            options.set("lossless", value: lossless)
        }
        if let compression = compression {
            options.set("compression", value: compression.cVipsCompression)
        }
        if let effort = effort {
            options.set("effort", value: effort)
        }
        
        if let subsampleMode = subsampleMode {
            options.set("subsample_mode", value: subsampleMode.mode)
        }
        if let encoder = encoder {
            options.set("encoder", value: encoder.encoder)
        }
        
        try VIPSImage.call("heifsave_buffer", options: &options)
        
        let blob = outBuf.pointee
        let areaPtr = shim_vips_area(blob)
        let buffer = UnsafeRawBufferPointer(start: areaPtr!.pointee.data, count: Int(areaPtr!.pointee.length))

        defer { vips_area_unref(shim_vips_area(blob)) }

        return Array(buffer)
    }
        
    
    public func exportedPNG() throws -> [UInt8] {
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>?>.allocate(capacity: 1)
        defer {
            outBuf.deallocate()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        options.set("buffer", value: outBuf)
        
        try VIPSImage.call("pngsave_buffer", options: &options)
        
        let blob = outBuf.pointee
        let areaPtr = shim_vips_area(blob)
        let buffer = UnsafeRawBufferPointer(start: areaPtr!.pointee.data, count: Int(areaPtr!.pointee.length))
        
        defer { vips_area_unref(shim_vips_area(blob)) }
        
        return Array(buffer)
    }
}