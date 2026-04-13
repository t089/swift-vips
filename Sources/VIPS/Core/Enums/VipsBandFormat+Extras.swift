import Cvips
import CvipsShim

extension VipsBandFormat {
    /// The maximum numeric value possible for this band format.
    ///
    /// Returns the largest value that can be represented in this format.
    /// For example:
    /// - `.uchar` returns 255
    /// - `.ushort` returns 65535
    /// - `.float` returns 1.0
    ///
    /// - Returns: The maximum value for this format
    public var max: Double {
        return vips_image_get_format_max(self)
    }
}
