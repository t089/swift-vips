import VIPS

// Stress test to trigger the vips_area_unref assertion
func stressTestBlobHandling() throws {
    try VIPS.start()
    
    // Create test image data
    let width = 100
    let height = 100
    let data = Array(repeating: UInt8(128), count: width * height * 3)
    
    // Test 1: Multiple exports in quick succession
    for i in 0..<50 {
        do {
            let image = try VIPSImage(data: data, width: width, height: height, bands: 3, format: .uchar)
            let _ = try image.exportedJpeg(quality: 80)
            let _ = try image.exportedPNG()
            if i % 10 == 0 {
                print("Export iteration \(i)")
            }
        } catch {
            print("Error at iteration \(i): \(error)")
        }
    }
    
    print("Stress test completed successfully")
    VIPS.shutdown()
}

do {
    try stressTestBlobHandling()
} catch {
    print("Fatal error: \(error)")
}
