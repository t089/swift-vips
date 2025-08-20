import Cvips
import CvipsShim

extension VipsPCS {
    public static var lab: Self { VIPS_PCS_LAB }
    public static var xyz: Self { VIPS_PCS_XYZ }
    public static var last: Self { VIPS_PCS_LAST }
}