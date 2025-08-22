import Cvips
import CvipsShim

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

    public mutating func set(_ name: String, value: VIPSObject) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, value.type)
        g_value_set_object(&pair.value, value.object)
        self.pairs.append(pair)
    }

    public mutating func set(_ name: String, value: [VipsBlendMode]) {
        self.set(name, value: value.map({ Int($0.rawValue )}))
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

    public mutating func set(_ name: String, value: UnsafeMutablePointer<Bool>!) {
        let pair = Pair(name: name, input: false)
        g_value_init(&pair.value, shim_g_type_boolean())
        pair.output = .boolean(value)
        self.pairs.append(pair)
    }
    
    // input
    public mutating func set(_ name: String, value: UnsafeMutablePointer<VipsImage>!) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_image_get_type())
        g_value_set_object(&pair.value, value)
        self.pairs.append(pair)
    }

    public mutating func set(_ name: String, value: VIPSImage) {
        set(name, value: value.image)
    }

    public mutating func set(_ name: String, value: UnsafeMutablePointer<VipsTarget>!) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_target_get_type())
        g_value_set_object(&pair.value, value)
        self.pairs.append(pair)
    }

    public mutating func set(_ name: String, value: VIPSTarget) {
        set(name, value: value.target)
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

    public mutating func set(_ name: String, value: VIPSInterpolate) {
        let pair = Pair(name: name, input: true)
        g_value_init(&pair.value, vips_interpolate_get_type())
        g_value_set_object(&pair.value, value.interpolate)
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

final class Pair {
    enum Output {
        case image(UnsafeMutablePointer<UnsafeMutablePointer<VipsImage>?>)
        case blob(UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>>)
        case double(UnsafeMutablePointer<Double>!)
        case integer(UnsafeMutablePointer<Int>!)
        case boolean(UnsafeMutablePointer<Bool>!)
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