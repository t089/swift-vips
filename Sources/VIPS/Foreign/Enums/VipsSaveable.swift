import Cvips
import CvipsShim

// VipsSaveable was removed in libvips 8.17.0 and replaced with VipsForeignSaveable.
// In 8.17.3+, they added backwards compatibility macros, but Swift can't import them
// because they use bitwise OR. CvipsShim provides getter functions that work across
// all libvips versions by checking for the native enum/macros and falling back to
// VipsForeignSaveable flags.

public typealias VipsSaveable = UInt32

public extension VipsSaveable {
    static var mono: Self { UInt32(shim_VIPS_SAVEABLE_MONO()) }
    static var rgb: Self { UInt32(shim_VIPS_SAVEABLE_RGB()) }
    static var rgba: Self { UInt32(shim_VIPS_SAVEABLE_RGBA()) }
    static var rgbaOnly: Self { UInt32(shim_VIPS_SAVEABLE_RGBA_ONLY()) }
    static var rgbCmyk: Self { UInt32(shim_VIPS_SAVEABLE_RGB_CMYK()) }
    static var any: Self { UInt32(shim_VIPS_SAVEABLE_ANY()) }
    static var last: Self { UInt32(shim_VIPS_SAVEABLE_LAST()) }
}