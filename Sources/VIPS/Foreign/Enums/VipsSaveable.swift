import Cvips
import CvipsShim

// VipsSaveable was removed in libvips 8.17.0 and replaced with VipsForeignSaveable.
// CvipsShim provides a backwards compatibility layer for 8.17+ that recreates
// the old VipsSaveable enum by mapping to VipsForeignSaveable flags.
extension VipsSaveable {
    public static var mono: Self { VIPS_SAVEABLE_MONO }
    public static var rgb: Self { VIPS_SAVEABLE_RGB }
    public static var rgba: Self { VIPS_SAVEABLE_RGBA }
    public static var rgbaOnly: Self { VIPS_SAVEABLE_RGBA_ONLY }
    public static var rgbCmyk: Self { VIPS_SAVEABLE_RGB_CMYK }
    public static var any: Self { VIPS_SAVEABLE_ANY }
    public static var last: Self { VIPS_SAVEABLE_LAST }
}