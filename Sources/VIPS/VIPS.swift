import Cvips
import CvipsShim
import Foundation
import Logging


public struct VIPSError: Error, CustomStringConvertible {
    public let message: String
    
    init(_ errorBuffer: UnsafePointer<Int8>! = vips_error_buffer()) {
        self.message = String(cString: errorBuffer)
        vips_error_clear()
    }
    
    init(_ message: String) {
        self.message = message
    }
    
    public var description: String { self.message }
}

func logfunc(_ domain: UnsafePointer<gchar>!, _ loglevel: GLogLevelFlags, _ msg: UnsafePointer<gchar>!, _ userdata: gpointer!) {
    let logger : VIPSLoggingDelegate = Unmanaged<AnyObject>.fromOpaque(userdata).takeUnretainedValue() as! VIPSLoggingDelegate
    switch loglevel {
    case G_LOG_LEVEL_ERROR:
        logger.error("\(String(cString: msg))")
    case G_LOG_LEVEL_WARNING:
        logger.warning("\(String(cString: msg))")
    case G_LOG_LEVEL_INFO:
        logger.info("\(String(cString: msg))")
    default:
        logger.debug("\(String(cString: msg))")
    }
}

public protocol VIPSLoggingDelegate: AnyObject {
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
}

public enum VIPS {
    
    
    
    public static func start(concurrency: Int = 0, logger: Logger = Logger(label: "VIPS"), loggingDelegate: VIPSLoggingDelegate? = nil) throws {
        if vips_init(CommandLine.arguments[0]) != 0 {
            throw VIPSError(vips_error_buffer())
        }

        vips_concurrency_set(Int32(concurrency))
        
        logger.info("Using concurrency: \(concurrency)")

        #if DEBUG
        vips_leak_set(1)
        #endif
        
        logger.info("Vips: \(String(cString: vips_version_string()))")
        
        if let loggingDelegate = loggingDelegate {
            let box = Unmanaged.passRetained(loggingDelegate as AnyObject)
            
            g_log_set_handler("VIPS", G_LOG_LEVEL_MASK, logfunc, box.toOpaque())
        }
        
    }
    
    public static func shutdown() {
        vips_shutdown()
    }
}

public enum VIPSSize {
    case up, down, both
    
    var vipsSize: VipsSize {
        switch self {
        case .up: return VIPS_SIZE_UP
        case .down: return VIPS_SIZE_DOWN
        case .both: return VIPS_SIZE_BOTH
        }
    }
}

public enum VIPSInteresting {
    case none, centre, entropy, attention
    
    var vipsInteresting: VipsInteresting {
        switch self {
        case .none: return VIPS_INTERESTING_NONE
        case .centre: return VIPS_INTERESTING_CENTRE
        case .entropy: return VIPS_INTERESTING_ENTROPY
        case .attention: return VIPS_INTERESTING_ATTENTION
        }
    }
}

public struct VIPSOption {
    var pairs: [Pair] = []
    
    public init() {
        self.pairs = []
    }
    
