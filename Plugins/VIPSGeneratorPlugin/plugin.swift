//
//  plugin.swift
//  VIPSGeneratorPlugin
//
//  Build tool plugin that generates Swift wrappers for libvips operations
//

import Foundation
import PackagePlugin

@main
struct VIPSGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // Only apply to the VIPS target
        guard target.name == "VIPS" else {
            return []
        }

        // Get the generator tool
        let generator = try context.tool(named: "vips-generator")

        // Output directory for generated files
        let outputDir = context.pluginWorkDirectory.appending("Generated")
        let foreignDir = outputDir.appending("Foreign")

        // Define all known output files - categories are deterministic
        // even if some might be empty for certain libvips builds
        let outputFiles: [Path] = [
            // Top-level categories
            outputDir.appending("arithmetic.generated.swift"),
            outputDir.appending("colour.generated.swift"),
            outputDir.appending("conversion.generated.swift"),
            outputDir.appending("convolution.generated.swift"),
            outputDir.appending("create.generated.swift"),
            outputDir.appending("freqfilt.generated.swift"),
            outputDir.appending("histogram.generated.swift"),
            outputDir.appending("misc.generated.swift"),
            outputDir.appending("morphology.generated.swift"),
            outputDir.appending("resample.generated.swift"),
            // Foreign subcategories
            foreignDir.appending("foreign_gif.generated.swift"),
            foreignDir.appending("foreign_heif.generated.swift"),
            foreignDir.appending("foreign_jpeg.generated.swift"),
            foreignDir.appending("foreign_other.generated.swift"),
            foreignDir.appending("foreign_pdf.generated.swift"),
            foreignDir.appending("foreign_png.generated.swift"),
            foreignDir.appending("foreign_svg.generated.swift"),
            foreignDir.appending("foreign_tiff.generated.swift"),
            foreignDir.appending("foreign_webp.generated.swift"),
        ]

        // Use a build command - runs when outputs are missing or inputs changed
        // Since there are no file inputs (we introspect libvips at runtime),
        // this will run when outputs are missing (first build after clone)
        return [
            .buildCommand(
                displayName: "Generating VIPS Swift wrappers",
                executable: generator.path,
                arguments: [
                    "--output-dir", outputDir.string,
                    "--verbose"
                ],
                inputFiles: [],
                outputFiles: outputFiles
            )
        ]
    }
}
