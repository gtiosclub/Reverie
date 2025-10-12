//
//  ImageGenerationService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/9/25.
//

import Foundation
import CoreML
import StableDiffusion
import Vision
import SwiftUI
import Combine

@Observable
@MainActor
class ImageGenerationService {
    var generatedImage: UIImage?
    var isLoading = false
    var loadingStateText = ""
    var progress: StableDiffusionPipeline.Progress?
    
    private var pipeline: StableDiffusionPipeline?

    init() {
        Task(priority: .high) {
            await loadModel()
        }
    }
    
    func generateSticker(prompt: String) async throws -> UIImage? {
        guard let pipeline = self.pipeline else {
            throw NSError(domain: "ImageGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Pipeline not ready."])
        }

        self.isLoading = true
        self.loadingStateText = "Generating..."
        
        defer {
            self.isLoading = false
            self.loadingStateText = ""
        }
        
        var configuration = StableDiffusionPipeline.Configuration(prompt: prompt)
        configuration.stepCount = 20
        configuration.seed = UInt32.random(in: 0...UInt32.max)
        
        let images = try pipeline.generateImages(configuration: configuration)
        
        guard let finalCGImage = images.compactMap({ $0 }).first else {
            print("⚠️ Stable Diffusion did not produce a valid image.")
            return nil
        }
        
        let uiImage = UIImage(cgImage: finalCGImage)
        
        return try await removeBackground(from: uiImage)
    }

    private func loadModel() async {
        if pipeline != nil { return }
        
        isLoading = true
        loadingStateText = "Loading model..."
        
        do {
            guard let resourceURL = Bundle.main.url(forResource: "StableDiffusionResources", withExtension: nil) else {
                throw NSError(domain: "ImageGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find model resources."])
            }
            
            let loadedPipeline = try StableDiffusionPipeline(
                resourcesAt: resourceURL,
                controlNet: [],
                reduceMemory: true
            )
            
            self.pipeline = loadedPipeline
            self.isLoading = false
            self.loadingStateText = ""
            print("✅ Model loaded successfully.")
            
        } catch {
            print("❌ Error loading Stable Diffusion pipeline: \(error)")
            self.loadingStateText = "Error loading model."
        }
    }
    
    func removeBackground(from image: UIImage) async throws -> UIImage? {
        guard let cgImage = image.cgImage else {
            print("❌ DEBUG: Failed to get CGImage.")
            throw ImageProcessingErrorService.failedToGetCGImage
        }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        try handler.perform([request])
        
        guard let result = request.results?.first else {
            print("❌ DEBUG: Vision request did not find any subject.")
            throw ImageProcessingErrorService.visionRequestFailed
        }

        let maskPixelBuffer = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: handler,
            croppedToInstancesExtent: false
        )

        let originalCIImage = CIImage(cgImage: cgImage)
        let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer)

        guard let compositingFilter = CIFilter(name: "CISourceInCompositing") else {
            throw ImageProcessingErrorService.filterCreationFailed
        }

        compositingFilter.setValue(originalCIImage, forKey: kCIInputImageKey)
        compositingFilter.setValue(maskCIImage, forKey: kCIInputBackgroundImageKey)

        guard let outputCIImage = compositingFilter.outputImage else {
            throw ImageProcessingErrorService.filterFailedToOutput
        }
        
        if outputCIImage.extent.isInfinite || outputCIImage.extent.isEmpty {
            throw ImageProcessingErrorService.infiniteOrEmptyOutput
        }

        let context = CIContext(options: nil)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            throw ImageProcessingErrorService.finalImageCreationFailed
        }
        
        return UIImage(cgImage: outputCGImage)
    }
}
