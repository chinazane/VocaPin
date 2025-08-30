import Foundation
import Speech
import AVFoundation

class AzureSpeechRecognizer: NSObject, ObservableObject {
    // Audio recording and processing
    private let audioEngine = AVAudioEngine()
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    // Audio level properties for visualization
    @Published var audioLevel: Float = 0.0
    @Published var smoothedAudioLevel: Float = 0.0
    @Published var peakAudioLevel: Float = 0.0
    @Published var waveformData: [Float] = Array(repeating: 0.0, count: 50)
    
    // Audio level processing
    private var audioLevelHistory: [Float] = []
    private let audioLevelHistorySize = 10
    private var lastAudioLevelUpdate = Date()
    
    // Recording state
    @Published var isRecordingAudio: Bool = false
    @Published var recordingStatus: String = "Ready"
    private var recordingSessionID: String = ""
    
    // WAV file tracking for transcription
    @Published var lastRecordingURL: URL?
    @Published var lastRecordingMetadata: AudioFileMetadata?
    
    // Error handling
    @Published var currentError: AudioRecordingError?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // Azure Speech Service
    private let azureSpeechService = AzureSpeechService()
    
    // Real-time transcription callback
    private var transcriptionCallback: ((String) -> Void)?
    
    override init() {
        super.init()
        print("🎤 AzureSpeechRecognizer: Initialized with Azure Speech Service")
    }
    
    // MARK: - Public Methods
    
    func startRecording(completion: @escaping (String) -> Void) {
        print("🎤 AzureSpeechRecognizer: Starting recording with Azure backend")
        
        // Store callback for later use
        transcriptionCallback = completion
        
        // Clear any previous errors
        dismissError()
        
        // Check permissions
        if let permissionError = checkPermissions() {
            handleError(permissionError)
            return
        }
        
        // Check storage space
        if !checkStorageSpace() {
            handleError(.insufficientStorage)
            return
        }
        
        // Configure audio session
        guard configureAudioSession() else {
            handleError(.audioSessionFailed)
            return
        }
        
        // Setup audio recording
        guard setupAudioRecording() != nil else {
            handleError(.fileCreationFailed)
            return
        }
        
        // Start audio file recording
        startAudioFileRecording()
        
        // Start audio engine for visualization
        startAudioVisualization()
    }
    
