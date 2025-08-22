import Foundation
import Cvips
import CvipsIntrospection

// MARK: - Models

struct VIPSOperationInfo {
    let name: String
    let nickname: String
    let description: String
    let flags: VipsOperationFlags
    let arguments: [VIPSArgumentInfo]
    
    var category: String {
        // Extract category from operation name patterns
        let name = self.nickname.lowercased()
        
        // Foreign operations (file I/O)
        if name.contains("load") || name.contains("save") {
            // Further categorize by format
            if name.contains("jpeg") || name.contains("jpg") {
                return "Foreign/JPEG"
            } else if name.contains("png") {
                return "Foreign/PNG"
            } else if name.contains("webp") {
                return "Foreign/WebP"
            } else if name.contains("tiff") || name.contains("tif") {
                return "Foreign/TIFF"
            } else if name.contains("pdf") {
                return "Foreign/PDF"
            } else if name.contains("svg") {
                return "Foreign/SVG"
            } else if name.contains("heif") || name.contains("heic") {
                return "Foreign/HEIF"
            } else if name.contains("gif") {
                return "Foreign/GIF"
            } else {
                return "Foreign"
            }
        }
        
        // Arithmetic operations
        if ["add", "subtract", "multiply", "divide", "abs", "linear", "math", "complex", "remainder", "boolean", "relational", "round", "sign", "avg", "min", "max", "deviate", "sum", "invert"].contains(where: name.contains) {
            return "Arithmetic"
        }
        
        // Convolution operations
        if name.contains("conv") || name.contains("sharpen") || name.contains("blur") || name.contains("sobel") || name.contains("canny") || name.contains("gaussblur") {
            return "Convolution"
        }
        
        // Colour operations
        if name.contains("colour") || name.contains("color") || name.contains("lab") || name.contains("xyz") || name.contains("srgb") || name.contains("rgb") || name.contains("cmyk") || name.contains("hsv") || name.contains("lch") || name.contains("yxy") || name.contains("scrgb") {
            return "Colour"
        }
        
        // Conversion operations
        if ["resize", "rotate", "flip", "crop", "embed", "extract", "shrink", "reduce", "zoom", "affine", "similarity", "scale", "autorot", "rot", "recomb", "bandjoin", "bandrank", "bandsplit", "cast", "copy", "tilecache", "arrayjoin", "grid", "transpose", "wrap", "unpremultiply", "premultiply", "composite"].contains(where: name.contains) {
            return "Conversion"
        }
        
        // Create operations
        if ["black", "xyz", "grey", "mask", "gaussmat", "logmat", "text", "gaussnoise", "eye", "zone", "sines", "buildlut", "identity", "fractsurf", "radload", "tonelut", "worley", "perlin"].contains(where: name.contains) {
            return "Create"
        }
        
        // Draw operations
        if name.contains("draw") {
            return "Draw"
        }
        
        // Morphology operations
        if ["morph", "erode", "dilate", "median", "rank", "countlines", "labelregions"].contains(where: name.contains) {
            return "Morphology"
        }
        
        // Histogram operations
        if ["hist", "heq", "hough", "profile", "project", "spectrum", "phasecor"].contains(where: name.contains) {
            return "Histogram"
        }
        
        // Frequency domain operations
        if ["fft", "invfft", "freqmult", "spectrum", "phasecor"].contains(where: name.contains) {
            return "Freqfilt"
        }
        
        // Resample operations
        if ["shrink", "reduce", "resize", "thumbnail", "mapim", "quadratic"].contains(where: name.contains) {
            return "Resample"
        }
        
        // Default to misc
        return "Misc"
    }
    
    var isValid: Bool {
        // Filter out deprecated or internal operations
        if nickname.contains("_buffer") || nickname.contains("_stream") {
            return false
        }
        
        // Check if it has at least one output
        let hasOutput = arguments.contains { $0.isOutput }
        
        return hasOutput
    }
}

struct VIPSArgumentInfo {
    let name: String
    let type: GType
    let flags: VipsArgumentFlags
    let priority: Int
    let description: String?
    
    var isInput: Bool {
        return (flags.rawValue & VIPS_ARGUMENT_INPUT.rawValue) != 0
    }
    
    var isOutput: Bool {
        return (flags.rawValue & VIPS_ARGUMENT_OUTPUT.rawValue) != 0
    }
    
    var isRequired: Bool {
        return (flags.rawValue & VIPS_ARGUMENT_REQUIRED.rawValue) != 0
    }
    
    var isDeprecated: Bool {
        return (flags.rawValue & VIPS_ARGUMENT_DEPRECATED.rawValue) != 0
    }
    
