import VIPS
import Cvips
import Foundation

guard CommandLine.arguments.count > 2 else {
    print("Usage: \(CommandLine.arguments[0]) PATH TEXT")
    exit(1)
}


let im = try VIPSImage(fromFilePath: CommandLine.arguments[1])

var text = try VIPSImage.text(CommandLine.arguments[2], font: "sans bold 12", align: .centre, dpi: 72)

print(text.size)


text = try (text * 0.4).cast(VIPS_FORMAT_UCHAR)
try Data(try text.exportedPNG()).write(to: URL(fileURLWithPath: "/tmp/swift-vips/out_text_test.png"))
text = try text
            .rotate(-45)
            .gravity(direction: VIPS_COMPASS_DIRECTION_CENTRE, width: 300, height: 300)
            .replicate(across: 1 + im.size.width / text.size.width, down: 1 + im.size.height / text.size.height)
            .crop(left: 0, top: 0, width: im.size.width, height: im.size.height)

let overlay = try text.new([255, 128, 128])
    .copy(interpretation: VIPS_INTERPRETATION_sRGB)
    .bandjoin([text])

let out = try im.composite(overlay: overlay, mode: VIPS_BLEND_MODE_OVER)

let jpeg = try out.exportedPNG()
try Data(jpeg).write(to: URL(fileURLWithPath: "/tmp/swift-vips/out_text_exported.jpg"))

