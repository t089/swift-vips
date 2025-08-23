import Cvips
import CvipsShim

#if SHIM_VIPS_VERSION_8_17
// VipsSdfShape is not available in the current version of libvips
// Commenting out until the library is updated

public typealias VipsSdfShape = Cvips.VipsSdfShape

extension VipsSdfShape {
    public static var circle: Self { VIPS_SDF_SHAPE_CIRCLE }
    public static var box: Self { VIPS_SDF_SHAPE_BOX }
    public static var roundedBox: Self { VIPS_SDF_SHAPE_ROUNDED_BOX }
    public static var line: Self { VIPS_SDF_SHAPE_LINE }
    public static var last: Self { VIPS_SDF_SHAPE_LAST }
}
#endif