    var swiftType: String {
        // Use our C helpers to check types
        if cvips_type_is_image(type) {
            return "VIPSImage"
        } else if cvips_type_is_array_double(type) {
            return "[Double]"
        } else if cvips_type_is_array_int(type) {
            return "[Int]"
        } else if cvips_type_is_array_image(type) {
            return "[VIPSImage]"
        } else if cvips_type_is_blob(type) {
            return "Data"
        }
        
        // Standard GObject types
        switch type {
        case G_TYPE_DOUBLE:
            return "Double"
        case G_TYPE_INT, G_TYPE_UINT:
            return "Int"
        case G_TYPE_BOOLEAN:
            return "Bool"
        case G_TYPE_STRING:
            return "String"
        default:
            // Check if it's an enum type
            if g_type_is_a(type, G_TYPE_ENUM) != 0 {
                if let typeName = cvips_get_type_name(type) {
                    let name = String(cString: typeName)
                    // Convert GType name to Swift enum name
                    return name
                }
            } else if g_type_is_a(type, G_TYPE_FLAGS) != 0 {
                if let typeName = cvips_get_type_name(type) {
                    let name = String(cString: typeName)
                    return name
                }
            }
            return "Any"
        }
    }
    
    var swiftParameterType: String {
        if isRequired && !isOutput {
            return swiftType
        } else if !isRequired && !isOutput {
            return "\(swiftType)?"
        } else {
            return swiftType
        }
    }
}

// MARK: - Operation Discovery

class VIPSOperationDiscovery {
    
    static func discoverAllOperations() -> [VIPSOperationInfo] {
        // Initialize VIPS if not already done
        if vips_init("vips-generator") != 0 {
            print("Failed to initialize VIPS")
            return []
        }
        
        var operations: [VIPSOperationInfo] = []
        
        // Get all operation names using our C helper
        var count: Int32 = 0
        guard let namesPtr = cvips_get_operation_names(&count) else {
            print("Failed to get operation names")
            return []
        }
        defer { cvips_free_string_array(namesPtr, count) }
        
        for i in 0..<Int(count) {
            guard let namePtr = namesPtr[i] else { continue }
            let name = String(cString: namePtr)
            
            if let operation = getOperationInfo(name: name) {
                if operation.isValid {
                    operations.append(operation)
                }
            }
        }
        
        return operations
    }
    
    private static func getOperationInfo(name: String) -> VIPSOperationInfo? {
        guard let infoPtr = cvips_get_operation_info(name) else {
            return nil
        }
        defer { cvips_free_operation_info(infoPtr) }
        
        let info = infoPtr.pointee
        
        let nickname = String(cString: info.nickname)
        let description = String(cString: info.description)
        
        // Get arguments
        var argCount: Int32 = 0
        let argsPtr = cvips_get_operation_arguments(name, &argCount)
        defer { 
            if let argsPtr = argsPtr {
                cvips_free_argument_info(argsPtr, argCount)
            }
        }
        
        var arguments: [VIPSArgumentInfo] = []
        
        if let argsPtr = argsPtr {
            for i in 0..<Int(argCount) {
                let arg = argsPtr[i]
                
                // Skip deprecated arguments
                if (arg.flags.rawValue & VIPS_ARGUMENT_DEPRECATED.rawValue) != 0 {
                    continue
                }
                
                let argInfo = VIPSArgumentInfo(
                    name: String(cString: arg.name),
                    type: arg.type,
                    flags: arg.flags,
                    priority: Int(arg.priority),
                    description: arg.description.map(String.init(cString:))
                )
                arguments.append(argInfo)
            }
        }
        
        return VIPSOperationInfo(
            name: name,
            nickname: nickname,
            description: description,
            flags: info.flags,
            arguments: arguments.sorted { $0.priority < $1.priority }
        )
    }
}

// MARK: - Code Generation

class SwiftCodeGenerator {
    
    static func generateSwiftWrapper(for operation: VIPSOperationInfo) -> String {
        var code = ""
        
        // Skip operations without proper outputs
        let outputArgs = operation.arguments.filter { $0.isOutput && !$0.isInput }
        if outputArgs.isEmpty && !operation.nickname.contains("save") {
            return ""
        }
        
        // Generate different wrapper styles based on operation type
        if operation.nickname.contains("load") {
            return generateLoadOperation(operation)
        } else if operation.nickname.contains("save") {
            return generateSaveOperation(operation)
        } else {
            return generateStandardOperation(operation)
        }
    }
    
