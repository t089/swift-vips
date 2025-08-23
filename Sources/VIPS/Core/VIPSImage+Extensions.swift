import Cvips
import CvipsShim

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
    
    public var width: Int {
        return Int(vips_image_get_width(self.image))
    }
    
    public var height: Int {
        return Int(vips_image_get_height(self.image))
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
        let iccName = "icc-profile-data"
        return vips_image_get_typeof(self.image, iccName) != 0;
    }
    
    public var format: VipsBandFormat {
        return vips_image_get_format(self.image)
    }

    public var interpretation: VipsInterpretation {
        return vips_image_get_interpretation(self.image)
    }

    public func getpoint(_ x: Int, _ y: Int) throws -> [Double] {
        try self.getpoint(x: x, y: y)
    }
}

extension VipsBandFormat {
    public var max: Double {
        return vips_image_get_format_max(self)
    }
}