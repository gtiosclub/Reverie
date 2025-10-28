//
//  ImageGenerationService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/9/25.
//

import Foundation
import SwiftUI
import CoreML
import StableDiffusion
import Vision

actor ImageGenerationService {
    static let shared = ImageGenerationService()
    
    private var pipeline: StableDiffusionPipeline!

    private init() {
        Task(priority: .utility) {
            await loadModel()
        }
    }

    func getPipeline() async -> StableDiffusionPipeline {
        while pipeline == nil {
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return pipeline
    }

    func generateSticker(prompt: String, isSticker: Bool) async throws -> UIImage? {
        print("coreml generating - waiting for pipeline")
        let strongPipeline = await getPipeline()
        print("coreml generating - pipeline acquired")

        let generatedImage: UIImage? = try await Task.detached(priority: .utility) {
            var config = StableDiffusionPipeline.Configuration(prompt: prompt)
            config.stepCount = 20
            config.seed = UInt32.random(in: 0...UInt32.max)
            let images = try strongPipeline.generateImages(configuration: config)
            guard let cgImage = images.compactMap({ $0 }).first else { return nil }
            return UIImage(cgImage: cgImage)
        }.value

        guard let generatedImage = generatedImage, !Task.isCancelled else { return nil }
        
        if isSticker {
            print("Removing background")
            do {
                return try await ImageGenerationService.removeBackground(from: generatedImage)
            } catch {
                print("Background removal failed. Returning original image.")
                return generatedImage
            }
        } else {
            return generatedImage
        }
    }

    func loadModel() async {
        guard pipeline == nil else { return }
        print("Loading Stable Diffusion model...")
        do {
            guard let url = Bundle.main.url(forResource: "StableDiffusionResources", withExtension: nil) else {
                print("Error: Model resources missing")
                return
            }
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndNeuralEngine
            let loaded = try StableDiffusionPipeline(
                resourcesAt: url,
                controlNet: [],
                configuration: config,
                reduceMemory: true
            )
            pipeline = loaded
            print("Model loaded successfully")
        } catch {
            print("Error loading model: \(error)")
        }
    }

    static func removeBackground(from image: UIImage) async throws -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        guard !Task.isCancelled else { return nil }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        guard let result = request.results?.first else { return image }

        let maskBuffer = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: handler,
            croppedToInstancesExtent: false
        )
        let originalCI = CIImage(cgImage: cgImage)
        let maskCI = CIImage(cvPixelBuffer: maskBuffer)
        guard let filter = CIFilter(name: "CISourceInCompositing") else { return image }
        filter.setValue(originalCI, forKey: kCIInputImageKey)
        filter.setValue(maskCI, forKey: kCIInputBackgroundImageKey)
        guard let output = filter.outputImage else { return image }
        let context = CIContext()
        guard let outputCG = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: outputCG)
    }
}
