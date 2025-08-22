import Cvips

public struct HeifCompression: Hashable {
    public static var av1 : Self { Self(compression: VIPS_FOREIGN_HEIF_COMPRESSION_AV1) }
    public static var hevc : Self { Self(compression: VIPS_FOREIGN_HEIF_COMPRESSION_HEVC) }
    public static var avc : Self { Self(compression: VIPS_FOREIGN_HEIF_COMPRESSION_AVC) }
    public static var jpeg : Self { Self(compression: VIPS_FOREIGN_HEIF_COMPRESSION_JPEG) }

    public init(compression: VipsForeignHeifCompression) {
        self.cVipsCompression = compression
    }

    public var cVipsCompression: VipsForeignHeifCompression

    public func hash(into hasher: inout Hasher) {
        hasher.combine(cVipsCompression.rawValue)
    }

    public static func == (lhs: HeifCompression, rhs: HeifCompression) -> Bool {
        return lhs.cVipsCompression == rhs.cVipsCompression
    }
}


public struct HeifEncoder: Hashable {
    public static var auto : Self { Self(encoder: VIPS_FOREIGN_HEIF_ENCODER_AUTO) }
    public static var aom : Self { Self(encoder: VIPS_FOREIGN_HEIF_ENCODER_AOM) }
    public static var rav1e : Self { Self(encoder: VIPS_FOREIGN_HEIF_ENCODER_RAV1E) }
    public static var svt : Self { Self(encoder: VIPS_FOREIGN_HEIF_ENCODER_SVT) }
    public static var x265 : Self { Self(encoder: VIPS_FOREIGN_HEIF_ENCODER_X265) }

    public var encoder: VipsForeignHeifEncoder
    
    public init(encoder: VipsForeignHeifEncoder) {
        self.encoder = encoder
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(encoder.rawValue)
    }

    public static func == (lhs: HeifEncoder, rhs: HeifEncoder) -> Bool {
        return lhs.encoder == rhs.encoder
    }
}

public struct ForeignSubsample: Hashable {
    public static var auto : Self { Self(mode: VIPS_FOREIGN_SUBSAMPLE_AUTO) }
    public static var on : Self { Self(mode: VIPS_FOREIGN_SUBSAMPLE_ON) }
    public static var off : Self { Self(mode: VIPS_FOREIGN_SUBSAMPLE_OFF) }

    public var mode: VipsForeignSubsample

    public init(mode: VipsForeignSubsample) {
        self.mode = mode
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(mode.rawValue)
    }

    public static func == (lhs: ForeignSubsample, rhs: ForeignSubsample) -> Bool {
        return lhs.mode == rhs.mode
    }
}