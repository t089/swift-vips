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

        // Output directory for generated files (using URL-based API)
        let outputDir = context.pluginWorkDirectoryURL.appending(path: "Generated")
        let foreignDir = outputDir.appending(path: "Foreign")

        // Define all known output files - categories are deterministic
        // even if some might be empty for certain libvips builds
        let outputFiles: [URL] = [
            // Top-level categories
            outputDir.appending(path: "arithmetic.generated.swift"),
            outputDir.appending(path: "colour.generated.swift"),
            outputDir.appending(path: "conversion.generated.swift"),
            outputDir.appending(path: "convolution.generated.swift"),
            outputDir.appending(path: "create.generated.swift"),
            outputDir.appending(path: "freqfilt.generated.swift"),
            outputDir.appending(path: "histogram.generated.swift"),
            outputDir.appending(path: "misc.generated.swift"),
            outputDir.appending(path: "morphology.generated.swift"),
            outputDir.appending(path: "resample.generated.swift"),
            // Foreign subcategories
            foreignDir.appending(path: "foreign_gif.generated.swift"),
            foreignDir.appending(path: "foreign_heif.generated.swift"),
            foreignDir.appending(path: "foreign_jpeg.generated.swift"),
            foreignDir.appending(path: "foreign_other.generated.swift"),
            foreignDir.appending(path: "foreign_pdf.generated.swift"),
            foreignDir.appending(path: "foreign_png.generated.swift"),
            foreignDir.appending(path: "foreign_svg.generated.swift"),
            foreignDir.appending(path: "foreign_tiff.generated.swift"),
            foreignDir.appending(path: "foreign_webp.generated.swift"),
        ]

        // Use a build command - runs when outputs are missing or inputs changed
        // Since there are no file inputs (we introspect libvips at runtime),
        // this will run when outputs are missing (first build after clone)
        return [
            .buildCommand(
                displayName: "Generating VIPS Swift wrappers",
                executable: generator.url,
                arguments: [
                    "--output-dir", outputDir.path(),
                    "--verbose"
                ],
                inputFiles: [],
                outputFiles: outputFiles
            )
        ]
    }
}
