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

        // Output directory for generated files (using URL-based API)
        let outputDir = context.pluginWorkDirectoryURL.appending(path: "Generated")

        // Resolve the generator tool. In some build systems (notably Xcode)
        // the tool dependency may not be available during the prebuild phase.
        let generator: URL?
        do {
            generator = try context.tool(named: "vips-generator").url
        } catch {
            generator = nil
        }

        // If the tool is available, use it. Otherwise fall back to reusing
        // outputs from a previous CLI build (they live under the package's
        // `.build` directory, which is separate from Xcode's DerivedData).
        if let generator, FileManager.default.fileExists(atPath: generator.path) {
            // Discover output files by running the generator with --list-outputs
            let outputFiles = try discoverOutputFiles(
                generator: generator,
                outputDir: outputDir
            )

            // Use a build command - runs when outputs are missing or inputs changed
            // Since there are no file inputs (we introspect libvips at runtime),
            // this will run when outputs are missing (first build after clone)
            return [
                .buildCommand(
                    displayName: "Generating VIPS Swift wrappers",
                    executable: generator,
                    arguments: [
                        "--output-dir", outputDir.path(),
                        "--verbose"
                    ],
                    inputFiles: [],
                    outputFiles: outputFiles
                )
            ]
        }

        // Tool unavailable (e.g. Xcode could not stage it). Try to reuse
        // outputs produced by a previous `swift build` so the target still
        // compiles. The output files must be declared via a build command so
        // the build system knows to include them in the target.
        if importCachedOutputs(from: context, into: outputDir) {
            let outputFiles = generatedFiles(in: outputDir)
            return [
                .buildCommand(
                    displayName: "Using cached VIPS Swift wrappers",
                    executable: URL(fileURLWithPath: "/usr/bin/true"),
                    arguments: [],
                    inputFiles: [],
                    outputFiles: outputFiles
                )
            ]
        }

        throw PluginError.toolNotFound
    }

    /// Discover output files by running the generator with --list-outputs
    private func discoverOutputFiles(generator: URL, outputDir: URL) throws -> [URL] {
        let process = Process()
        process.executableURL = generator
        process.arguments = ["--list-outputs", "--output-dir", outputDir.path()]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe() // Suppress stderr

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw PluginError.generatorFailed(status: process.terminationStatus)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            throw PluginError.invalidGeneratorOutput
        }

        // Parse output - one file path per line
        let filePaths = output
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { URL(fileURLWithPath: $0) }

        return filePaths
    }

    /// Recursively collect all generated Swift files under an output dir.
    private func generatedFiles(in outputDir: URL) -> [URL] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: outputDir,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []
        for case let url as URL in enumerator {
            if url.pathExtension == "swift" {
                files.append(url)
            }
        }
        return files
    }

    /// Best-effort reuse of outputs produced by a previous `swift build`.
    /// The CLI plugin work directory lives under `.build/plugins/outputs/` in
    /// the package directory, which is separate from Xcode's DerivedData.
    /// Returns `true` if files were found and copied.
    private func importCachedOutputs(from context: PluginContext, into outputDir: URL) -> Bool {
        let packageDir = context.package.directoryURL
        let packageName = context.package.displayName

        // e.g. <package>/.build/plugins/outputs/<packageName>/VIPS/destination/
        let searchRoot = packageDir
            .appending(path: ".build/plugins/outputs")
            .appending(path: packageName)
            .appending(path: "VIPS/destination")

        let fileManager = FileManager.default

        // Locate any VIPSGeneratorPlugin/Generated directory below the root.
        guard let enumerator = fileManager.enumerator(
            at: searchRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return false
        }

        var sourceDir: URL? = nil
        for case let url as URL in enumerator {
            if url.lastPathComponent == "Generated"
                && url.pathComponents.contains("VIPSGeneratorPlugin")
            {
                sourceDir = url
                break
            }
        }

        guard let sourceDir else { return false }

        // Clear any partial outputs before copying.
        if fileManager.fileExists(atPath: outputDir.path) {
            do {
                try fileManager.removeItem(at: outputDir)
            } catch {
                return false
            }
        }

        do {
            try fileManager.copyItem(at: sourceDir, to: outputDir)
            return true
        } catch {
            return false
        }
    }
}

enum PluginError: Error {
    case toolNotFound
    case generatorFailed(status: Int32)
    case invalidGeneratorOutput
}