    public mutating func set(_ name: String, value: Bool) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, shim_g_type_boolean())
        g_value_set_boolean(&pair.value, value ? 1 : 0)
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: UnsafeMutablePointer<VipsBlob>!) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_blob_get_type())
        g_value_set_boxed(&pair.value, value)
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: UnsafeMutablePointer<VipsSource>!) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_source_get_type())
        g_value_set_object(&pair.value, value)
        self.pairs.append(pair)
    }
    
    // output
    public mutating func set(_ name: String, value: UnsafeMutablePointer<UnsafeMutablePointer<VipsImage>?>!) {
        let pair = Pair(name: name, input: false)
        g_value_init(&pair.value, vips_image_get_type())
        pair.output = .image(value)
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>>!) {
        let pair = Pair(name: name, input: false)
        g_value_init(&pair.value, shim_VIPS_TYPE_BLOB())
        pair.output = .blob(value)
        self.pairs.append(pair)
    }
    
    
    
    public mutating func set(_ name: String, value: UnsafeMutablePointer<Double>!) {
        let pair = Pair(name: name, input: false)
        g_value_init(&pair.value, shim_G_TYPE_DOUBLE())
        pair.output = .double(value)
        self.pairs.append(pair)
    }
    
    
    
    public mutating func set(_ name: String, value: UnsafeMutablePointer<Int>!) {
        let pair = Pair(name: name, input: false)
        g_value_init(&pair.value, shim_G_TYPE_INT())
        pair.output = .integer(value)
        self.pairs.append(pair)
    }
    
    // input
    public mutating func set(_ name: String, value: UnsafeMutablePointer<VipsImage>!) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_image_get_type())
        g_value_set_object(&pair.value, value)
        self.pairs.append(pair)
    }
    
    // input
    public mutating func set(_ name: String, value: UnsafeMutablePointer<VipsTarget>!) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_target_get_type())
        g_value_set_object(&pair.value, value)
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: [VIPSImage]) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_array_image_get_type())
        vips_value_set_array_image(&pair.value, Int32(value.count))
        
        let array = vips_value_get_array_image(&pair.value, nil)
        
        let buffer = UnsafeMutableBufferPointer(start: array, count: value.count)
        for (i, image) in value.enumerated() {
            buffer[i] = image.image
            g_object_ref(image.image)
        }
        
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: String) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, shim_G_TYPE_STRING())
        value.withCString {
            g_value_set_string(&pair.value, $0)
        }
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: Double) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, shim_G_TYPE_DOUBLE())
        g_value_set_double(&pair.value, value)
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: Double?) {
        guard let v = value else { return }
        self.set(name, value: v)
    }
    
    public mutating func set(_ name: String, value: Array<Double>!) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, shim_VIPS_TYPE_ARRAY_DOUBLE())
        vips_value_set_array_double(&pair.value, nil, Int32(value.count))
        
        let array = vips_value_get_array_double(&pair.value, nil)
        
        let buffer = UnsafeMutableBufferPointer<Double>(start: array, count: value.count)
        for i in 0..<value.count {
            buffer[i] = value[i]
        }
        
        self.pairs.append(pair)
    }
    
    public mutating func set(_ name: String, value: Array<Int>) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, shim_VIPS_TYPE_ARRAY_INT())
        vips_value_set_array_int(&pair.value, nil, Int32(value.count))
        
        let array = vips_value_get_array_int(&pair.value, nil)
        
        let buffer = UnsafeMutableBufferPointer<Int32>(start: array, count: value.count)
        for i in 0..<value.count {
            buffer[i] = Int32(value[i])
        }
        
        self.pairs.append(pair)
    }
    
    public mutating func set<V>(_ name: String, value: V) where V : BinaryInteger {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, shim_G_TYPE_INT())
        g_value_set_int(&pair.value, gint(value))
        self.pairs.append(pair)
    }
    
    public mutating func set<V>(_ name: String, value: V?) where V : BinaryInteger {
        guard let v = value else { return }
        self.set(name, value: v)
    }
    
    public mutating func set(_ name: String, value: VipsBandFormat)  {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_band_format_get_type())
        g_value_set_enum(&pair.value, gint(value.rawValue))
        self.pairs.append(pair)
    }
    
    public mutating func set<V>(_ name: String, value: V) where V: RawRepresentable, V.RawValue : BinaryInteger {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, shim_G_TYPE_INT())
        g_value_set_int(&pair.value, gint(value.rawValue))
        self.pairs.append(pair)
    }
}

final class VIPSOperation {
    var op: UnsafeMutablePointer<VipsOperation>!
    
    init(name: String) throws {
        let op = vips_operation_new(name)
        guard op != nil else { throw VIPSError() }
        self.op = op
    }
    
    init(name: UnsafePointer<CChar>!) throws {
        let op = vips_operation_new(name)
        guard op != nil else { throw VIPSError() }
        self.op = op
    }
    
    func setFromString(options: String) throws {
        guard vips_object_set_from_string( shim_vips_object( self.op ), options) == 0 else {
            throw VIPSError()
        }
    }
    
    func set(option: VIPSOption) {
        for pair in option.pairs where pair.input == true {
            g_object_set_property( shim_g_object(op) , pair.name, &pair.value)
        }
    }
    
    func get(option: inout VIPSOption) {
        for i in 0..<option.pairs.count {
            if option.pairs[i].input == true { continue }
            g_object_get_property( shim_g_object(self.op) , option.pairs[i].name, &option.pairs[i].value)
            switch option.pairs[i].output {
            case .some(.image(let image)):
                let obj = shim_vips_image( g_value_get_object(&option.pairs[i].value) )
                image.pointee = obj!
            case .some(.double(let value)):
                value?.pointee = g_value_get_double(&option.pairs[i].value)
            case .some(.blob(let blob)):
                blob.pointee = g_value_get_boxed(&option.pairs[i].value).assumingMemoryBound(to: VipsBlob.self)
            case .some(.integer(let value)):
                value?.pointee = Int(g_value_get_int(&option.pairs[i].value))
            case .none:
                assertionFailure("no output specified for output value")
            }
        }
    }
    