    private static func generateStandardOperation(_ operation: VIPSOperationInfo) -> String {
        var code = ""
        
        let funcName = operation.nickname.swiftName()
        let inputArgs = operation.arguments.filter { $0.isInput && !$0.isOutput && !$0.isDeprecated }
        let outputArgs = operation.arguments.filter { $0.isOutput && !$0.isInput }
        
        let imageOutputs = outputArgs.filter { $0.swiftType == "VIPSImage" }
        
        // Skip if no image output
        if imageOutputs.isEmpty {
            return ""
        }
        
        // Generate documentation
        code += generateDocumentation(for: operation)
        
        // Check if this is an instance method (has an "in" parameter) or static method
        let hasInputImage = inputArgs.contains { $0.name == "in" }
        
        if hasInputImage {
            code += "    public func \(funcName)("
        } else {
            code += "    public static func \(funcName)("
        }
        
        // Add parameters
        var parameters: [String] = []
        for arg in inputArgs {
            if arg.name == "in" { continue } // Skip 'in' parameter as it's self
            
            let paramName = arg.name.swiftParameterName()
            let paramType = arg.swiftParameterType
            
            if arg.isRequired {
                parameters.append("\(paramName): \(paramType)")
            } else {
                // Provide sensible defaults where possible
                let defaultValue = getDefaultValue(for: arg)
                parameters.append("\(paramName): \(paramType) = \(defaultValue)")
            }
        }
        
        code += parameters.joined(separator: ", ")
        code += ") throws"
        
        // Determine return type
        if imageOutputs.count == 1 {
            code += " -> VIPSImage"
        } else if imageOutputs.count > 1 {
            let outputNames = imageOutputs.map { $0.name.swiftParameterName() }
            let outputTypes = imageOutputs.map { _ in "VIPSImage" }
            let tupleElements = zip(outputNames, outputTypes).map { "\($0): \($1)" }
            code += " -> (\(tupleElements.joined(separator: ", ")))"
        }
        
        code += " {\n"
        
        // Generate function body
        if hasInputImage {
            code += "        return try VIPSImage(self) { out in\n"
        } else {
            code += "        return try VIPSImage(nil) { out in\n"
        }
        
        code += "            var opt = VIPSOption()\n"
        code += "            \n"
        
        if hasInputImage {
            code += "            opt.set(\"in\", value: self.image)\n"
        }
        
        // Set input parameters
        for arg in inputArgs {
            if arg.name == "in" { continue }
            
            let paramName = arg.name.swiftParameterName()
            
            if arg.isRequired {
                code += "            opt.set(\"\(arg.name)\", value: \(paramName))\n"
            } else {
                code += "            if let \(paramName) = \(paramName) {\n"
                code += "                opt.set(\"\(arg.name)\", value: \(paramName))\n"
                code += "            }\n"
            }
        }
        
        // Set output parameters
        for output in imageOutputs {
            code += "            opt.set(\"\(output.name)\", value: &out)\n"
        }
        
        code += "\n"
        code += "            try VIPSImage.call(\"\(operation.nickname)\", options: &opt)\n"
        code += "        }\n"
        code += "    }\n"
        
        return code
    }
    
    private static func generateLoadOperation(_ operation: VIPSOperationInfo) -> String {
        // Load operations are typically static methods
        var code = ""
        
        let funcName = operation.nickname.swiftName()
        let inputArgs = operation.arguments.filter { $0.isInput && !$0.isOutput && !$0.isDeprecated }
        
        code += generateDocumentation(for: operation)
        code += "    public static func \(funcName)("
        
        // Add parameters
        var parameters: [String] = []
        for arg in inputArgs {
            let paramName = arg.name.swiftParameterName()
            let paramType = arg.swiftParameterType
            
            if arg.isRequired {
                parameters.append("\(paramName): \(paramType)")
            } else {
                let defaultValue = getDefaultValue(for: arg)
                parameters.append("\(paramName): \(paramType) = \(defaultValue)")
            }
        }
        
        code += parameters.joined(separator: ", ")
        code += ") throws -> VIPSImage {\n"
        
        code += "        return try VIPSImage(nil) { out in\n"
        code += "            var opt = VIPSOption()\n"
        code += "            \n"
        
        // Set input parameters
        for arg in inputArgs {
            let paramName = arg.name.swiftParameterName()
            
            if arg.isRequired {
                code += "            opt.set(\"\(arg.name)\", value: \(paramName))\n"
            } else {
                code += "            if let \(paramName) = \(paramName) {\n"
                code += "                opt.set(\"\(arg.name)\", value: \(paramName))\n"
                code += "            }\n"
            }
        }
        
        code += "            opt.set(\"out\", value: &out)\n"
        code += "\n"
        code += "            try VIPSImage.call(\"\(operation.nickname)\", options: &opt)\n"
        code += "        }\n"
        code += "    }\n"
        
        return code
    }
    
