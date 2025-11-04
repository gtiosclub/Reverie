//
//  AudioCapture.swift
//  Reverie
//
//  Created by Heather Partridge on 10/30/25.
//


import Foundation
@preconcurrency import AVFAudio

nonisolated class AudioCapturer {
    
    let inputTapEventsStream: AsyncStream<(AVAudioPCMBuffer, AVAudioTime)>
    private let inputTapEventsContinuation: AsyncStream<(AVAudioPCMBuffer, AVAudioTime)>.Continuation
    
    private let audioEngine = AVAudioEngine()
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()

    private let bufferSize: UInt32 = 1024

    init() throws {
        (self.inputTapEventsStream, self.inputTapEventsContinuation) = AsyncStream.makeStream(of: (AVAudioPCMBuffer, AVAudioTime).self)
        try self.configureAudioSession()
    }
    

    private func configureAudioSession() throws {
        // Use voiceChat mode for better speech recognition compatibility
        try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetoothHFP, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Set preferred sample rate for speech recognition
        try audioSession.setPreferredSampleRate(16000)
        
        guard let availableInputs = audioSession.availableInputs,
              let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
            throw _Error.builtinMicNotFound
        }
        try audioSession.setPreferredInput(builtInMicInput)
    }


    func startCapturingInput() async throws {
        print(#function)
        try await self.checkRecordingPermission()
        
        self.audioEngine.reset()

        let inputNode = audioEngine.inputNode
        
        // Proceed without requiring voice processing; `.measurement` mode typically disables it.
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: self.bufferSize, format: format) { (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
            self.inputTapEventsContinuation.yield((buffer, time))
        }
        
        audioEngine.prepare()
       
        try audioEngine.start()
    }
    
    func pauseCapturing() {
        self.audioEngine.pause()
    }
    
    func resumeCapturing() throws {
        try self.audioEngine.start()
    }

    func stopCapturing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        
        self.audioEngine.reset()
    }
    
    
    private func checkRecordingPermission() async throws {
        let permission = AVAudioApplication.shared.recordPermission
        switch permission {
            
        case .undetermined:
            let result = await AVAudioApplication.requestRecordPermission()
            if !result {
                throw _Error.permissionDenied
            }
            return
            
        case .denied:
            throw _Error.permissionDenied
            
        case .granted:
            return
            
        @unknown default:
            throw _Error.unknownPermission
        }
    }
    
    enum EngineState {
        case started
        case stopped
    }
    
    enum _Error: Error {
        
        case permissionDenied
        case unknownPermission
        case builtinMicNotFound
        case inputNotEnabled
        
        var message: String {
            switch self  {
                
            case .permissionDenied:
                "Capturing Permission Denied."
            case .unknownPermission:
                "Unknown Capturing Permission."
                
            case .builtinMicNotFound:
                "Built in Mic is not found."
                           
            case .inputNotEnabled:
                "Input node is not available to use"
            }
        }
    }
}