    deinit {
        guard self.op != nil else { return }
        vips_object_unref_outputs( shim_vips_object(self.op) )
        g_object_unref(self.op)
    }
}

final class Pair {
    enum Output {
        case image(UnsafeMutablePointer<UnsafeMutablePointer<VipsImage>?>)
        case blob(UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>>)
        case double(UnsafeMutablePointer<Double>!)
        case integer(UnsafeMutablePointer<Int>!)
    }
    
    var name: String
    var value: GValue
    
    var input: Bool
    
    var output: Output?
    
    init(name: String, input: Bool) {
        self.name = name
        self.input = input
        self.value = GValue()
    }
    
    deinit {
        if input {
            g_value_unset(&self.value)
        }
    }
}

open class VIPSImage {
    
    private var other: Any? = nil
    
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
    
    public func copy(interpretation: VipsInterpretation) -> VIPSImage {
        return VIPSImage(nil) { out in
            shim_vips_copy_interpretation(self.image, &out, interpretation)
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
    
    public func resize(scale: Float) throws -> VIPSImage {
        let image = try VIPSImage(self) { out in
            var option = VIPSOption()
            option.set("out", value: &out)
            option.set("in", value: self.image)
            option.set("scale", value: Double(scale))
        
            try VIPSImage.call("resize", optionsString: nil, options: &option)
        }
        image.other = self
        return image
    }
    
    public func fit(width: Int, height: Int?, size: VIPSSize = .down) throws -> VIPSImage {
        let currentSize = self.size
        let ar =  Float(currentSize.width) / Float(currentSize.height)
        
        var bh: Int
        if let h = height {
            bh = h
        } else {
            bh = Int(Float(width) / ar)
        }
        
        let scaleX = Float(width) / Float(currentSize.width)
        let scaleY = Float(bh)    / Float(currentSize.height)
        
        func effective(scale: Float) -> Float {
            switch size {
            case .both:
                return scale
            case .down:
                return Swift.min(scale, 1.0)
            case .up:
                return Swift.max(scale, 1.0)
            }
        }
        
        if scaleX < scaleY {
            return try self.resize(scale: effective(scale: scaleX))
        } else {
            return try self.resize(scale: effective(scale: scaleY))
        }
        
    }
    
    public func thumbnailImage(width: Int, height: Int? = nil, crop: VIPSInteresting = .centre, size: VIPSSize = .both) throws -> VIPSImage {
        return try VIPSImage(self) { (out) in
            var option = VIPSOption()
            
            option.set("out", value: &out)
            option.set("in", value: self.image)
            option.set("width", value: width)
            if let height = height {
                option.set("height", value: height)
            }
            option.set("size", value: size.vipsSize)
            option.set("crop", value: crop.vipsInteresting)
	    
            try VIPSImage.call("thumbnail_image", options: &option)
        }
    }
    
    public static func thumbnail(buffer: UnsafeRawBufferPointer, width: Int, height: Int? = nil, crop: VIPSInteresting = .centre, size: VIPSSize = .both) throws -> VIPSImage {
        return try VIPSImage(nil) { out in
            
            let blob = vips_blob_new(nil, buffer.baseAddress!, buffer.count);
            defer {
                vips_area_unref(shim_vips_area(blob))
            }
            
            var options = VIPSOption()
            
            options.set("out", value: &out)
            options.set("buffer", value: blob)
            options.set("width", value: width)
            if let height = height {
                options.set("height", value: height)
            }
            options.set("size", value: size.vipsSize)
            options.set("crop", value: crop.vipsInteresting)
            
            try VIPSImage.call("thumbnail_buffer", options: &options)
        }
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
        return try VIPSImage(self) { out in
            
            var options = VIPSOption()
            
            options.set("in", value: self.image)
            options.set("out", value: &out)
            options.set("exponent", value: exponent)
            
            try VIPSImage.call("gamma", options: &options)
        }
    }
    
    deinit {
        g_object_unref(self.image)
    }
    
    static func call(_ name: UnsafePointer<CChar>!, optionsString: String? = nil, options: inout VIPSOption) throws {
        try self.call(String(cString: name), optionsString: optionsString, options: &options)
    }
    
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
    
    public init(fromFilePath path: String, access: VIPSAccess = .random) throws {
        guard let image = shim_vips_image_new_from_file(path, access.cVipsAccess) else {
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
}

extension VIPSImage {
    public static func tonelut(
        inMax: Int? = nil,
        outMax: Int? = nil,
        blackPoint lb: Double? = nil,
        whitePoint lw: Double? = nil,
        shadowPoint ps: Double? = nil,
        midTonePoint pm: Double? = nil,
        highlightPoint ph: Double? = nil,
        shadowAdjustment s: Double? = nil,
        midToneAdjustment m: Double? = nil,
        highlightAdjustment h: Double? = nil
    ) throws -> VIPSImage {
        return try VIPSImage(nil) { out in
            var opt = VIPSOption()
            
            opt.set("out", value: &out)
            
            opt.set("in_max", value: inMax)
            opt.set("out_max", value: outMax)
            opt.set("Lb", value: lb)
            opt.set("Lw", value: lw)
            opt.set("Ps", value: ps)
            opt.set("Pm", value: pm)
            opt.set("Ph", value: ph)
            opt.set("S", value: s)
            opt.set("M", value: m)
            opt.set("H", value: h)
            
            try VIPSImage.call("tonelut", optionsString: nil, options: &opt)
        }
    }
    
    
    public func maplut(_ lut: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, lut], { out in
            
            var opt = VIPSOption()
            
            opt.set("out", value: &out)
            opt.set("lut", value: lut.image)
            opt.set("in", value: self.image)
            
            try VIPSImage.call("maplut", optionsString: nil, options: &opt)
        })
    }
    
    public func cast(_ format: VipsBandFormat, shift: Bool = false) throws -> VIPSImage {
        return try VIPSImage(self, { out in
            
            var opt = VIPSOption()
            
            opt.set("out", value: &out)
            opt.set("format", value: format)
            opt.set("in", value: self.image)
            opt.set("shift", value: shift)
            
            try VIPSImage.call("cast", optionsString: nil, options: &opt)
        })
    }
    
    public func colourspace(_ colourspace: VipsInterpretation, sourceSpace: VipsInterpretation? = nil) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("out", value: &out)
            opt.set("in", value: self.image)
            opt.set("space", value: colourspace)
            if let sourceSpace = sourceSpace {
                opt.set("source_space", value: sourceSpace)
            }
            
            try VIPSImage.call("colourspace", optionsString: nil, options: &opt)
        }
    }
    
