import Foundation

// MARK: - Models
struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequestBody: Codable {
    let messages: [ChatMessage]
    let temperature: Double
    let max_tokens: Int
    let response_format: ResponseFormat
    
    struct ResponseFormat: Codable {
        let type: String
    }
}

struct ChatJSONResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let index: Int
        let finish_reason: String
        let message: Message
    }
    let id: String
    let model: String
    let choices: [Choice]
}

struct AzureAPIErrorEnvelope: Codable, Error {
    struct AzureError: Codable {
        let code: String
        let message: String
    }
    let error: AzureError
}

// MARK: - Service
/// A service class for Azure OpenAI GPT-4o chat completions
/// Usage:
///   let service = AzureChatGPT4OService(
///       config: .init(
///           endpoint: "https://your-resource.cognitiveservices.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2025-01-01-preview",
///           apiKey: "your-api-key",
///           defaultSystemPrompt: "You are a helpful assistant."
///       )
///   )
///   let response = try await service.chat(user: "Hello")
final class AzureChatGPT4OService {
    
    struct Config {
        /// Full chat completions URL, e.g.:
        /// https://<resource>.cognitiveservices.azure.com/openai/deployments/<deployment>/chat/completions?api-version=2025-01-01-preview
        let endpoint: String
        /// The `api-key` header value (NOT "Bearer ...")
        let apiKey: String
        /// Default system prompt for all requests (can be overridden per call)
        let defaultSystemPrompt: String
        
        /// Default configuration with preset values
        static let `default` = Config(
            endpoint: "https://aiazurebill.cognitiveservices.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2025-01-01-preview",
            apiKey: "YOUR_AZURE_API_KEY_HERE",
            defaultSystemPrompt: stickyNoteSystemPrompt
        )
    }
    
      
    private let endpoint: URL
    private let apiKey: String
    private let defaultSystemPrompt: String
    private let session: URLSession
    
    init(config: Config = .default, session: URLSession = .shared) {
        guard let url = URL(string: config.endpoint) else {
            preconditionFailure("Invalid endpoint URL: \(config.endpoint)")
        }
        self.endpoint = url
        self.apiKey = config.apiKey
        self.defaultSystemPrompt = config.defaultSystemPrompt
        self.session = session
    }
    
    /// Convenience initializer with preset values
    static func createDefault(systemPrompt: String? = nil) -> AzureChatGPT4OService {
        let config = Config(
            endpoint: "https://china-mel64ynr-eastus2.cognitiveservices.azure.com/openai/deployments/gpt-4o-mini/chat/completions?api-version=2025-03-01-preview",
            apiKey: "YOUR_AZURE_API_KEY_HERE",
            defaultSystemPrompt: systemPrompt ?? stickyNoteSystemPrompt
        )
        return AzureChatGPT4OService(config: config)
    }
    
