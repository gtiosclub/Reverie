//
//  Transcriber.swift
//  Reverie
//
//  Created by Heather Partridge on 10/30/25.
//

import SwiftUI
import Speech


class Transcriber {
    
    let transcriptionResults: any AsyncSequence<SpeechTranscriber.Result, any Error>
    
    let analyzer: SpeechAnalyzer
    let transcriber: SpeechTranscriber
    var bestAvailableAudioFormat: AVAudioFormat? = nil
    var inputStream: AsyncStream<AnalyzerInput>? = nil
    var inputContinuation: AsyncStream<AnalyzerInput>.Continuation? = nil
    let preset: SpeechTranscriber.Preset = .timeIndexedProgressiveTranscription
    let locale: Locale
    var audioConverter: AVAudioConverter?

    init(locale: Locale) async throws {
            self.locale = locale
            
            
            // Check iOS version
            if #available(iOS 18.0, *) {
                print("✅ iOS 18+ detected")
            } else {
                print("❌ iOS version is below 18.0 - SpeechTranscriber requires iOS 18+")
                throw _Error.notAvailable
            }
            
            // Check speech recognition authorization
            let authStatus = await SFSpeechRecognizer.authorizationStatus()
            
            if authStatus == .denied || authStatus == .restricted {
                throw _Error.notAvailable
            }
            
            guard SpeechTranscriber.isAvailable else {
                throw _Error.notAvailable
            }
            
            do {
                transcriber = SpeechTranscriber(
                    locale: locale,
                    transcriptionOptions: self.preset.transcriptionOptions,
                    reportingOptions: self.preset.reportingOptions.union([.alternativeTranscriptions]),
                    attributeOptions: self.preset.attributeOptions.union([.transcriptionConfidence])
                )
                
                transcriptionResults = transcriber.results
                
                analyzer = SpeechAnalyzer(modules: [transcriber], options: .init(priority: .userInitiated, modelRetention: .processLifetime))
                
                self.bestAvailableAudioFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])
                
                let installedLocales = await SpeechTranscriber.installedLocales
                
                let installed = installedLocales.contains(locale)
                if !installed {
                    if let installationRequest = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                        try await installationRequest.downloadAndInstall()
                    }
                }
            } catch {
                print("❌ Error during transcriber setup: \(error)")
                print("❌ Error type: \(type(of: error))")
                throw _Error.notAvailable
            }
        }
    
    deinit {
        Task { [weak self] in
            await self?.finishAnalysisSession()
        }
    }
    
    func finishAnalysisSession() async {
        self.inputContinuation?.finish()
        
      
        await self.analyzer.cancelAndFinishNow()
            
        
        await AssetInventory.release(reservedLocale: self.locale)

    }
    
    func startRealTimeTranscription() async throws {
        print(#function)
        
        try await self.finalizePreviousTranscribing()

        (inputStream, inputContinuation) = AsyncStream<AnalyzerInput>.makeStream()
        
        try await analyzer.start(inputSequence: inputStream!)
    }
    
    func streamAudioToTranscriber(_ buffer: AVAudioPCMBuffer) {
        // Use the buffer's native format to avoid conversion errors
        var convertedBuffer: AVAudioPCMBuffer = buffer
        
        // Only attempt conversion if we have a different best format
        if let bestFormat = self.bestAvailableAudioFormat, bestFormat != buffer.format {
            do {
                convertedBuffer = try self.convertBuffer(buffer, to: bestFormat)
            } catch {
                print("⚠️ Conversion failed, using original format: \(error)")
                // Fall back to original buffer if conversion fails
                convertedBuffer = buffer
            }
        }
        
        let input: AnalyzerInput = AnalyzerInput(buffer: convertedBuffer)
        self.inputContinuation?.yield(input)
    }
    

    func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        let inputFormat = buffer.format
        
        guard inputFormat != format else {
            return buffer
        }
        
        // Validate output format
        guard format.sampleRate > 0 && format.channelCount > 0 else {
            throw _Error.failedToConvertBuffer("Invalid output format")
        }
        
        // Recreate converter if formats changed
        if audioConverter == nil || audioConverter?.inputFormat != inputFormat || audioConverter?.outputFormat != format {
            guard let converter = AVAudioConverter(from: inputFormat, to: format) else {
                print("❌ Failed to create converter:")
                print("   Input: \(inputFormat)")
                print("   Output: \(format)")
                throw _Error.audioConverterCreationFailed
            }
            audioConverter = converter
            audioConverter?.primeMethod = .none
        }
        
        guard let audioConverter = audioConverter else {
            throw _Error.audioConverterCreationFailed
        }
        
        let sampleRateRatio = audioConverter.outputFormat.sampleRate / audioConverter.inputFormat.sampleRate
        let scaledInputFrameLength = Double(buffer.frameLength) * sampleRateRatio
        let frameCapacity = AVAudioFrameCount(scaledInputFrameLength.rounded(.up))
        guard let conversionBuffer = AVAudioPCMBuffer(pcmFormat: audioConverter.outputFormat, frameCapacity: frameCapacity) else {
            throw _Error.failedToConvertBuffer("Failed to create AVAudioPCMBuffer.")
        }
        
        var nsError: NSError?
        var bufferProcessed = false
        
        let status = audioConverter.convert(to: conversionBuffer, error: &nsError) { packetCount, inputStatusPointer in
            defer { bufferProcessed = true }
            inputStatusPointer.pointee = bufferProcessed ? .noDataNow : .haveData
            return bufferProcessed ? nil : buffer
        }
        
        guard status != .error else {
            throw _Error.failedToConvertBuffer(nsError?.localizedDescription)
        }
        
        return conversionBuffer
    }
    
    func finalizePreviousTranscribing() async throws {
        self.inputContinuation?.finish()
        self.inputStream = nil
        self.inputContinuation = nil
        
        try await self.analyzer.finalize(through: nil)
    }
    
    enum _Error: Error {
        case notAvailable
        
        case audioConverterCreationFailed
        case failedToConvertBuffer(String?)

        var message: String {
            return switch self {
                
            case .notAvailable:
                "Transcriber is not available on the given device."
            
            case .audioConverterCreationFailed:
                "Fail to create Audio Converter"
            case .failedToConvertBuffer(let s):
                "Failed to convert buffer to the destination format. \(s, default: "")"
            }
        }
    }
}
