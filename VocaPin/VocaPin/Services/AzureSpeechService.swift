import Foundation
import AVFoundation

// MARK: - Azure Speech Configuration
struct AzureSpeechConfig {
    let endpoint: String
    let transcribeDeployment: String
    let chatDeployment: String
    let apiVersion: String
    let apiKey: String
    
    static let `default` = AzureSpeechConfig(
        endpoint: "https://china-mel64ynr-eastus2.cognitiveservices.azure.com",
        transcribeDeployment: "gpt-4o-mini-transcribe",
        chatDeployment: "gpt-4o-mini",
        apiVersion: "2025-03-01-preview",
        apiKey: "YOUR_AZURE_API_KEY_HERE"
    )
}

// MARK: - Azure Speech Errors
enum AzureSpeechError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidAPIKey
    case fileReadError
    case unsupportedFileType(String)
    case transcriptionFailed(String)
    case networkError(Error)
    case invalidResponse(String)
    case audioTooShort
    case audioTooLong
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Azure endpoint URL"
        case .noData:
            return "No data received from Azure service"
        case .invalidAPIKey:
            return "Invalid Azure API key"
        case .fileReadError:
            return "Unable to read audio file"
        case .unsupportedFileType(let type):
            return "Unsupported file type: .\(type)"
        case .transcriptionFailed(let message):
            return "Azure transcription failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let message):
            return "Invalid response from Azure: \(message)"
        case .audioTooShort:
            return "Audio file is too short for transcription"
        case .audioTooLong:
            return "Audio file is too long for transcription"
        }
    }
}

class AzureSpeechService: ObservableObject {
    private let config: AzureSpeechConfig
    private let session: URLSession
    
    // Supported audio file types
    private let supportedFileTypes: [String: String] = [
        "wav": "audio/wav",
        "mp3": "audio/mpeg",
        "m4a": "audio/mp4",
        "aac": "audio/aac",
        "flac": "audio/flac"
    ]
    
    init(config: AzureSpeechConfig = .default, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }
    
    /// Simple transcription without summarization (for speech recognition view)
    func transcribeAudio(fileURL: URL, completion: @escaping (Result<String, AzureSpeechError>) -> Void) {
        print("🎤 AzureSpeechService: Starting transcription for \(fileURL.lastPathComponent)")
        
        // Validate file
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completion(.failure(.fileReadError))
            return
        }
        
        // Check file type
        let fileExtension = fileURL.pathExtension.lowercased()
        guard let mimeType = supportedFileTypes[fileExtension] else {
            completion(.failure(.unsupportedFileType(fileExtension)))
            return
        }
        
        // Check file size
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            
            if fileSize < 1000 { // Less than 1KB
                completion(.failure(.audioTooShort))
                return
            }
            
            if fileSize > 25 * 1024 * 1024 { // More than 25MB
                completion(.failure(.audioTooLong))
                return
            }
        } catch {
            completion(.failure(.fileReadError))
            return
        }
        
        performTranscription(fileURL: fileURL, mimeType: mimeType, completion: completion)
    }
    
    /// Full pipeline: transcribe audio, then summarize with a prompt
    func transcribeAndSummarize(fileURL: URL, prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        transcribeAudio(fileURL: fileURL) { result in
            switch result {
            case .success(let transcript):
                self.summarizeTranscript(transcript: transcript, prompt: prompt) { summaryResult in
                    switch summaryResult {
                    case .success(let summary):
                        completion(.success(summary))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func performTranscription(fileURL: URL, mimeType: String, completion: @escaping (Result<String, AzureSpeechError>) -> Void) {
        guard let url = URL(string: "\(config.endpoint)/openai/deployments/\(config.transcribeDeployment)/audio/transcriptions?api-version=\(config.apiVersion)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // FIX 1: Use correct header format matching your curl command
        request.setValue(config.apiKey, forHTTPHeaderField: "api-key")
        
        // Multipart body
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        
        // Model field
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
        body.append("\(config.transcribeDeployment)\r\n")
        
        // File field
        let filename = fileURL.lastPathComponent
        guard let fileData = try? Data(contentsOf: fileURL) else {
            completion(.failure(.fileReadError))
            return
        }
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        
        // FIX 2: Add prompt field matching your curl command
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n")
        body.append("Transcribe the audio verbatim. Include every word, in the original language/script (Chinese, English, Japanese). Do not summarize or omit anything.\r\n")
        
        // FIX 3: Add response_format field matching your curl command
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n")
        body.append("text\r\n")
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ AzureSpeechService: Network error: \(error.localizedDescription)")
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    print("❌ AzureSpeechService: No data received")
                    completion(.failure(.noData))
                    return
                }
                
                // Log response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                   // print("🔍 AzureSpeechService: Response: \(responseString)")
                }
                
                // FIX 4: Handle text response format (not JSON) matching your curl command
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 AzureSpeechService: HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        // Success - response should be plain text
                        if let transcribedText = String(data: data, encoding: .utf8) {
                            let cleanedText = transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
                           // print("✅ AzureSpeechService: Transcription successful: '\(cleanedText)'")
                            completion(.success(cleanedText))
                        } else {
                            completion(.failure(.invalidResponse("Could not decode text response")))
                        }
                        return
                    }
                }
                
                // If not 200 status, try to parse as JSON error response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("❌ AzureSpeechService: API error: \(message)")
                        completion(.failure(.transcriptionFailed(message)))
                        return
                    }
                } catch {
                    // If JSON parsing fails, treat as plain text error
                    if let errorText = String(data: data, encoding: .utf8) {
                        print("❌ AzureSpeechService: Error response: \(errorText)")
                        completion(.failure(.transcriptionFailed(errorText)))
                    } else {
                        completion(.failure(.invalidResponse("Unknown error response")))
                    }
                }
            }
        }.resume()
    }
    
    private func summarizeTranscript(transcript: String, prompt: String, completion: @escaping (Result<String, AzureSpeechError>) -> Void) {
        guard let url = URL(string: "\(config.endpoint)/openai/deployments/\(config.chatDeployment)/chat/completions?api-version=\(config.apiVersion)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("api-key \(config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that rewrites transcripts."],
                ["role": "user", "content": "\(prompt)\n\nTranscript:\n\(transcript)"]
            ],
            "max_tokens": 500
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        completion(.failure(.invalidResponse("Invalid JSON response")))
                        return
                    }
                    
                    // Check for error in response
                    if let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        completion(.failure(.transcriptionFailed(message)))
                        return
                    }
                    
                    // Extract content
                    guard let choices = json["choices"] as? [[String: Any]],
                          let firstChoice = choices.first,
                          let message = firstChoice["message"] as? [String: Any],
                          let content = message["content"] as? String else {
                        completion(.failure(.transcriptionFailed("No content found in response")))
                        return
                    }
                    
                    completion(.success(content))
                    
                } catch {
                    completion(.failure(.invalidResponse("Failed to parse response")))
                }
            }
        }.resume()
    }
}

// MARK: - Data helper
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

/*
let service = AzureSpeechService()
let audioFileURL = URL(fileURLWithPath: "/path/to/audio.mp3")

let customPrompt = "Summarize the transcript into 3 bullet points with key decisions."

service.transcribeAndSummarize(fileURL: audioFileURL, prompt: customPrompt) { result in
    switch result {
    case .success(let summary):
        print("✨ Final Output:\n\(ummary)")
    case .failure(let error):
        print("❌ Error: \(error.localizedDescription)")
    }

}*/
