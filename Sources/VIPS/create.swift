import Cvips

public enum VIPSAlign: _VipsEnumValue {
    public static var format: GType { vips_align_get_type() }

    public var rawValue: Int32 { Int32(vipsAlign.rawValue) }

    

    case low, centre, high, last

    var vipsAlign: VipsAlign {
        switch self {
            case .low: return VIPS_ALIGN_LOW
            case .centre: return VIPS_ALIGN_CENTRE
            case .high: return VIPS_ALIGN_HIGH
            case .last: return VIPS_ALIGN_LAST
        }
    }

    init(vipsAlign: VipsAlign) {
        switch vipsAlign {
            case VIPS_ALIGN_LOW: self = .low
            case VIPS_ALIGN_CENTRE: self = .centre
            case VIPS_ALIGN_HIGH: self = .high
            default: self = .last
        }
    }
}

public enum VIPSTextWrap: _VipsEnumValue {
    public static var format: GType { vips_text_wrap_get_type() }

    public var rawValue: Int32 { Int32(vipsTextWrap.rawValue) }

    case word, char, wordChar, none, last

    init(vipsTextWrap: VipsTextWrap) {
        switch vipsTextWrap {
            case VIPS_TEXT_WRAP_WORD: self = .word
            case VIPS_TEXT_WRAP_WORD_CHAR: self = .wordChar
            case VIPS_TEXT_WRAP_CHAR: self = .char
            case VIPS_TEXT_WRAP_NONE: self = .none
            default: self = .last
        }
    }

    var vipsTextWrap: VipsTextWrap {
        switch self {
            case .word: return VIPS_TEXT_WRAP_WORD
            case .char: return VIPS_TEXT_WRAP_CHAR
            case .wordChar: return VIPS_TEXT_WRAP_WORD_CHAR
            case .none: return VIPS_TEXT_WRAP_NONE
            case .last: return VIPS_TEXT_WRAP_NONE
        }
    }
}

extension VIPSImage {
    public static func text(
        _ text: String,
        font: String? = nil,
        fontFile: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        align: VIPSAlign? = nil,
        justify: Bool? = nil,
        dpi: Int? = nil,
        autofitDpi: Int? = nil,
        rgba: Bool? = nil,
        spacing: Int? = nil,
        wrap: VIPSTextWrap? = nil,
        options: String? = nil
    ) throws -> VIPSImage {
        try VIPSImage(nil) { out in 
            var opt = VIPSOption()
            opt.set("text", value: text)
            if let font {
                opt.set("font", value: font)
            }
            if let fontFile {
                opt.set("fontFile", value: fontFile)
            }
            if let width {
                opt.set("width", value: width)
            }
            if let height {
                opt.set("height", value: height)
            }
            if let align {
                opt.set("align", value: align)
            }
            if let justify {
                opt.set("justify", value: justify)
            }
            if let dpi {
                opt.set("dpi", value: dpi)
            }
            if let autofitDpi {
                opt.set("autofit_dpi", value: autofitDpi)
            }
            if let rgba {
                opt.set("rgba", value: rgba)
            }
            if let spacing {
                opt.set("spacing", value: spacing)
            }
            if let wrap {
                opt.set("wrap", value: wrap)
            }

            opt.set("out", value: &out)

            return try call("text", optionsString: options, options: &opt)
        }
    }
}