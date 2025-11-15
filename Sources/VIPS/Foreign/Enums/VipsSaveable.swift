import Cvips
import CvipsShim

// VipsSaveable was removed in libvips 8.17.0 and replaced with VipsForeignSaveable.
// CvipsShim provides the VipsSaveable typedef and constants for 8.17+.
// We use a Swift typealias that works with both the native enum (pre-8.17)
// and our shim typedef (8.17+), since both are compatible with UInt32/CInt.

public typealias VipsSaveable = UInt32

public extension VipsSaveable {
    static var mono: Self { VIPS_SAVEABLE_MONO.rawValue }
    static var rgb: Self { VIPS_SAVEABLE_RGB.rawValue }
    static var rgba: Self { VIPS_SAVEABLE_RGBA.rawValue }
    static var rgbaOnly: Self { VIPS_SAVEABLE_RGBA_ONLY.rawValue }
    static var rgbCmyk: Self { VIPS_SAVEABLE_RGB_CMYK.rawValue }
    static var any: Self { VIPS_SAVEABLE_ANY.rawValue }
    static var last: Self { VIPS_SAVEABLE_LAST.rawValue }
}