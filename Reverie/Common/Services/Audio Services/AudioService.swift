//
//  AudioVM.swift
//  Reverie
//
//  Created by Heather Partridge on 10/30/25.
//


import Foundation
import AVFoundation
import Speech
import QuartzCore

@Observable

class AudioService {
    
    let locale: Locale = Locale(languageCode: .english, script: nil, languageRegion: .unitedStates)
    typealias ElapsedTime = TimeInterval
    var isSettingUp: Bool = false
    var volatileTranscript: AttributedString = ""
    var finalizedTranscript: AttributedString = ""
    var isTranscribing: Bool = false
    
    var audioCapturerState: AudioCapturer.EngineState = .stopped {
        didSet {
            if self.audioCapturerState == .started {
                self.audioCapturingStartTime = CACurrentMediaTime()
                return
            }
            if self.audioCapturerState == .stopped {
                self.audioCapturingStartTime = nil
                self.audioInputEvents = nil
                return
            }
        }
    }
    
    var audioInputEvents: ElapsedTime? = nil
    var audioCapturingStartTime: TimeInterval? = nil
    var transcriber: Transcriber?
    var audioCapturer: AudioCapturer?
    
    var transcriptionResultsTask: Task<Void, Error>?
    var audioInputTask: Task<Void, Error>?
    
    init() {
        self.isSettingUp = true
        
        
        
        
        Task {
            do {
                try await self.setupTranscriber(locale: locale)
                try self.setupAudioCapturer()
                self.isSettingUp = false
            } catch (let error) {
                self.error = error
            }
        }
        
    }
    
    deinit {
        self.transcriptionResultsTask?.cancel()
        self.transcriptionResultsTask = nil
        
        self.audioInputTask?.cancel()
        self.audioInputTask = nil
        
        Task { [weak self] in
            await self?.transcriber?.finishAnalysisSession()
        }
    }
    
    var error: Error? {
        didSet {
            if let error = self.error {
                print(error.localizedDescription)
                self.showError = true
                self.isSettingUp = false
            }
        }
    }
    
    var showError: Bool = false {
        didSet {
            if !showError {
                self.error = nil
            }
        }
    }
    
    
    func startRealTimeTranscription() async throws {
        guard self.isTranscribing == false else { return }
        guard self.audioCapturerState == .stopped else { return }
        
        guard let transcriber = self.transcriber else {
            throw _Error.failToCreateTranscriber
        }
        
        guard let audioCapturer = self.audioCapturer else {
            throw _Error.failToCreateAudioCapturer
        }
        
        
        try await audioCapturer.startCapturingInput()
        try await transcriber.startRealTimeTranscription()
        
        self.resetTranscripts()
        self.isTranscribing = true
        self.audioCapturerState = .started
        
    }
    
    func stopTranscription() async throws {
        self.audioCapturer?.stopCapturing()
        try await self.transcriber?.finalizePreviousTranscribing()
        self.audioCapturerState = .stopped
        self.isTranscribing = false
    }
    
    func resetTranscripts() {
        self.volatileTranscript = ""
        self.finalizedTranscript = ""
    }
    

    func setupTranscriber(locale: Locale) async throws {
        do {
            // Check if speech recognition is available
            guard await SFSpeechRecognizer.authorizationStatus() != .denied else {
                throw _Error.failToCreateTranscriber
            }
            
            self.transcriber = try await Transcriber(locale: locale)
            
            transcriptionResultsTask = Task {
                guard let transcriber = self.transcriber else {
                    return
                }
                do {
                    for try await result in transcriber.transcriptionResults {
                        let text = result.text
                        
                        if result.isFinal {
                            let previousConfidence = finalizedTranscript.transcriptionConfidence
                            
                            finalizedTranscript.append(text)
                            
                            if let confidence = text.transcriptionConfidence {
                                finalizedTranscript.transcriptionConfidence = confidence
                            } else {
                                finalizedTranscript.transcriptionConfidence = previousConfidence
                            }
                            
                            volatileTranscript = ""
                        } else {
                            volatileTranscript = text
                        }
                    }
                } catch(let error) {
                    if error is CancellationError {
                        print("task cancelled")
                        return
                    }
                    
                    self.error = error
                    
                    if self.isTranscribing {
                        try await self.stopTranscription()
                    }
                }
            }
        } catch {
            print("❌ Failed to setup transcriber: \(error)")
            throw _Error.failToCreateTranscriber
        }
    }
    
    func setupAudioCapturer() throws {
        self.audioCapturer = try AudioCapturer()
        
        audioInputTask = Task {
            guard let audioCapturer = self.audioCapturer else {
                return
            }
            for await (buffer, time) in audioCapturer.inputTapEventsStream {
                if self.audioCapturerState == .started {
                    
                    self.transcriber?.streamAudioToTranscriber(buffer)
                    
                    if let startTime = self.audioCapturingStartTime {
                        self.audioInputEvents = AVAudioTime.seconds(forHostTime: time.hostTime) - startTime
                    }
                }
            }
        }
    }
    enum _Error: Error {
        case failToCreateAudioCapturer
        case failToCreateTranscriber
        var message: String {
            switch self  {
                
            case .failToCreateAudioCapturer:
                "Failed to setup Audio Engine."
            case .failToCreateTranscriber:
                "Failed to set up speech analyzer."
            }
        }
        
    }
}
