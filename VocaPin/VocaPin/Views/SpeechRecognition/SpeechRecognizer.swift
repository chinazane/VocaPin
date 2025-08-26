//
//  SpeechRecognizer.swift
//  VocaPin
//
//  Created by Kiro on 8/26/25.
//

import Foundation
import Speech
import AVFoundation

// MARK: - Audio Recording Configuration
struct AudioRecordingConfig {
    static let sampleRate: Double = 44100.0
    static let channels: Int = 1
    static let bitDepth: Int = 16
    static let fileFormat: AudioFileTypeID = kAudioFileWAVEType
    
    static var settings: [String: Any] {
        return [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVLinearPCMBitDepthKey: bitDepth,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
    }
}

// MARK: - File Naming Utility
struct AudioFileNaming {
    static func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return "VocaPin_Recording_\(formatter.string(from: Date())).wav"
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    static func getRecordingsDirectory() -> URL {
        let documentsDirectory = getDocumentsDirectory()
        let recordingsDirectory = documentsDirectory.appendingPathComponent("VocaPin_Recordings")
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: recordingsDirectory.path) {
            try? FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
        }
        
        return recordingsDirectory
    }
}

// MARK: - File Management Utility
struct AudioFileManager {
    static let maxFileAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    static let maxTotalSize: Int64 = 100 * 1024 * 1024 // 100MB
    
    static func getAllRecordingFiles() -> [URL] {
        let recordingsDirectory = AudioFileNaming.getRecordingsDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: recordingsDirectory,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )
            
            return files.filter { $0.pathExtension.lowercased() == "wav" }
        } catch {
            print("Error getting recording files: \(error)")
            return []
        }
    }
    
    static func getFileSize(at url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    static func getFileCreationDate(at url: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.creationDate] as? Date
        } catch {
            return nil
        }
    }
    
    static func getTotalRecordingsSize() -> Int64 {
        let files = getAllRecordingFiles()
        return files.reduce(0) { total, url in
            total + getFileSize(at: url)
        }
    }
    
    static func cleanupOldFiles() -> Int {
        let files = getAllRecordingFiles()
        let cutoffDate = Date().addingTimeInterval(-maxFileAge)
        var deletedCount = 0
        
        for file in files {
            if let creationDate = getFileCreationDate(at: file),
               creationDate < cutoffDate {
                do {
                    try FileManager.default.removeItem(at: file)
                    deletedCount += 1
                    print("Deleted old recording: \(file.lastPathComponent)")
                } catch {
                    print("Failed to delete file \(file.lastPathComponent): \(error)")
                }
            }
        }
        
        return deletedCount
    }
    
    static func cleanupLargestFiles(targetSize: Int64) -> Int {
        let files = getAllRecordingFiles()
        let currentSize = getTotalRecordingsSize()
        
        guard currentSize > targetSize else { return 0 }
        
        // Sort files by size (largest first)
        let sortedFiles = files.sorted { file1, file2 in
            getFileSize(at: file1) > getFileSize(at: file2)
        }
        
        var deletedCount = 0
        var remainingSize = currentSize
        
        for file in sortedFiles {
            if remainingSize <= targetSize { break }
            
            let fileSize = getFileSize(at: file)
            do {
                try FileManager.default.removeItem(at: file)
                remainingSize -= fileSize
                deletedCount += 1
                print("Deleted large recording: \(file.lastPathComponent) (\(fileSize) bytes)")
            } catch {
                print("Failed to delete file \(file.lastPathComponent): \(error)")
            }
        }
        
        return deletedCount
    }
    
    static func performMaintenanceCleanup() -> (deletedOld: Int, deletedLarge: Int) {
        let deletedOld = cleanupOldFiles()
        let deletedLarge = cleanupLargestFiles(targetSize: maxTotalSize)
        
        let totalSize = getTotalRecordingsSize()
        let fileCount = getAllRecordingFiles().count
        
        print("File maintenance completed:")
        print("- Deleted \(deletedOld) old files")
        print("- Deleted \(deletedLarge) large files")
        print("- Remaining: \(fileCount) files, \(totalSize) bytes")
        
        return (deletedOld, deletedLarge)
    }
}