    public func extractBand(_ band: Int) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("band", value: band)
            
            try VIPSImage.call("extract_band", options: &opt)
        }
    }
    
    public func bandjoin<Images: Collection>(_ other: Images) throws -> VIPSImage where Images.Element == VIPSImage {
        return try VIPSImage([self, other]) { out in
            
            var opt = VIPSOption()
            opt.set("in", value: [ self ] + other)
            opt.set("out", value: &out)
            
            try VIPSImage.call("bandjoin", options: &opt)
        }
    }
    
    public subscript(band: Int) -> VIPSImage? {
        return try? self.extractBand(band)
    }
}


extension VIPSImage {
    public struct Size {
        public var width: Int
        public var height: Int
        
        public init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }
    
    public var size: Size {
        return Size(width: Int(vips_image_get_width(self.image)),
                    height: Int(vips_image_get_height(self.image)))
    }
    
    public func average() throws -> Double {
        var options = VIPSOption()
        
        var out: Double = 0
        
        options.set("in", value: self.image)
        options.set("out", value: &out)
        try VIPSImage.call("avg", options: &options)
        
        return out
    }
    
    public func autorotate() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var options = VIPSOption()
            options.set("in", value: self.image)
            options.set("out", value: &out)
            
            try VIPSImage.call("autorot", options: &options)
        }
    }
    
    public var bands: Int {
        Int(vips_image_get_bands(self.image))
    }
    
    public var orientation: Int {
        Int(shim_vips_exif_orientation(self.image))
    }
    
    public var space: String {
        return String(cString: vips_enum_nick(vips_interpretation_get_type(), self.image.pointee.Type.rawValue))
    }
    
    public var hasAlpha: Bool {
        return (vips_image_hasalpha(self.image) != 0)
    }
    
    public var hasProfile: Bool {
        return vips_image_get_typeof(self.image, SHIM_VIPS_META_ICC_NAME) != 0;
    }
    
    public func exportJpeg(quality: Int? = nil, to target: VIPSCustomTarget) throws {
        guard let name = vips_foreign_find_save_target(".jpg") else {
            throw VIPSError()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        if let q = quality { options.set("Q", value: q) }
        options.set("target", value: shim_VIPS_TARGET(target.target))
        
        try VIPSImage.call(name, options: &options)
    }
    
    public func exportedJpeg(quality: Int? = nil, optimizeCoding: Bool = false, interlace: Bool = false, strip: Bool = false) throws -> [UInt8] {
        guard let name = vips_foreign_find_save_buffer(".jpg") else {
            throw VIPSError()
        }
        
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>>.allocate(capacity: 1)
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
    
    public func exported(suffix: String, quality: Int? = nil) throws -> [UInt8] {
        guard let name = vips_foreign_find_save_buffer(suffix) else {
            throw VIPSError()
        }
        
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>>.allocate(capacity: 1)
        defer {
            outBuf.deallocate()
        }
        
        var options = VIPSOption()
        options.set("in", value: self.image)
        if let q = quality { options.set("Q", value: q) }
        options.set("buffer", value: outBuf)
        
        try VIPSImage.call(name, options: &options)
        
        let blob = outBuf.pointee
        let areaPtr = shim_vips_area(blob)
        let buffer = UnsafeRawBufferPointer(start: areaPtr!.pointee.data, count: Int(areaPtr!.pointee.length))
        
        defer { vips_area_unref(shim_vips_area(blob)) }
        
        return Array(buffer)
    }
    
    public func exportedHeif(quality: Int? = nil, lossless: Bool = false) throws -> [UInt8] {
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>>.allocate(capacity: 1)
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
    
    public func exportedPNG() throws -> [UInt8] {
        let outBuf = UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>>.allocate(capacity: 1)
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

public class VIPSSource {
    var source: UnsafeMutablePointer<VipsSource>!
    
    public init(_ source: UnsafeMutablePointer<VipsSource>!) {
        self.source = source
        g_object_ref(self.source)
    }
    
    public init(fromFile path: String) throws {
        guard let source = vips_source_new_from_file(path) else {
            throw VIPSError()
        }
        
        self.source = source
    }
    
    deinit {
        g_object_unref(self.source)
    }
    
    public func findLoader() throws -> String {
        guard let loader = vips_foreign_find_load_source(self.source) else {
            throw VIPSError()
        }
        return String(cString: loader)
    }
    
    public func rewind() throws {
        guard vips_source_rewind(self.source) == 0 else { throw VIPSError() }
    }
    
    public func withMappedMemory<T>(_ work: (UnsafeRawBufferPointer) throws -> T) throws -> T {
        var length: Int = 0
        let ptr = vips_source_map(self.source, &length)
        if (ptr == nil) {
            throw VIPSError()
        }
        return try work(UnsafeRawBufferPointer(start: ptr, count: length))
    }
}

public final class VIPSCustomTarget {
    var target: UnsafeMutablePointer<VipsTargetCustom>!
    
    var writer: ([UInt8]) -> Int = { _ in return 0 }
    var finisher: () -> () = {  }
    
    public init() {
        self.target = vips_target_custom_new()
    }
    
    typealias WriteHandle = @convention(c) (UnsafeMutablePointer<VipsTargetCustom>?, gpointer, Int64, gpointer ) -> Int64
    
    
    private func _onWrite(_ handle: @escaping WriteHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.target, "write", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    public func onWrite(_ handler: @escaping ([UInt8]) -> Int) {
        self.writer = handler
        
        let data = Unmanaged<VIPSCustomTarget>.passUnretained(self).toOpaque()
        
        self._onWrite({ _, buf, len, data in
            let me = Unmanaged<VIPSCustomTarget>.fromOpaque(data).takeUnretainedValue()
            
            let bufferPtr = buf.assumingMemoryBound(to: UInt8.self)
            let buffer = UnsafeMutableBufferPointer(start: bufferPtr, count: Int(len))
            
            let bytes = Array(buffer)
            
            return Int64(me.writer(bytes))
            
        }, userInfo: data)
    }
    
    public func onFinish(_ handler: @escaping () -> ()) {
        self.finisher = handler
        let data = Unmanaged<VIPSCustomTarget>.passUnretained(self).toOpaque()
        
        let _onFinish : () -> () = {
            let me = Unmanaged<VIPSCustomTarget>.fromOpaque(data).takeUnretainedValue()
            me.finisher()
        }
        
        shim_g_signal_connect(self.target, "finish", shim_G_CALLBACK(unsafeBitCast(_onFinish, to: UnsafeMutableRawPointer.self)), data);
    }
}


public final class VIPSSourceCustom : VIPSSource {
    private var customSource: UnsafeMutablePointer<VipsSourceCustom>!
    
    var reader:  (Int, inout [UInt8]) -> () = { _, _ in }
    var unsafeRader: (UnsafeMutableRawBufferPointer) -> Int = {_ in 0 }
    
    var _onDeinit: () -> () = { }
    
    public init() {
        let source = vips_source_custom_new()
        super.init(shim_VIPS_SOURCE(source))
        self.customSource = source
        g_object_unref(source)
    }
    
    typealias ReadHandle = @convention(c) (UnsafeMutablePointer<VipsSourceCustom>?, UnsafeMutableRawPointer, Int64, gpointer ) -> Int64
    
    
    private func _onRead(_ handle: @escaping ReadHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.source, "read", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    public func onUnsafeRead(_ handle: @escaping (UnsafeMutableRawBufferPointer) -> Int) {
        self.unsafeRader = handle
        let selfptr = Unmanaged<VIPSSourceCustom>.passUnretained(self).toOpaque()
        
        
        self._onRead({ _, buf, length, obj in
            let me = Unmanaged<VIPSSourceCustom>.fromOpaque(obj).takeUnretainedValue()
            
            let buffer = UnsafeMutableRawBufferPointer.init(start: buf, count: Int(length))
            return Int64(me.unsafeRader(buffer))
        }, userInfo: selfptr)
    }
    
    public func onRead(_ handle: @escaping (Int, inout [UInt8]) -> ()) {
        self.reader = handle
        
        let selfptr = Unmanaged<VIPSSourceCustom>.passUnretained(self).toOpaque()
        
        
        _onRead({ _, buf, length, obj in
            var buffer = [UInt8]()
            
            let me = Unmanaged<VIPSSourceCustom>.fromOpaque(obj).takeUnretainedValue()
            
            me.reader(Int(length), &buffer)
            
            guard buffer.count <= length else {
                fatalError("Trying to copy too much data")
            }
            
            buf.copyMemory(from: buffer, byteCount: buffer.count)
            return Int64(buffer.count)
        }, userInfo: selfptr)
    }
    
    public func onDeinit(_ work: @escaping () -> ()) {
        self._onDeinit = work
    }
    
    deinit {
        self._onDeinit()
    }
}


public func vipsFindLoader(path: String) -> String? {
    guard let cstring = vips_foreign_find_load(path) else {
        return nil
    }
    
    return String(cString: cstring)
}

extension Collection where Element == UInt8 {
    public func vips_findLoader() throws -> String {
        let maybeResult = try self.withContiguousStorageIfAvailable { ptr -> String in
            if let cstring = vips_foreign_find_load_buffer(ptr.baseAddress, ptr.count) {
                return String(cString: cstring)
            } else {
                throw VIPSError()
            }
        }
        
        if let res = maybeResult {
            return res
        } else {
            let array = Array(self)
            guard let cstring = array.withUnsafeBytes({ ptr in
                vips_foreign_find_load_buffer(ptr.baseAddress!, ptr.count)
            }) else {
                throw VIPSError()
            }
            return String(cString: cstring)
        }
    }
}


extension VIPS {
    public static func findLoader(filename: String) -> String? {
        guard let cloader = vips_foreign_find_load(filename) else {
            return nil
        }
        
        return String(cString: cloader)
    }
    
    public static func findLoader<Buffer: Sequence>(buffer: Buffer) throws -> String  where Buffer.Element == UInt8 {
        let maybeResult = try buffer.withContiguousStorageIfAvailable { ptr -> String in
            if let cstring = vips_foreign_find_load_buffer(ptr.baseAddress, ptr.count) {
                return String(cString: cstring)
            } else {
                throw VIPSError()
            }
        }
        
        if let res = maybeResult {
            return res
        } else {
            let array = Array(buffer)
            guard let cstring = array.withUnsafeBytes({ ptr in
                vips_foreign_find_load_buffer(ptr.baseAddress!, ptr.count)
            }) else {
                throw VIPSError()
            }
            return String(cString: cstring)
        }
    }
}


public enum VIPSAccess {
    case random
    case sequential
    case sequentialUnbuffered
    case last
    
    var cVipsAccess: VipsAccess {
        switch self {
        case .random: return VIPS_ACCESS_RANDOM
        case .sequential: return VIPS_ACCESS_SEQUENTIAL
        case .sequentialUnbuffered: return VIPS_ACCESS_SEQUENTIAL_UNBUFFERED
        case .last: return VIPS_ACCESS_LAST
        }
    }
}