    func stopRecording() {
        print("🎤 AzureSpeechRecognizer: Stopping recording")
        
        // Stop audio file recording
        stopAudioFileRecording()
        
        // Stop audio engine
        stopAudioVisualization()
        
        // Process the recorded file with Azure
        if let recordingURL = lastRecordingURL {
            processRecordingWithAzure(recordingURL)
        }
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            updateRecordingStatus("Audio session configured")
            return true
        } catch {
            print("❌ AzureSpeechRecognizer: Audio session setup failed: \(error.localizedDescription)")
            handleError(.audioSessionFailed)
            return false
        }
    }
    
    // MARK: - Audio Recording Setup
    
    private func setupAudioRecording() -> URL? {
        // Check microphone permission
        let recordPermission = AVAudioSession.sharedInstance().recordPermission
        guard recordPermission == .granted else {
            print("❌ AzureSpeechRecognizer: Microphone permission not granted")
            return nil
        }
        
        let recordingsDirectory = AudioFileNaming.getRecordingsDirectory()
        let filename = AudioFileNaming.generateFilename()
        let url = recordingsDirectory.appendingPathComponent(filename)
        
        recordingSessionID = UUID().uuidString.prefix(8).uppercased()
        
        print("🎤 AzureSpeechRecognizer: Setting up recording at: \(url.lastPathComponent)")
        updateRecordingStatus("Setting up recording...")
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: AudioRecordingConfig.settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            recordingURL = url
            
            DispatchQueue.main.async {
                self.lastRecordingURL = url
                self.lastRecordingMetadata = nil
            }
            
            print("✅ AzureSpeechRecognizer: Audio recorder configured successfully")
            updateRecordingStatus("Recording ready")
            return url
        } catch {
            print("❌ AzureSpeechRecognizer: Failed to setup audio recorder: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func startAudioFileRecording() {
        guard let recorder = audioRecorder else {
            print("❌ AzureSpeechRecognizer: Audio recorder not configured")
            updateRecordingStatus("Recording setup failed")
            return
        }
        
        let success = recorder.record()
        if success {
            DispatchQueue.main.async {
                self.isRecordingAudio = true
            }
            updateRecordingStatus("Recording with Azure backend")
            print("✅ AzureSpeechRecognizer: Audio file recording started")
        } else {
            print("❌ AzureSpeechRecognizer: Failed to start audio file recording")
            updateRecordingStatus("Recording failed to start")
        }
    }
    
    private func stopAudioFileRecording() {
        guard let recorder = audioRecorder else {
            updateRecordingStatus("Ready")
            return
        }
        
        recorder.stop()
        DispatchQueue.main.async {
            self.isRecordingAudio = false
        }
        
        if let url = recordingURL {
            print("✅ AzureSpeechRecognizer: Audio file recording stopped and saved")
            updateRecordingStatus("Processing with Azure...")
            
            // Extract metadata from the finalized WAV file
            DispatchQueue.global(qos: .userInitiated).async {
                let metadata = self.extractAudioFileMetadata(from: url)
                
                DispatchQueue.main.async {
                    self.lastRecordingMetadata = metadata
                    self.lastRecordingURL = url
                    
                    if metadata.isValidForTranscription {
                        self.updateRecordingStatus("Recording ready for Azure transcription")
                        print("✅ AzureSpeechRecognizer: WAV file ready for Azure - Duration: \(metadata.formattedDuration)")
                    } else {
                        self.updateRecordingStatus("Recording saved (quality issues detected)")
                        print("⚠️ AzureSpeechRecognizer: WAV file may have quality issues")
                    }
                }
            }
        } else {
            updateRecordingStatus("Recording completed")
        }
        
        audioRecorder = nil
        recordingURL = nil
    }
    
    // MARK: - Audio Visualization
    
    private func startAudioVisualization() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { buffer, _ in
            self.updateAudioLevel(from: buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("✅ AzureSpeechRecognizer: Audio engine started for visualization")
        } catch {
            print("❌ AzureSpeechRecognizer: Audio engine start failed: \(error)")
        }
    }
    
    private func stopAudioVisualization() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Reset audio levels
        DispatchQueue.main.async {
            self.audioLevel = 0.0
            self.smoothedAudioLevel = 0.0
            self.peakAudioLevel = 0.0
            self.waveformData = Array(repeating: 0.0, count: 50)
        }
        audioLevelHistory.removeAll()
        
        print("✅ AzureSpeechRecognizer: Audio visualization stopped")
    }
    
    // MARK: - Azure Processing
    
    private func processRecordingWithAzure(_ url: URL) {
        print("🎤 AzureSpeechRecognizer: Processing recording with Azure Speech Service")
        updateRecordingStatus("Transcribing with Azure...")
        
        azureSpeechService.transcribeAudio(fileURL: url) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let transcribedText):
                    print("✅ AzureSpeechRecognizer: Azure transcription successful")
                    self.updateRecordingStatus("Azure transcription completed")
                    
                    // Call the completion callback with the transcribed text
                    self.transcriptionCallback?(transcribedText)
                    
                case .failure(let error):
                    print("❌ AzureSpeechRecognizer: Azure transcription failed: \(error.localizedDescription)")
                    self.updateRecordingStatus("Azure transcription failed")
                    
                    // Handle the error appropriately
                    let audioError = self.mapAzureErrorToAudioError(error)
                    self.handleError(audioError)
                }
                
                // Reset status after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.updateRecordingStatus("Ready")
                }
            }
        }
    }
    
    private func mapAzureErrorToAudioError(_ azureError: AzureSpeechError) -> AudioRecordingError {
        switch azureError {
        case .networkError:
            return .networkError
        case .fileReadError:
            return .fileCreationFailed
        case .unsupportedFileType:
            return .unknownError("Unsupported audio format")
        case .transcriptionFailed(let message):
            return .unknownError("Transcription failed: \(message)")
        case .invalidURL, .invalidAPIKey, .noData, .invalidResponse:
            return .unknownError("Azure service configuration error")
        case .audioTooShort, .audioTooLong:
            return .unknownError("Audio length not suitable for transcription")
        }
    }
    
    // MARK: - Helper Methods (copied from original SpeechRecognizer)
    
    private func checkPermissions() -> AudioRecordingError? {
        let recordPermission = AVAudioSession.sharedInstance().recordPermission
        if recordPermission != .granted {
            return .permissionDenied
        }
        return nil
    }
    
    private func checkStorageSpace() -> Bool {
        // Simple storage check - could be enhanced
        return true
    }
    
    private func handleError(_ error: AudioRecordingError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.errorMessage = error.userFriendlyMessage
            self.showError = true
            self.updateRecordingStatus("Error occurred")
        }
    }
    
    func dismissError() {
        DispatchQueue.main.async {
            self.currentError = nil
            self.showError = false
            self.errorMessage = ""
        }
    }
    
    private func updateRecordingStatus(_ status: String) {
        DispatchQueue.main.async {
            self.recordingStatus = status
        }
    }
    
    // MARK: - Audio Level Processing (copied from original)
    
    private func updateAudioLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        let rms = calculateRMS(from: channelDataArray)
        let peak = calculatePeak(from: channelDataArray)
        let dynamicRange = calculateDynamicRange(from: channelDataArray)
        
        let frequencyWeightedLevel = applyFrequencyWeighting(rms: rms, peak: peak, dynamicRange: dynamicRange)
        let normalizedLevel = enhancedNormalization(frequencyWeightedLevel)
        let smoothedLevel = applySmoothingFilter(normalizedLevel)
        let waveformData = generateWaveformFromBuffer(channelDataArray)
        
        DispatchQueue.main.async {
            self.audioLevel = normalizedLevel
            self.smoothedAudioLevel = smoothedLevel
            self.peakAudioLevel = peak
            self.waveformData = waveformData
        }
    }
    
    private func calculateRMS(from samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }
        let sumOfSquares = samples.reduce(0) { $0 + ($1 * $1) }
        return sqrt(sumOfSquares / Float(samples.count))
    }
    
    private func calculatePeak(from samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }
        return samples.map { abs($0) }.max() ?? 0
    }
    
    private func calculateDynamicRange(from samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }
        let absoluteSamples = samples.map { abs($0) }
        let peak = absoluteSamples.max() ?? 0
        let average = absoluteSamples.reduce(0, +) / Float(absoluteSamples.count)
        return peak - average
    }
    
    private func applyFrequencyWeighting(rms: Float, peak: Float, dynamicRange: Float) -> Float {
        let rmsWeight: Float = 0.6
        let peakWeight: Float = 0.3
        let dynamicWeight: Float = 0.1
        return (rms * rmsWeight) + (peak * peakWeight) + (dynamicRange * dynamicWeight)
    }
    
    private func enhancedNormalization(_ level: Float) -> Float {
        let logLevel = log10(max(level * 100, 0.001)) / 2.0
        let normalizedLevel = max(min(logLevel + 1.0, 1.0), 0.0)
        return applySensitivityCurve(normalizedLevel)
    }
    
    private func applySensitivityCurve(_ level: Float) -> Float {
        return pow(level, 0.7)
    }
    
    private func applySmoothingFilter(_ currentLevel: Float) -> Float {
        audioLevelHistory.append(currentLevel)
        if audioLevelHistory.count > audioLevelHistorySize {
            audioLevelHistory.removeFirst()
        }
        
        var weightedSum: Float = 0
        var totalWeight: Float = 0
        
        for (index, level) in audioLevelHistory.enumerated() {
            let weight = Float(index + 1)
            weightedSum += level * weight
            totalWeight += weight
        }
        
        return totalWeight > 0 ? weightedSum / totalWeight : currentLevel
    }
    
    private func generateWaveformFromBuffer(_ samples: [Float]) -> [Float] {
        let waveformBars = 50
        guard !samples.isEmpty else {
            return Array(repeating: 0.0, count: waveformBars)
        }
        
        let samplesPerBar = max(1, samples.count / waveformBars)
        var waveformData: [Float] = []
        
        for barIndex in 0..<waveformBars {
            let startIndex = barIndex * samplesPerBar
            let endIndex = min(startIndex + samplesPerBar, samples.count)
            
            if startIndex < samples.count {
                let barSamples = Array(samples[startIndex..<endIndex])
                let rms = calculateRMS(from: barSamples)
                let normalizedRMS = aggressiveNormalization(rms)
                waveformData.append(normalizedRMS)
            } else {
                waveformData.append(0.0)
            }
        }
        
        return waveformData
    }
    
    private func aggressiveNormalization(_ level: Float) -> Float {
        let silenceThreshold: Float = 0.001
        
        if level < silenceThreshold {
            return 0.0
        }
        
        let amplified = level * 10.0
        let normalized = min(amplified, 1.0)
        return normalized
    }
    
    private func extractAudioFileMetadata(from url: URL) -> AudioFileMetadata {
        // Simplified metadata extraction
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            let fileSize = AudioFileManager.getFileSize(at: url)
            let creationDate = AudioFileManager.getFileCreationDate(at: url) ?? Date()
            
            let qualityScore: Float = duration > 0.5 && duration < 120 ? 0.8 : 0.4
            let isValid = duration > 0.5 && fileSize > 1000
            
            return AudioFileMetadata(
                url: url,
                duration: duration,
                fileSize: fileSize,
                sampleRate: audioFile.fileFormat.sampleRate,
                channels: Int(audioFile.fileFormat.channelCount),
                bitDepth: 16, // Assuming 16-bit
                creationDate: creationDate,
                isValidForTranscription: isValid,
                qualityScore: qualityScore
            )
        } catch {
            print("❌ AzureSpeechRecognizer: Failed to extract metadata: \(error)")
            return AudioFileMetadata(
                url: url,
                duration: 0,
                fileSize: 0,
                sampleRate: 44100,
                channels: 1,
                bitDepth: 16,
                creationDate: Date(),
                isValidForTranscription: false,
                qualityScore: 0.0
            )
        }
    }
    
    // MARK: - Public Interface Methods
    
    func getLastRecordingURL() -> URL? {
        return lastRecordingURL
    }
    
    func isLastRecordingValidForTranscription() -> Bool {
        return lastRecordingMetadata?.isValidForTranscription ?? false
    }
}

// MARK: - AVAudioRecorderDelegate
extension AzureSpeechRecognizer: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("❌ AzureSpeechRecognizer: Recording did not finish successfully")
            handleError(.recordingInterrupted)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("❌ AzureSpeechRecognizer: Recording encode error: \(error.localizedDescription)")
            handleError(.unknownError(error.localizedDescription))
        }
    }
}