    /// Sends messages to Azure OpenAI and returns plain text if server honors `response_format: { type: "text" }`,
    /// otherwise extracts `choices[0].message.content` from JSON.
    ///
    /// - Parameters:
    ///   - user: User message content
    ///   - systemPrompt: Optional override for the default system prompt
    ///   - temperature: Sampling temperature (0.0 to 2.0)
    ///   - maxTokens: Maximum tokens to generate
    /// - Returns: The generated response text
    /// - Throws: Network or API errors
    func chat(
        user: String,
        systemPrompt: String? = nil,
        temperature: Double = 0.2,
        maxTokens: Int = 800
    ) async throws -> String {
        
        let body = ChatRequestBody(
            messages: [
                ChatMessage(role: "system", content: systemPrompt ?? defaultSystemPrompt),
                ChatMessage(role: "user", content: user)
            ],
            temperature: temperature,
            max_tokens: maxTokens,
            response_format: ChatRequestBody.ResponseFormat(type: "text")
        )
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        // Handle response
        if let httpResponse = response as? HTTPURLResponse {
            let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""
            
            // If server returned plain text, prefer it
            if contentType.contains("text/plain") || contentType.contains("text/event-stream") {
                return String(data: data, encoding: .utf8) ?? ""
            }
            
            // Handle error responses
            if httpResponse.statusCode >= 400 {
                if let errorEnvelope = try? JSONDecoder().decode(AzureAPIErrorEnvelope.self, from: data) {
                    throw AzureChatGPT4OError.apiError(
                        code: errorEnvelope.error.code,
                        message: errorEnvelope.error.message
                    )
                }
                throw AzureChatGPT4OError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        // Try to decode as JSON response
        do {
            let decoded = try JSONDecoder().decode(ChatJSONResponse.self, from: data)
            guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
                throw AzureChatGPT4OError.emptyResponse
            }
            return content
        } catch {
            // If JSON decoding fails, try to return raw text
            if let rawText = String(data: data, encoding: .utf8), !rawText.isEmpty {
                return rawText
            }
            throw AzureChatGPT4OError.decodingError(error)
        }
    }
    
    /// Convenience method for multiple message conversations
    /// - Parameters:
    ///   - messages: Array of chat messages
    ///   - temperature: Sampling temperature
    ///   - maxTokens: Maximum tokens to generate
    /// - Returns: The generated response text
    func chat(
        messages: [ChatMessage],
        temperature: Double = 0.2,
        maxTokens: Int = 800
    ) async throws -> String {
        
        let body = ChatRequestBody(
            messages: messages,
            temperature: temperature,
            max_tokens: maxTokens,
            response_format: ChatRequestBody.ResponseFormat(type: "text")
        )
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        // Handle response (same logic as above)
        if let httpResponse = response as? HTTPURLResponse {
            let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""
            
            if contentType.contains("text/plain") || contentType.contains("text/event-stream") {
                return String(data: data, encoding: .utf8) ?? ""
            }
            
            if httpResponse.statusCode >= 400 {
                if let errorEnvelope = try? JSONDecoder().decode(AzureAPIErrorEnvelope.self, from: data) {
                    throw AzureChatGPT4OError.apiError(
                        code: errorEnvelope.error.code,
                        message: errorEnvelope.error.message
                    )
                }
                throw AzureChatGPT4OError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        do {
            let decoded = try JSONDecoder().decode(ChatJSONResponse.self, from: data)
            guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
                throw AzureChatGPT4OError.emptyResponse
            }
            return content
        } catch {
            if let rawText = String(data: data, encoding: .utf8), !rawText.isEmpty {
                return rawText
            }
            throw AzureChatGPT4OError.decodingError(error)
        }
    }
    
    // MARK: - Public AI Summarization Methods
    
    /// Generates an AI summary for the given text using the sticky note system prompt
    /// - Parameter text: The text to summarize
    /// - Returns: The AI-generated summary
    /// - Throws: AzureChatGPT4OError for various error conditions
    public func generateSummary(for text: String) async throws -> String {
        // Validate text length
        guard shouldAutoSummarize(text) else {
            throw AzureChatGPT4OError.textTooShort
        }
        
        do {
            let summary = try await chat(
                user: text,
                systemPrompt: Self.stickyNoteSystemPrompt,
                temperature: 0.2,
                maxTokens: 800
            )
            return summary
        } catch let error as AzureChatGPT4OError {
            // Re-throw known errors
            throw error
        } catch {
            // Wrap unknown errors
            if error.localizedDescription.lowercased().contains("network") {
                throw AzureChatGPT4OError.networkError(error.localizedDescription)
            } else {
                throw AzureChatGPT4OError.processingError(error.localizedDescription)
            }
        }
    }
    
    /// Determines if the given text should be automatically summarized
    /// - Parameter text: The text to validate
    /// - Returns: True if the text meets the criteria for automatic summarization
    public func shouldAutoSummarize(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if text is empty
        guard !trimmedText.isEmpty else {
            return false
        }
        
        // Use intelligent text length validation that handles multiple languages
        let (isValid, _) = validateTextLength(trimmedText)
        return isValid
    }
    
    /// Validates text for AI processing and returns word count
    /// - Parameter text: The text to validate
    /// - Returns: Tuple containing validation result and word count
    public func validateTextForAI(_ text: String) -> (isValid: Bool, wordCount: Int) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
            return (false, 0)
        }
        
        return validateTextLength(trimmedText)
    }
    
    /// Validates text length using language-aware logic
    /// - Parameter text: The text to validate
    /// - Returns: Tuple containing validation result and effective word/character count
    private func validateTextLength(_ text: String) -> (isValid: Bool, wordCount: Int) {
        // Detect if text contains CJK characters (Chinese, Japanese, Korean)
        let cjkCharacterCount = text.unicodeScalars.filter { scalar in
            // CJK Unified Ideographs: U+4E00-U+9FFF
            // CJK Extension A: U+3400-U+4DBF
            // CJK Extension B: U+20000-U+2A6DF
            // Hiragana: U+3040-U+309F
            // Katakana: U+30A0-U+30FF
            // Hangul: U+AC00-U+D7AF
            return (scalar.value >= 0x4E00 && scalar.value <= 0x9FFF) ||
                   (scalar.value >= 0x3400 && scalar.value <= 0x4DBF) ||
                   (scalar.value >= 0x20000 && scalar.value <= 0x2A6DF) ||
                   (scalar.value >= 0x3040 && scalar.value <= 0x309F) ||
                   (scalar.value >= 0x30A0 && scalar.value <= 0x30FF) ||
                   (scalar.value >= 0xAC00 && scalar.value <= 0xD7AF)
        }.count
        
        // If text contains significant CJK characters, use character-based validation
        if cjkCharacterCount > 0 {
            // For CJK languages, require at least 15 characters (including mixed content)
            // This accounts for meaningful content in languages without spaces
            let effectiveLength = max(cjkCharacterCount, text.count / 2)
            return (effectiveLength >= 15, effectiveLength)
        } else {
            // For space-separated languages (English, etc.), use word-based validation
            let wordCount = text.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
                .count
            return (wordCount >= 10, wordCount)
        }
    }
}

