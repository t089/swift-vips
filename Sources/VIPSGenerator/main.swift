import Foundation

@main
struct VIPSGenerator {
    static func main() {
        print("🔍 Discovering VIPS operations...")
        
        let operations = VIPSOperationDiscovery.discoverAllOperations()
        print("✅ Found \(operations.count) operations")
        
        // Group operations by category
        var operationsByCategory: [String: [VIPSOperationInfo]] = [:]
        
        for operation in operations {
            if operationsByCategory[operation.category] == nil {
                operationsByCategory[operation.category] = []
            }
            operationsByCategory[operation.category]?.append(operation)
        }
        
        let categories = operationsByCategory.keys.sorted()
        
        print("\n📁 Categories found:")
        for category in categories {
            let count = operationsByCategory[category]?.count ?? 0
            print("   - \(category): \(count) operations")
        }
        
        // Create output directory structure
        let baseOutputDir = "Sources/VIPS/Generated"
        try? FileManager.default.createDirectory(atPath: baseOutputDir, withIntermediateDirectories: true)
        
        // Generate code for each category
        print("\n📝 Generating Swift code...")
        
        for category in categories {
            guard let categoryOps = operationsByCategory[category] else { continue }
            
            // Create subdirectory for nested categories (e.g., Foreign/JPEG)
            let categoryPath = category.split(separator: "/").map(String.init)
            var outputDir = baseOutputDir
            
            if categoryPath.count > 1 {
                outputDir = "\(baseOutputDir)/\(categoryPath[0])"
                try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            }
            
            let code = SwiftCodeGenerator.generateSwiftFile(operations: categoryOps, category: category)
            
            // Generate filename from category
            let fileName = category
                .replacingOccurrences(of: "/", with: "_")
                .lowercased() + ".generated.swift"
            
            let filePath = "\(outputDir)/\(fileName)"
            
            do {
                try code.write(toFile: filePath, atomically: true, encoding: .utf8)
                print("   ✅ Generated \(filePath) (\(categoryOps.count) operations)")
            } catch {
                print("   ❌ Failed to write \(filePath): \(error)")
            }
        }
        
        // Generate a summary file
        generateSummaryFile(categories: categories, operationsByCategory: operationsByCategory)
        
        print("\n🎉 Code generation complete!")
        print("\n📊 Summary:")
        print("   Total operations: \(operations.count)")
        print("   Total categories: \(categories.count)")
        
        // List operations that might need manual review
        let complexOperations = operations.filter { op in
            op.arguments.contains { arg in
                arg.swiftType == "Any" && !arg.isDeprecated
            }
        }
        
        if !complexOperations.isEmpty {
            print("\n⚠️  Operations with complex types that may need manual review:")
            for op in complexOperations.prefix(10) {
                print("   - \(op.nickname)")
            }
            if complexOperations.count > 10 {
                print("   ... and \(complexOperations.count - 10) more")
            }
        }
    }
    
    static func generateSummaryFile(categories: [String], operationsByCategory: [String: [VIPSOperationInfo]]) {
        var content = """
        # Generated VIPS Operations
        
        This directory contains automatically generated Swift wrappers for libvips operations.
        Generated on: \(Date())
        
        ## Categories
        
        """
        
        for category in categories {
            let count = operationsByCategory[category]?.count ?? 0
            content += "### \(category)\n"
            content += "- Operations: \(count)\n"
            
            if let ops = operationsByCategory[category] {
                content += "- Examples: \(ops.prefix(5).map { $0.nickname }.joined(separator: ", "))"
                if ops.count > 5 {
                    content += ", ..."
                }
                content += "\n"
            }
            content += "\n"
        }
        
        content += """
        
        ## Regenerating
        
        To regenerate these files, run:
        ```bash
        swift run vips-generator
        ```
        
        ## Implementation Notes
        
        - Operations are discovered using GObject introspection
        - Each operation is wrapped in a Swift-friendly API
        - Type conversions are handled automatically where possible
        - Complex types may require manual review
        
        """
        
        let summaryPath = "Sources/VIPS/Generated/README.md"
        try? content.write(toFile: summaryPath, atomically: true, encoding: .utf8)
    }
}

extension String {
    func write(toFile path: String, atomically: Bool, encoding: String.Encoding) throws {
        try self.write(to: URL(fileURLWithPath: path), atomically: atomically, encoding: encoding)
    }
}