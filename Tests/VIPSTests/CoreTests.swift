import Cvips
import CvipsShim
import Foundation
import Testing

@testable import VIPS

extension VIPSTests {
    @Suite(.vips)
    struct CoreTests {

        var testPath: String {
            testUrl.path
        }

        var testUrl: URL {
            Bundle.module.resourceURL!
                .appendingPathComponent("data")
                .appendingPathComponent("bay.jpg")
        }

        var mythicalGiantPath: String {
            Bundle.module.resourceURL!
                .appendingPathComponent("data")
                .appendingPathComponent("mythical_giant.jpg")
                .path
        }

        @Test()
        func testProgressReporting() async throws {
            do {
                let image = try VIPSImage(fromFilePath: mythicalGiantPath)

                var preEval: VIPSProgress?
                var postEval: VIPSProgress?
                var progressRecieved : [VIPSProgress] = []


                image.setProgressReportingEnabled(true)

                image.onPreeval { _, progress in preEval = progress }
                image.onPosteval { _, progress in postEval = progress }

                image.onEval { [weak image] imageRef, progress in
                    guard let image else { return }
                    progressRecieved.append(progress)
                    #expect(image.image == imageRef.image, "Image references match")
                }

                _ = try image.writeToBuffer(suffix: ".jpg")

                let pre = try #require(preEval)
                #expect(pre.percent == 0, "Pre-eval progress is 0%")
                #expect(progressRecieved.count > 0, "Got progress")
                let post = try #require(postEval)
                #expect(post.percent == 100, "Post-eval progress is 100%")
            }
        }

        @Test()
        func cancellation() async throws {
            do {
                let image = try VIPSImage(fromFilePath: mythicalGiantPath)
                
                image.onEval { imageRef, progress in
                    if Task.isCancelled {
                        imageRef.setKill(true)
                    }
                }

                image.setProgressReportingEnabled(true)

                let task = Task {
                    try? await Task.sleep(for: .milliseconds(50))
                    return try image.writeToBuffer(suffix: ".jpg")
                }
                task.cancel()
                do {
                    _ = try await task.value
                    Issue.record("Expected cancellation to throw")
                } catch {
                    let message = "\(error)"
                    #expect(message.starts(with: "VipsImage: "), "Cancellation error from VIPS")
                }
                
            }
        }
    }
}