    private static func generateSaveOperation(_ operation: VIPSOperationInfo) -> String {
        // Save operations are instance methods that don't return anything
        var code = ""
        
        let funcName = operation.nickname.swiftName()
        let inputArgs = operation.arguments.filter { $0.isInput && !$0.isOutput && !$0.isDeprecated }
        
        code += generateDocumentation(for: operation)
        code += "    public func \(funcName)("
        
        // Add parameters (skip "in" as it's self)
        var parameters: [String] = []
        for arg in inputArgs {
            if arg.name == "in" { continue }
            
            let paramName = arg.name.swiftParameterName()
            let paramType = arg.swiftParameterType
            
            if arg.isRequired {
                parameters.append("\(paramName): \(paramType)")
            } else {
                let defaultValue = getDefaultValue(for: arg)
                parameters.append("\(paramName): \(paramType) = \(defaultValue)")
            }
        }
        
        code += parameters.joined(separator: ", ")
        code += ") throws {\n"
        
        code += "        var opt = VIPSOption()\n"
        code += "        \n"
        code += "        opt.set(\"in\", value: self.image)\n"
        
        // Set input parameters
        for arg in inputArgs {
            if arg.name == "in" { continue }
            
            let paramName = arg.name.swiftParameterName()
            
            if arg.isRequired {
                code += "        opt.set(\"\(arg.name)\", value: \(paramName))\n"
            } else {
                code += "        if let \(paramName) = \(paramName) {\n"
                code += "            opt.set(\"\(arg.name)\", value: \(paramName))\n"
                code += "        }\n"
            }
        }
        
        code += "\n"
        code += "        try VIPSImage.call(\"\(operation.nickname)\", options: &opt)\n"
        code += "    }\n"
        
        return code
    }
    
    static func generateDocumentation(for operation: VIPSOperationInfo) -> String {
        var doc = "    /// \(operation.description)\n"
        
        let inputArgs = operation.arguments.filter { $0.isInput && !$0.isOutput && $0.name != "in" && !$0.isDeprecated }
        if !inputArgs.isEmpty {
            doc += "    /// \n"
            doc += "    /// - Parameters:\n"
            for arg in inputArgs {
                if let desc = arg.description {
                    doc += "    ///   - \(arg.name.swiftParameterName()): \(desc)\n"
                }
            }
        }
        
        return doc
    }
    
    static func getDefaultValue(for arg: VIPSArgumentInfo) -> String {
        switch arg.swiftType {
        case "Bool":
            return "false"
        case "Int":
            return "0"
        case "Double":
            return "0.0"
        case "String":
            return "\"\""
        case "[Double]", "[Int]", "[VIPSImage]":
            return "[]"
        default:
            return "nil"
        }
    }
    
    static func generateSwiftFile(operations: [VIPSOperationInfo], category: String) -> String {
        let fileName = category.replacingOccurrences(of: "/", with: "_")
        
        var code = """
        //
        //  \(fileName).generated.swift
        //  
        //
        //  Generated by VIPSGenerator
        //  DO NOT EDIT - This file is automatically generated
        //
        
        import Cvips
        
        extension VIPSImage {
        
        """
        
        let categoryOps = operations
            .filter { $0.category == category }
            .sorted { $0.nickname < $1.nickname }
        
        for operation in categoryOps {
            let opCode = generateSwiftWrapper(for: operation)
            if !opCode.isEmpty {
                code += opCode
                code += "\n"
            }
        }
        
        code += "}\n"
        
        return code
    }
}

// MARK: - Utilities

extension String {
    func swiftName() -> String {
        // Remove vips_ prefix if present
        var name = self
        if name.hasPrefix("vips_") {
            name = String(name.dropFirst(5))
        }
        
        // Convert snake_case to camelCase
        return name.camelCased()
    }
    
    func camelCased() -> String {
        let components = self.split(separator: "_")
        if components.isEmpty { return self }
        
        let first = String(components[0])
        let rest = components.dropFirst().map { $0.capitalized }
        
        return ([first] + rest).joined()
    }
    
    func swiftParameterName() -> String {
        // Handle reserved keywords
        let reserved = ["in", "out", "var", "let", "func", "class", "struct", "enum", "protocol", 
                       "extension", "import", "typealias", "operator", "return", "if", "else", 
                       "for", "while", "do", "switch", "case", "default", "break", "continue", 
                       "fallthrough", "where", "guard", "defer", "repeat", "try", "catch", "throw", 
                       "throws", "rethrows", "as", "is", "nil", "true", "false", "self", "super", 
                       "init", "deinit", "get", "set", "willSet", "didSet", "static", "public", 
                       "private", "internal", "fileprivate", "open", "final", "lazy", "weak", 
                       "unowned", "inout", "associatedtype", "indirect", "prefix", "postfix", 
                       "infix", "left", "right", "none", "precedence", "higherThan", "lowerThan", 
                       "assignment", "Type"]
        
        let camelCased = self.camelCased()
        
        if reserved.contains(camelCased) {
            return "`\(camelCased)`"
        }
        
        return camelCased
    }
}