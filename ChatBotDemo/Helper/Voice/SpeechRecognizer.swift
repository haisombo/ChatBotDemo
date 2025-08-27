//
//  SpeechRecognizer.swift
//  ChatBotDemo
//
//  Voice to Text Conversion Handler
//

import Foundation
import Speech
import AVFoundation
import SwiftUI

class SpeechRecognizer: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var transcript = ""
    @Published var isAuthorized = false
    
    // MARK: - Private Properties
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer?
    private var audioSession: AVAudioSession?
    
    // Callbacks
    private var onTranscriptionUpdate: ((String) -> Void)?
    private var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(locale: Locale = Locale(identifier: "en-US")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        setupAudioSession()
    }
    
    // MARK: - Setup Methods
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    self?.isAuthorized = false
                @unknown default:
                    self?.isAuthorized = false
                }
            }
        }
    }
    
    // MARK: - Start Transcribing
    func startTranscribing(
        onUpdate: @escaping (String) -> Void,
        onError: @escaping (String) -> Void
    ) {
        // Store callbacks
        self.onTranscriptionUpdate = onUpdate
        self.onError = onError
        
        // Check if speech recognizer is available
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            onError("Speech recognition is not available")
            return
        }
        
        // Check authorization
        guard isAuthorized else {
            onError("Speech recognition is not authorized")
            return
        }
        
        // Stop any ongoing task
        stopTranscribing()
        
        do {
            // Configure audio session
            try audioSession?.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession?.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Create and configure the speech recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else {
                onError("Unable to create recognition request")
                return
            }
            
            // Configure request for real-time results
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.requiresOnDeviceRecognition = false
            
            // Get the audio input node
            let inputNode = audioEngine.inputNode
            
            // Remove any existing tap to avoid errors
            inputNode.removeTap(onBus: 0)
            
            // Create recognition task
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                var isFinal = false
                
                if let result = result {
                    // Update transcript with the latest result
                    self.transcript = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                    
                    // Call the update callback
                    DispatchQueue.main.async {
                        self.onTranscriptionUpdate?(self.transcript)
                    }
                }
                
                // Handle errors or final results
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self.onError?(error.localizedDescription)
                        }
                    }
                }
            }
            
            // Configure the microphone input
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // Install tap on input node to capture audio
            inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: recordingFormat
            ) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }
            
            // Start the audio engine
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
            
        } catch {
            onError("Failed to start recording: \(error.localizedDescription)")
            stopTranscribing()
        }
    }
    
    // MARK: - Stop Transcribing
    func stopTranscribing() {
        // Stop the audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End the recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel the recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Deactivate audio session
        try? audioSession?.setActive(false, options: .notifyOthersOnDeactivation)
        
        isRecording = false
    }
    
    // MARK: - Cleanup
    deinit {
        stopTranscribing()
    }
}

// MARK: - Helper Extension for Multi-language Support
extension SpeechRecognizer {
    
    // Get available languages
    static func availableLanguages() -> [Locale] {
        return SFSpeechRecognizer.supportedLocales().sorted {
            $0.identifier < $1.identifier
        }
    }
    
    // Check if a specific language is supported
    static func isLanguageSupported(_ locale: Locale) -> Bool {
        return SFSpeechRecognizer.supportedLocales().contains(locale)
    }
    
    // Change the recognition language
    func changeLanguage(to locale: Locale) -> SpeechRecognizer {
        stopTranscribing()
        return SpeechRecognizer(locale: locale)
    }
}