// MARK: - Audio Recording Errors
enum AudioRecordingError: Error {
    case permissionDenied
    case fileCreationFailed
    case recordingInterrupted
    case insufficientStorage
    case audioSessionFailed
    case speechRecognitionUnavailable
    case networkError
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "Microphone access required for recording"
        case .fileCreationFailed:
            return "Unable to create recording file"
        case .recordingInterrupted:
            return "Recording was interrupted"
        case .insufficientStorage:
            return "Insufficient storage space for recording"
        case .audioSessionFailed:
            return "Audio system configuration failed"
        case .speechRecognitionUnavailable:
            return "Speech recognition is not available"
        case .networkError:
            return "Network connection required for speech recognition"
        case .unknownError(let message):
            return "An unexpected error occurred: \(message)"
        }
    }
    
    var userFriendlyMessage: String {
        switch self {
        case .permissionDenied:
            return "Please allow microphone access in Settings to record audio"
        case .fileCreationFailed:
            return "Unable to save recording. Please check available storage"
        case .recordingInterrupted:
            return "Recording was interrupted. Please try again"
        case .insufficientStorage:
            return "Not enough storage space. Please free up space and try again"
        case .audioSessionFailed:
            return "Audio system error. Please restart the app and try again"
        case .speechRecognitionUnavailable:
            return "Speech recognition is not available on this device"
        case .networkError:
            return "Internet connection required for speech recognition"
        case .unknownError:
            return "Something went wrong. Please try again"
        }
    }
    
    var recoveryAction: String? {
        switch self {
        case .permissionDenied:
            return "Open Settings"
        case .fileCreationFailed, .insufficientStorage:
            return "Free Up Space"
        case .recordingInterrupted, .audioSessionFailed, .unknownError:
            return "Try Again"
        case .speechRecognitionUnavailable:
            return nil
        case .networkError:
            return "Check Connection"
        }
    }
}

