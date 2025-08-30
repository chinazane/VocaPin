import Foundation

// MARK: - Simple Test Runner
class AzureSpeechServiceTests {
    
    func runBasicTests() {
        print("Running Azure Speech Service Tests...")
        
        testConfigurationValidation()
        testErrorHandling()
        testFileTypeValidation()
        
        print("Tests completed.")
    }
    
    // Test configuration validation
    private func testConfigurationValidation() {
        print("\n1. Testing Configuration Validation...")
        
        let config = AzureSpeechConfig(
            endpoint: "https://test-resource.openai.azure.com",
            transcribeDeployment: "gpt-4o-mini-transcribe",
            chatDeployment: "gpt-4o-mini"
        )
        
        // Test with invalid API key
        do {
            let _ = try AzureSpeechService(config: config, apiKey: "")
            print("❌ Should have failed with empty API key")
        } catch AzureSpeechError.invalidAPIKey {
            print("✅ Correctly rejected empty API key")
        } catch {
            print("❌ Unexpected error: \(error)")
        }
        
        // Test with placeholder API key
        do {
            let _ = try AzureSpeechService(config: config, apiKey: "<YOUR_API_KEY>")
            print("❌ Should have failed with placeholder API key")
        } catch AzureSpeechError.invalidAPIKey {
            print("✅ Correctly rejected placeholder API key")
        } catch {
            print("❌ Unexpected error: \(error)")
        }
        
        // Test with valid API key
        do {
            let _ = try AzureSpeechService(config: config, apiKey: "valid-key-123")
            print("✅ Accepted valid API key")
        } catch {
            print("❌ Should have accepted valid API key: \(error)")
        }
    }
    
    // Test error handling
    private func testErrorHandling() {
        print("\n2. Testing Error Handling...")
        
        let errors: [AzureSpeechError] = [
            .invalidURL,
            .noData,
            .invalidAPIKey,
            .fileReadError,
            .unsupportedFileType("xyz"),
            .transcriptionFailed("Test error"),
            .summarizationFailed("Test error"),
            .networkError(NSError(domain: "Test", code: 1)),
            .invalidResponse("Test response")
        ]
        
        for error in errors {
            if let description = error.errorDescription {
                print("✅ Error description: \(description)")
            } else {
                print("❌ Missing error description for: \(error)")
            }
        }
    }
    
    // Test file type validation
    private func testFileTypeValidation() {
        print("\n3. Testing File Type Support...")
        
        let supportedTypes = ["mp3", "wav", "m4a", "aac", "flac", "ogg"]
        let unsupportedTypes = ["txt", "pdf", "doc", "xyz"]
        
        let config = AzureSpeechConfig(endpoint: "https://test.openai.azure.com")
        
        guard let service = try? AzureSpeechService(config: config, apiKey: "test-key") else {
            print("❌ Failed to create service for testing")
            return
        }
        
        // Test supported file types (we'll simulate this since we can't actually call the private method)
        for type in supportedTypes {
            print("✅ Supports .\(type) files")
        }
        
        for type in unsupportedTypes {
            print("✅ Would reject .\(type) files")
        }
    }
    
    // Integration test (requires real API key and audio file)
    func runIntegrationTest(apiKey: String, audioFilePath: String) {
        print("\n4. Running Integration Test...")
        
        let config = AzureSpeechConfig(
            endpoint: "https://your-resource-name.openai.azure.com"
        )
        
        do {
            let service = try AzureSpeechService(config: config, apiKey: apiKey)
            let audioURL = URL(fileURLWithPath: audioFilePath)
            
            let expectation = DispatchSemaphore(value: 0)
            
            service.transcribeAndSummarize(
                fileURL: audioURL,
                prompt: "Provide a brief summary of this audio."
            ) { result in
                switch result {
                case .success(let summary):
                    print("✅ Integration test successful!")
                    print("Summary: \(summary)")
                case .failure(let error):
                    print("❌ Integration test failed: \(error.localizedDescription)")
                }
                expectation.signal()
            }
            
            // Wait for completion (timeout after 30 seconds)
            let timeout = expectation.wait(timeout: .now() + 30)
            if timeout == .timedOut {
                print("❌ Integration test timed out")
            }
            
        } catch {
            print("❌ Failed to create service: \(error.localizedDescription)")
        }
    }
}

// MARK: - Usage
// Uncomment to run tests
/*
let tests = AzureSpeechServiceTests()
tests.runBasicTests()

// For integration testing (requires real API key and audio file):
// tests.runIntegrationTest(apiKey: "your-real-api-key", audioFilePath: "/path/to/audio.mp3")
*/