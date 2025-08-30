import UIKit
import AVFoundation

class StickyNoteViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stickyNotesStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var processButton: UIButton!
    
    // MARK: - Services
   // private let voiceService = VoiceToStickyNoteService()
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    // MARK: - State
    private var isRecording = false
    //private var stickyNotes: [StickyNote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Voice Sticky Notes"
        
        recordButton.setTitle("🎤 Start Recording", for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.layer.cornerRadius = 8
        recordButton.setTitleColor(.white, for: .normal)
        
        processButton.setTitle("📝 Process Last Recording", for: .normal)
        processButton.backgroundColor = .systemGreen
        processButton.layer.cornerRadius = 8
        processButton.setTitleColor(.white, for: .normal)
        processButton.isEnabled = false
        
        statusLabel.text = "Ready to record"
        statusLabel.textAlignment = .center
        
        // Setup stack view for sticky notes
        stickyNotesStackView.axis = .vertical
        stickyNotesStackView.spacing = 12
        stickyNotesStackView.distribution = .fill
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // Request microphone permission
            audioSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        self?.showAlert(title: "Microphone Access", message: "Please enable microphone access in Settings to record voice notes.")
                    }
                }
            }
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Recording Actions
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @IBAction func processButtonTapped(_ sender: UIButton) {
        guard let audioURL = recordingURL else {
            showAlert(title: "No Recording", message: "Please record audio first.")
            return
        }
        
       // processAudioFile(audioURL)
    }
    
    private func startRecording() {
        // Create recording URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("voice_note_\(Date().timeIntervalSince1970).wav")
        
        // Audio settings
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            recordingURL = audioFilename
            isRecording = true
            
            // Update UI
            recordButton.setTitle("⏹️ Stop Recording", for: .normal)
            recordButton.backgroundColor = .systemRed
            statusLabel.text = "Recording... Speak your tasks and reminders"
            processButton.isEnabled = false
            
        } catch {
            showAlert(title: "Recording Error", message: "Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        
        // Update UI
        recordButton.setTitle("🎤 Start Recording", for: .normal)
        recordButton.backgroundColor = .systemBlue
        statusLabel.text = "Recording saved. Tap 'Process' to create sticky notes."
        processButton.isEnabled = true
    }
    
    // MARK: - Audio Processing
  /*  private func processAudioFile(_ audioURL: URL) {
        statusLabel.text = "🔄 Processing audio... This may take a moment"
        processButton.isEnabled = false
        
        voiceService.processVoiceRecording(audioFileURL: audioURL) { [weak self] result in
            DispatchQueue.main.async {
                self?.processButton.isEnabled = true
                
                switch result {
                case .success(let notes):
                    self?.handleProcessingSuccess(notes)
                case .failure(let error):
                    self?.handleProcessingError(error)
                }
            }
        }
    }
    */
   /* private func handleProcessingSuccess(_ notes: [StickyNote]) {
        stickyNotes = notes
        
        if notes.isEmpty {
            statusLabel.text = "No actionable tasks found in the recording. Try speaking about specific tasks or reminders."
            return
        }
        
        statusLabel.text = "✅ Created \(notes.count) sticky note\(notes.count == 1 ? "" : "s")"
        displayStickyNotes(notes)
    }*/
    
    private func handleProcessingError(_ error: Error) {
        statusLabel.text = "❌ Processing failed"
        showAlert(title: "Processing Error", message: error.localizedDescription)
    }
    
    // MARK: - UI Display
   /* private func displayStickyNotes(_ notes: [StickyNote]) {
        // Clear existing notes
        stickyNotesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new sticky notes
        for (index, note) in notes.enumerated() {
            let noteView = createStickyNoteView(note: note, index: index)
            stickyNotesStackView.addArrangedSubview(noteView)
        }
        
        // Scroll to show the notes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollView.scrollRectToVisible(self.stickyNotesStackView.frame, animated: true)
        }
    }*/
    
   /*private func createStickyNoteView(note: StickyNote, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = getColorForTag(note.tag)
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 4
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "📌 \(note.taskTitle)"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        
        // Due date and tag
        let metaLabel = UILabel()
        metaLabel.text = "📅 \(note.dueDate) • #\(note.tag)"
        metaLabel.font = UIFont.systemFont(ofSize: 14)
        metaLabel.textColor = .systemGray
        
        // Details
        let detailsLabel = UILabel()
        detailsLabel.text = note.text
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.numberOfLines = 0
        
        // Reminder
        if note.reminderAlerts != "-" {
            let reminderLabel = UILabel()
            reminderLabel.text = "⏰ \(note.reminderAlerts)"
            reminderLabel.font = UIFont.systemFont(ofSize: 12)
            reminderLabel.textColor = .systemOrange
            stackView.addArrangedSubview(reminderLabel)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(metaLabel)
        stackView.addArrangedSubview(detailsLabel)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        return containerView
    }
   */
    private func getColorForTag(_ tag: String) -> UIColor {
        switch tag.lowercased() {
        case "email": return UIColor.systemBlue.withAlphaComponent(0.1)
        case "call": return UIColor.systemGreen.withAlphaComponent(0.1)
        case "meeting": return UIColor.systemPurple.withAlphaComponent(0.1)
        case "review": return UIColor.systemOrange.withAlphaComponent(0.1)
        case "errand": return UIColor.systemYellow.withAlphaComponent(0.1)
        case "purchase": return UIColor.systemPink.withAlphaComponent(0.1)
        case "travel": return UIColor.systemTeal.withAlphaComponent(0.1)
        case "deadline": return UIColor.systemRed.withAlphaComponent(0.1)
        case "reminder": return UIColor.systemIndigo.withAlphaComponent(0.1)
        default: return UIColor.systemGray.withAlphaComponent(0.1)
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVAudioRecorderDelegate
extension StickyNoteViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            showAlert(title: "Recording Failed", message: "The audio recording was not completed successfully.")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            showAlert(title: "Recording Error", message: "An error occurred during recording: \(error.localizedDescription)")
        }
    }
}