class SpeechRecognizer: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Existing properties
    @Published var audioLevel: Float = 0.0
    
    // Enhanced audio level properties
    @Published var smoothedAudioLevel: Float = 0.0
    @Published var peakAudioLevel: Float = 0.0
    private var audioLevelHistory: [Float] = []
    private let audioLevelHistorySize = 10
    private var lastAudioLevelUpdate = Date()
    
    // Real-time waveform data
    @Published var waveformData: [Float] = Array(repeating: 0.0, count: 50)
    
    // New properties for audio recording
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    @Published var isRecordingAudio: Bool = false
    @Published var recordingStatus: String = "Ready"
    private var recordingSessionID: String = ""
    
    // Error handling properties
    @Published var currentError: AudioRecordingError?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    private var errorCallback: ((AudioRecordingError) -> Void)?
    
    // File management properties
    @Published var totalRecordingsSize: Int64 = 0
    @Published var recordingFileCount: Int = 0
    private var maintenanceTimer: Timer?
    
    func startRecording(completion: @escaping (String) -> Void) {
        // Clear any previous errors
        dismissError()
        
        // Check permissions first
        if let permissionError = checkPermissions() {
            handleError(permissionError)
            return
        }
        
        // Check storage space
        if !checkStorageSpace() {
            handleError(.insufficientStorage)
            return
        }
        
        // Cancel any previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session first
        guard configureAudioSession() else {
            handleError(.audioSessionFailed)
            return
        }
        
        // Setup audio file recording
        if setupAudioRecording() == nil {
            logRecordingError("Failed to setup audio recording, continuing with speech recognition only", url: nil)
            // Don't treat this as a fatal error - continue with speech recognition
        }
        
        // Start audio file recording
        startAudioFileRecording()
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request")
            stopAudioFileRecording() // Clean up audio recording if speech recognition fails
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Get audio input node
        let inputNode = audioEngine.inputNode
        
        // Install tap on audio input with smaller buffer for more responsive updates
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
            
            // Calculate audio level for wave visualization - this runs frequently
            self.updateAudioLevel(from: buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start failed: \(error)")
            stopAudioFileRecording() // Clean up audio recording if engine fails
            return
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    completion(recognizedText)
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }
    }
    
    private func configureAudioSession() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            updateRecordingStatus("Audio session configured")
            return true
        } catch {
            logRecordingError("Audio session setup failed: \(error.localizedDescription)", url: nil)
            handleError(.audioSessionFailed)
            return false
        }
    }
    
    func stopRecording() {
        // Stop audio file recording first
        stopAudioFileRecording()
        
        // Stop speech recognition
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Reset audio levels and history
        DispatchQueue.main.async {
            self.audioLevel = 0.0
            self.smoothedAudioLevel = 0.0
            self.peakAudioLevel = 0.0
            self.waveformData = Array(repeating: 0.0, count: 50)
        }
        audioLevelHistory.removeAll()
        
        // Final status update
        updateRecordingStatus("Recording stopped")
    }
    
    private func updateAudioLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        // Calculate multiple audio metrics
        let rms = calculateRMS(from: channelDataArray)
        let peak = calculatePeak(from: channelDataArray)
        let dynamicRange = calculateDynamicRange(from: channelDataArray)
        
        // Apply frequency-aware processing
        let frequencyWeightedLevel = applyFrequencyWeighting(rms: rms, peak: peak, dynamicRange: dynamicRange)
        
        // Normalize the level (enhanced normalization)
        let normalizedLevel = enhancedNormalization(frequencyWeightedLevel)
        
        // Apply smoothing
        let smoothedLevel = applySmoothingFilter(normalizedLevel)
        
        // Generate real waveform data from audio buffer
        let waveformData = generateWaveformFromBuffer(channelDataArray)
        
        // Debug: Log audio levels occasionally
        if Date().timeIntervalSince(lastAudioLevelUpdate) > 0.5 {
           // print("Audio Debug - RMS: \(rms), Peak: \(peak), Normalized: \(normalizedLevel)")
           // print("Waveform sample: \(waveformData.prefix(5))")
           // print("Waveform range: min=\(waveformData.min() ?? 0), max=\(waveformData.max() ?? 0)")
           // print("Raw samples range: min=\(channelDataArray.min() ?? 0), max=\(channelDataArray.max() ?? 0)")
            lastAudioLevelUpdate = Date()
        }
        
        // Update on main thread
        DispatchQueue.main.async {
            self.audioLevel = normalizedLevel
            self.smoothedAudioLevel = smoothedLevel
            self.peakAudioLevel = peak
            self.waveformData = waveformData
        }
    }
    
    // MARK: - Enhanced Audio Processing Methods
    
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
        // Combine RMS, peak, and dynamic range for more realistic representation
        let rmsWeight: Float = 0.6
        let peakWeight: Float = 0.3
        let dynamicWeight: Float = 0.1
        
        return (rms * rmsWeight) + (peak * peakWeight) + (dynamicRange * dynamicWeight)
    }
    
    private func enhancedNormalization(_ level: Float) -> Float {
        // Apply logarithmic scaling for more natural audio level representation
        let logLevel = log10(max(level * 100, 0.001)) / 2.0 // log10(100) = 2
        let normalizedLevel = max(min(logLevel + 1.0, 1.0), 0.0) // Shift and clamp to [0,1]
        
        // Apply sensitivity curve for better visual representation
        return applySensitivityCurve(normalizedLevel)
    }
    
    private func applySensitivityCurve(_ level: Float) -> Float {
        // Apply a curve that makes quiet sounds more visible and prevents saturation
        return pow(level, 0.7) // Power curve for better visual dynamics
    }
    
    private func applySmoothingFilter(_ currentLevel: Float) -> Float {
        // Add to history
        audioLevelHistory.append(currentLevel)
        if audioLevelHistory.count > audioLevelHistorySize {
            audioLevelHistory.removeFirst()
        }
        
        // Calculate weighted average (more weight to recent samples)
        var weightedSum: Float = 0
        var totalWeight: Float = 0
        
        for (index, level) in audioLevelHistory.enumerated() {
            let weight = Float(index + 1) // More recent samples get higher weight
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
        
        // Calculate samples per bar
        let samplesPerBar = max(1, samples.count / waveformBars)
        var waveformData: [Float] = []
        
        for barIndex in 0..<waveformBars {
            let startIndex = barIndex * samplesPerBar
            let endIndex = min(startIndex + samplesPerBar, samples.count)
            
            if startIndex < samples.count {
                // Get samples for this bar
                let barSamples = Array(samples[startIndex..<endIndex])
                
                // Calculate RMS for this segment
                let rms = calculateRMS(from: barSamples)
                
                // Apply more aggressive normalization for better visibility
                let normalizedRMS = aggressiveNormalization(rms)
                
                waveformData.append(normalizedRMS)
            } else {
                waveformData.append(0.0)
            }
        }
        
        return waveformData
    }
    
    private func aggressiveNormalization(_ level: Float) -> Float {
        // Much more conservative normalization that respects silence
        
        // Define silence threshold - below this is considered silence
        let silenceThreshold: Float = 0.001
        
        if level < silenceThreshold {
            // True silence - return 0
            return 0.0
        }
        
        // For non-silence, apply moderate scaling
        let amplified = level * 10.0 // Reduced amplification
        
        // Simple linear scaling with a cap
        let normalized = min(amplified, 1.0)
        
        return normalized
    }
    

    
    // MARK: - File Management Methods
    
    func updateFileStatistics() {
        DispatchQueue.global(qos: .utility).async {
            let size = AudioFileManager.getTotalRecordingsSize()
            let count = AudioFileManager.getAllRecordingFiles().count
            
            DispatchQueue.main.async {
                self.totalRecordingsSize = size
                self.recordingFileCount = count
            }
        }
    }
    
    private func performMaintenanceIfNeeded() {
        // Check if maintenance is needed
        let currentSize = AudioFileManager.getTotalRecordingsSize()
        let maxSize = AudioFileManager.maxTotalSize
        
        if currentSize > maxSize * 8 / 10 { // 80% of max size
            DispatchQueue.global(qos: .utility).async {
                let result = AudioFileManager.performMaintenanceCleanup()
                
                DispatchQueue.main.async {
                    self.logRecordingEvent("Maintenance cleanup completed: \(result.deletedOld) old files, \(result.deletedLarge) large files deleted", url: nil)
                    self.updateFileStatistics()
                }
            }
        }
    }
    
    func performManualCleanup() {
        DispatchQueue.global(qos: .utility).async {
            let result = AudioFileManager.performMaintenanceCleanup()
            
            DispatchQueue.main.async {
                self.logRecordingEvent("Manual cleanup completed: \(result.deletedOld) old files, \(result.deletedLarge) large files deleted", url: nil)
                self.updateFileStatistics()
                self.updateRecordingStatus("Cleanup completed")
            }
        }
    }
    
    func getAllRecordings() -> [URL] {
        return AudioFileManager.getAllRecordingFiles()
    }
    
    func deleteRecording(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            logRecordingEvent("Recording deleted: \(url.lastPathComponent)", url: url)
            updateFileStatistics()
            return true
        } catch {
            logRecordingError("Failed to delete recording: \(error.localizedDescription)", url: url)
            return false
        }
    }
    
    private func startMaintenanceTimer() {
        // Perform maintenance every hour
        maintenanceTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.performMaintenanceIfNeeded()
        }
    }
    
    private func stopMaintenanceTimer() {
        maintenanceTimer?.invalidate()
        maintenanceTimer = nil
    }
    
    // MARK: - Audio Recording Methods
    
    private func setupAudioRecording() -> URL? {
        // Check microphone permission first
        let recordPermission = AVAudioSession.sharedInstance().recordPermission
        guard recordPermission == .granted else {
            logRecordingError("Microphone permission not granted: \(recordPermission.rawValue)", url: nil)
            return nil
        }
        
        // Perform maintenance cleanup before creating new file
        performMaintenanceIfNeeded()
        
        let recordingsDirectory = AudioFileNaming.getRecordingsDirectory()
        let filename = AudioFileNaming.generateFilename()
        let url = recordingsDirectory.appendingPathComponent(filename)
        
        // Generate session ID for logging
        recordingSessionID = UUID().uuidString.prefix(8).uppercased()
        
        // Log intended file path
        logRecordingEvent("Recording setup initiated", url: url)
        updateRecordingStatus("Setting up recording...")
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: AudioRecordingConfig.settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            recordingURL = url
            logRecordingEvent("Audio recorder configured successfully", url: url)
            updateRecordingStatus("Recording ready")
            return url
        } catch {
            logRecordingError("Failed to setup audio recorder: \(error.localizedDescription)", url: url)
            return nil
        }
    }
    
    private func startAudioFileRecording() {
        guard let recorder = audioRecorder else {
            logRecordingError("Audio recorder not configured", url: recordingURL)
            updateRecordingStatus("Recording setup failed")
            return
        }
        
        let success = recorder.record()
        if success {
            DispatchQueue.main.async {
                self.isRecordingAudio = true
            }
            updateRecordingStatus("Recording audio to file")
            logRecordingEvent("Audio file recording started", url: recordingURL)
        } else {
            logRecordingError("Failed to start audio file recording", url: recordingURL)
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
            logRecordingEvent("Audio file recording stopped and saved", url: url)
            updateRecordingStatus("Recording saved")
        } else {
            updateRecordingStatus("Recording completed")
        }
        
        audioRecorder = nil
        recordingURL = nil
        
        // Reset status after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.updateRecordingStatus("Ready")
        }
    }
    
    // MARK: - Error Handling and Cleanup
    
    private func handleRecordingInterruption() {
        logRecordingError("Recording interrupted by system", url: recordingURL)
        stopAudioFileRecording()
    }
    
    private func cleanupRecordingResources() {
        if let recorder = audioRecorder, recorder.isRecording {
            recorder.stop()
        }
        audioRecorder = nil
        recordingURL = nil
        DispatchQueue.main.async {
            self.isRecordingAudio = false
        }
    }
    
    // MARK: - Status Management
    
    private func updateRecordingStatus(_ status: String) {
        DispatchQueue.main.async {
            self.recordingStatus = status
        }
    }
    
    // MARK: - Error Handling
    
    func setErrorCallback(_ callback: @escaping (AudioRecordingError) -> Void) {
        errorCallback = callback
    }
    
    private func handleError(_ error: AudioRecordingError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.errorMessage = error.userFriendlyMessage
            self.showError = true
            self.updateRecordingStatus("Error: \(error.localizedDescription)")
        }
        
        logRecordingError("Error occurred: \(error.localizedDescription)", url: recordingURL)
        errorCallback?(error)
    }
    
    func dismissError() {
        DispatchQueue.main.async {
            self.showError = false
            self.currentError = nil
            self.errorMessage = ""
            self.updateRecordingStatus("Ready")
        }
    }
    
    private func checkStorageSpace() -> Bool {
        do {
            let documentsDirectory = AudioFileNaming.getDocumentsDirectory()
            let resourceValues = try documentsDirectory.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            
            if let availableCapacity = resourceValues.volumeAvailableCapacity {
                let requiredSpace: Int64 = 10 * 1024 * 1024 // 10MB minimum
                return availableCapacity > requiredSpace
            }
        } catch {
            logRecordingError("Failed to check storage space: \(error.localizedDescription)", url: nil)
        }
        return true // Assume sufficient space if check fails
    }
    
    private func checkPermissions() -> AudioRecordingError? {
        // Check microphone permission
        let recordPermission = AVAudioSession.sharedInstance().recordPermission
        if recordPermission != .granted {
            return .permissionDenied
        }
        
        // Check speech recognition permission
        let speechAuthStatus = SFSpeechRecognizer.authorizationStatus()
        if speechAuthStatus != .authorized {
            return .speechRecognitionUnavailable
        }
        
        return nil
    }
    
    // MARK: - Logging Methods
    
    private func logRecordingEvent(_ message: String, url: URL?) {
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        let urlString = url?.path ?? "No URL"
        print("[\(timestamp)] [VocaPin-Recording-\(recordingSessionID)] \(message)")
        print("[\(timestamp)] [VocaPin-Recording-\(recordingSessionID)] File Path: \(urlString)")
    }
    
    private func logRecordingError(_ message: String, url: URL?) {
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        let urlString = url?.path ?? "No URL"
        print("[\(timestamp)] [VocaPin-Recording-\(recordingSessionID)] ERROR: \(message)")
        print("[\(timestamp)] [VocaPin-Recording-\(recordingSessionID)] Attempted Path: \(urlString)")
    }
}

// MARK: - AVAudioRecorderDelegate
extension SpeechRecognizer: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            logRecordingEvent("Recording completed successfully", url: recorder.url)
            
            // Check file size and log it
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: recorder.url.path)
                if let fileSize = attributes[.size] as? Int64 {
                    let fileSizeKB = Double(fileSize) / 1024.0
                    logRecordingEvent("File size: \(String(format: "%.2f", fileSizeKB)) KB", url: recorder.url)
                }
            } catch {
                logRecordingError("Could not get file size: \(error.localizedDescription)", url: recorder.url)
            }
        } else {
            logRecordingError("Recording failed to complete", url: recorder.url)
        }
        
        // Clean up resources
        cleanupRecordingResources()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            logRecordingError("Encoding error occurred: \(error.localizedDescription)", url: recorder.url)
        }
        handleRecordingInterruption()
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        logRecordingEvent("Recording interrupted (begin)", url: recorder.url)
        handleRecordingInterruption()
    }
    
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {
        logRecordingEvent("Recording interruption ended", url: recorder.url)
        // Note: We don't automatically resume recording after interruption
        // The user will need to start a new recording session
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