// MARK: - Error Types
enum AzureChatGPT4OError: Error, LocalizedError {
    case apiError(code: String, message: String)
    case httpError(statusCode: Int)
    case emptyResponse
    case decodingError(Error)
    case invalidConfiguration
    case textTooShort
    case networkError(String)
    case processingError(String)
    
    var errorDescription: String? {
        switch self {
        case .apiError(let code, let message):
            return "Azure API Error [\(code)]: \(message)"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .emptyResponse:
            return "Empty response from Azure OpenAI"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidConfiguration:
            return "Invalid service configuration"
        case .textTooShort:
            return "Text is too short for AI summarization"
        case .networkError(let message):
            return "Network error: \(message)"
        case .processingError(let message):
            return "Processing error: \(message)"
        }
    }
}

// MARK: - Predefined System Prompts
extension AzureChatGPT4OService {
    
    static let stickyNoteSystemPrompt2 = """
    [Role]
    You are an AI assistant that distills complex conversations into precise sticky notes. Your mission is to extract key data points from raw transcripts, notes, or spoken input.


    [Key Purpose]
    Generate short, structured sticky notes that highlight the most important actions, decisions, and reminders.
    Always keep the output in the same language as the input text. Do not translate.

    [Instructions]
    1.**Analyze the input for action items.** Look for specific tasks, decisions, deadlines, or reminders.
    2.**Format each point as a separate sticky note.** Use a bulleted list or markdown list for clarity.
    3.**Use a consistent structure.** Each note should follow this pattern: [Action Verb] [Task/Subject] [Optional: With/For Whom] [Optional: By When].
    4. **Keep each note scannable and direct.** Write each note as a simple sentence or a short phrase, staying under 20 words.
    5.**Maintain the original language.** Do not translate the output.
    6.**Handle short input correctly.** If the input is a single sentence or phrase, rephrase it slightly to fit the action-oriented format.
    """
    
    static let stickyNoteSystemPrompt1 = """
    [Role]
    You are an AI productivity assistant that transforms raw transcripts, meeting notes, or free-form speech into clear and concise sticky notes.

    [Key Purpose]
    Generate short, structured sticky notes that highlight the most important actions, decisions, and reminders.
    Always keep the output in the same language as the input text. Do not translate.

    [Instructions]
        • Detect the original language of the input.
        • Output sticky notes in that same language.
        • If the input is very short (e.g., a single sentence or phrase), simply echo it back as one sticky note instead of summarizing.
        • Extract only key points (task, deadline, time, people, place, decision).
        • Keep each note under 20 words, simple and scannable.
        • Format notes consistently.
    """
    
    static let stickyNoteSystemPrompt = """
    [Role]
    You are a productivity assistant that converts spoken words into simple, scannable sticky notes.

    [Goal]
    Transform user speech into structured sticky notes that capture tasks, to-dos, reminders, ideas, or motivational quotes.

    [Instructions]
    - Keep the original language (do not translate).
    - Remove filler words and casual conversation.
    - Detect note type automatically:
      • To-Do / Reminder → use checklist format.
      • Task → short actionable sentence.
      • Idea / Reference → plain text note.
      • Quote → quotation marks.
    - Keep each note short (max 20 words).
    - One note per line.
    - If multiple notes are mentioned, split them into separate stickies.

    [Output Format Examples]
    - Task: “Reply to emails from client”
    - Checklist:  
      - [ ] Milk  
      - [ ] Eggs  
    - Reminder: “Meditate for 10 minutes”
    - Quote: “Never give up on your dreams.”
    - Idea/Link: “Check Notion templates for productivity”
    """
    
    static let noteEnhancementPrompt = """
    You are a helpful assistant that improves and enhances note content. Make the text clearer, more organized, and easier to understand while maintaining the original meaning and intent.
    """
}

// MARK: - Usage Examples
/*
// Example 1: Simplest usage with preset values
let service = AzureChatGPT4OService()
let response = try await service.chat(user: "Hello, how are you?")
print(response)

// Example 2: Using preset values with custom system prompt
let stickyNoteService = AzureChatGPT4OService.createDefault(
    systemPrompt: AzureChatGPT4OService.stickyNoteSystemPrompt
)
let transcript = "明天上午10点要给Sarah发邮件，下午要review项目slides"
let stickyNotes = try await stickyNoteService.chat(user: transcript)
print(stickyNotes)

// Example 3: Using default config
let defaultService = AzureChatGPT4OService(config: .default)
let defaultResponse = try await defaultService.chat(user: "What can you help me with?")
print(defaultResponse)

// Example 4: Multi-message conversation
let messages = [
    ChatMessage(role: "system", content: "You are a helpful assistant."),
    ChatMessage(role: "user", content: "What's the weather like?"),
    ChatMessage(role: "assistant", content: "I don't have access to current weather data."),
    ChatMessage(role: "user", content: "Can you help me with something else?")
]
let conversationResponse = try await service.chat(messages: messages)
print(conversationResponse)

// Example 5: Custom configuration (if needed)
let customService = AzureChatGPT4OService(
    config: .init(
        endpoint: "https://custom-endpoint.com/...",
        apiKey: "custom-api-key",
        defaultSystemPrompt: "Custom system prompt"
    )
)
*/
