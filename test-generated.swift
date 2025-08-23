#!/usr/bin/env swift

// Simple test to verify generated code works
import VIPS

// Test that we can import and use the generated operations
do {
    // Create a test image
    let img = try VIPSImage.black(width: 100, height: 100)
    
    // Test arithmetic operation with image parameter
    let doubled = try img.add(img)
    
    // Test operation with mask parameter  
    let mask = try VIPSImage.gaussmat(sigma: 1.0)
    let blurred = try img.conv(mask: mask)
    
    // Test static load operation
    // let loaded = try VIPSImage.jpegload(filename: "test.jpg")
    
    print("✅ Generated operations compile and run successfully!")
} catch {
    print("❌ Error: \(error)")
}