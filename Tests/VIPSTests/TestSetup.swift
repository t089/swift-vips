@testable import VIPS
import Testing
import Foundation

/// Global test setup to ensure VIPS.start() is called only once across all tests
enum TestSetup {
    private static let setupOnce: Void = {
        try! VIPS.start()
        try? FileManager.default.createDirectory(
            at: URL(fileURLWithPath: "/tmp/swift-vips"), 
            withIntermediateDirectories: true
        )
    }()
    
    static func ensureSetup() {
        _ = setupOnce
    }
}

/// Scope provider that manages VIPS lifecycle
struct VIPSTestScopeProvider: TestScoping {
    func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        // Ensure VIPS is started before running any test
        TestSetup.ensureSetup()
        /*print("!!!!!! START")
        try VIPS.start()
        defer {
            VIPS.shutdown()
            print("!!!!!! SHUTDOWN")
        }*/
        // Run the test
        try await function()
        
        
    }
}

/// Custom trait that ensures VIPS is initialized before running tests
struct VIPSTestTrait: SuiteTrait, TestTrait {
    typealias TestScopeProvider = VIPSTestScopeProvider
    
    func scopeProvider(for test: Test, testCase: Test.Case?) -> VIPSTestScopeProvider? {
        if test.isSuite || testCase == nil {
            return VIPSTestScopeProvider()
        }
        return nil
    }
}

extension SuiteTrait where Self == VIPSTestTrait {
    static var vips: VIPSTestTrait {
        VIPSTestTrait()
    }
}