//
//  main.swift
//  VIPSGenerator
//
//  Swift-based VIPS operation wrapper generator
//

import VIPSIntrospection
import Foundation

func main() {
    do {
        print("Initializing VIPS library...")
        try VIPSIntrospection.initialize()
        defer { VIPSIntrospection.shutdown() }

        print("Discovering VIPS operations...")
        let operations = try VIPSIntrospection.getAllOperations()
        print("Found \(operations.count) operations")

        // Print first 10 operations as a test
        print("\nFirst 10 operations:")
        for (index, nickname) in operations.prefix(10).enumerated() {
            print("  \(index + 1). \(nickname)")
        }

        // Get detailed info for the first operation
        if let firstOp = operations.first {
            print("\nDetails for '\(firstOp)':")
            let opInfo = try VIPSIntrospection.getOperationInfo(firstOp)

            print("  Description: \(opInfo.description)")
            print("  Deprecated: \(opInfo.isDeprecated)")
            print("  Parameters: \(opInfo.parameters.count)")

            for param in opInfo.parameters.prefix(5) {
                let typeInfo = VIPSIntrospection.getTypeInfo(param.parameterType)
                print("    - \(param.name): \(typeInfo.name) (flags: \(param.flags))")
            }

            if opInfo.parameters.count > 5 {
                print("    ... and \(opInfo.parameters.count - 5) more parameters")
            }
        }

        print("\nIntrospection complete!")

    } catch {
        print("Error: \(error)")
        exit(1)
    }
}

main()
