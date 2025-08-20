import Cvips
import CvipsShim

extension VipsBandFormat {
    public static var notset: Self { VIPS_FORMAT_NOTSET }
    public static var uchar: Self { VIPS_FORMAT_UCHAR }
    public static var char: Self { VIPS_FORMAT_CHAR }
    public static var ushort: Self { VIPS_FORMAT_USHORT }
    public static var short: Self { VIPS_FORMAT_SHORT }
    public static var uint: Self { VIPS_FORMAT_UINT }
    public static var int: Self { VIPS_FORMAT_INT }
    public static var float: Self { VIPS_FORMAT_FLOAT }
    public static var complex: Self { VIPS_FORMAT_COMPLEX }
    public static var double: Self { VIPS_FORMAT_DOUBLE }
    public static var dpcomplex: Self { VIPS_FORMAT_DPCOMPLEX }
    public static var last: Self { VIPS_FORMAT_LAST }
}