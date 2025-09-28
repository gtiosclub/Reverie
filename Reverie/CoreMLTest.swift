//
//  CoreMLTest.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/25/25.
//

import SwiftUI
import CoreML
import StableDiffusion
import Vision

struct ContentView: View {
    
    // MARK: - State Variables
    
    @State private var prompt = "one goldendoodle cute dog sticker"
    @State private var generatedImage: UIImage?
    
    @State private var isLoading = false
    @State private var loadingStateText = "Initializing..."
    
    @State private var pipeline: StableDiffusionPipeline?
    @State private var progress: StableDiffusionPipeline.Progress?

    // MARK: - UI Body
    
    var body: some View {
        VStack(spacing: 20) {
            imageArea
            
            TextField("Enter your prompt", text: $prompt, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3)
            
            Button("Generate Sticker") {
                Task { await generateImage() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || pipeline == nil)
        }
        .padding()
        .onAppear(perform: loadModel)
    }
    
    private var imageArea: some View {
        Group {
            if let image = generatedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .overlay(progressOverlay)
            }
        }
    }
    
    private var progressOverlay: some View {
        Group {
            if isLoading {
                if let progress = progress, progress.stepCount > 0 {
                    ProgressView(value: Double(progress.step), total: Double(progress.stepCount)) {
                        Text(loadingStateText)
                    } currentValueLabel: {
                        Text("\(Int(Double(progress.step) / Double(progress.stepCount) * 100))%")
                    }
                    .padding()
                } else {
                    ProgressView(loadingStateText)
                }
            } else {
                Text("Your generated sticker will appear here.")
            }
        }
    }
    
    // MARK: - Load Model
    
    func loadModel() {
        if pipeline != nil { return }
        
        isLoading = true
        loadingStateText = "Loading model..."
        
        Task(priority: .userInitiated) {
            do {
                guard let resourceURL = Bundle.main.url(forResource: "StableDiffusionResources", withExtension: nil) else {
                    throw NSError(domain: "ContentView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find model resources."])
                }
                
                let loadedPipeline = try await StableDiffusionPipeline(
                    resourcesAt: resourceURL,
                    controlNet: [],
                    reduceMemory: true
                )
                
                await MainActor.run {
                    self.pipeline = loadedPipeline
                    self.isLoading = false
                    self.loadingStateText = ""
                }
                
            } catch {
                print("Error loading Stable Diffusion pipeline: \(error)")
                await MainActor.run {
                    self.loadingStateText = "Error loading model."
                }
            }
        }
    }
    
    // MARK: - Generate Image + Apply Effects
    
    @MainActor
    private func generateImage() async {
        guard let pipeline = pipeline else { return }
        
        isLoading = true
        loadingStateText = "Generating..."
        generatedImage = nil
        progress = nil
        
        do {
            var configuration = StableDiffusionPipeline.Configuration(prompt: prompt)
            // 1. SET THE RESOLUTION
            configuration.stepCount = 20
            configuration.seed = UInt32.random(in: 0...UInt32.max)
            configuration.guidanceScale = 7.5
            
            let images = try pipeline.generateImages(
                configuration: configuration,
                progressHandler: { progress in
                    Task { @MainActor in self.progress = progress }
                    return !Task.isCancelled
                }
            )
            
            if let finalCG = images.compactMap({ $0 }).first {
                let finalUIImage = UIImage(cgImage: finalCG)
                
                // 2. APPLY THE CORRECT SEGMENTATION AND STICKER EFFECT
//                if let stickerImage = await createSticker(from: finalUIImage) {
//                    self.generatedImage = stickerImage
//                } else {
                    self.generatedImage = finalUIImage // Fallback to original if sticker fails
//                }
            }
            
        } catch {
            print("Error generating image: \(error.localizedDescription)")
        }
        
        isLoading = false
        loadingStateText = ""
        progress = nil
    }
    
    // MARK: - Vision Sticker Functions
    
//    private func createSticker(from image: UIImage) async -> UIImage? {
//        guard let cutoutImage = await removeBackground(from: image) else {
//            return nil
//        }
//        return addStickerEffect(to: cutoutImage)
//    }
    
    // 3. USE THE CORRECT VISION REQUEST
//    func removeBackground(from image: UIImage) async -> UIImage? {
//        guard let cgImage = image.cgImage else { return nil }
//
//        let request = VNGenerateForegroundInstanceMaskRequest()
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        do {
//            try handler.perform([request])
//            
//            guard let observation = request.results?.first else { return nil }
//
//            let maskBuffer = try observation.generateScaledMaskForImage(
//                forInstances: IndexSet(integer: 0),
//                from: handler
//            )
//
//            return applySegmentationMask(maskPixelBuffer: maskBuffer, to: image)
//        } catch {
//            print("Segmentation error: \(error)")
//            return nil
//        }
//    }

//    private func applySegmentationMask(maskPixelBuffer: CVPixelBuffer, to image: UIImage) -> UIImage? {
//        let maskCI = CIImage(cvPixelBuffer: maskPixelBuffer)
//        guard let imageCI = CIImage(image: image),
//              let filter = CIFilter(name: "CIBlendWithMask") else { return nil }
//        
//        filter.setValue(imageCI, forKey: kCIInputImageKey)
//        filter.setValue(maskCI, forKey: kCIInputMaskImageKey)
//        
//        if let outputImage = filter.outputImage {
//            let context = CIContext()
//            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//                return UIImage(cgImage: cgImage)
//            }
//        }
//        return nil
//    }
    
    // 4. ADD A REAL BORDER AND SHADOW EFFECT
//    private func addStickerEffect(to image: UIImage) -> UIImage? {
//        guard let cgImage = image.cgImage else { return nil }
//        
//        let renderer = UIGraphicsImageRenderer(size: image.size)
//        
//        return renderer.image { context in
//            let ctx = context.cgContext
//            
//            // Create a subtle shadow
//            ctx.saveGState()
//            ctx.setShadow(offset: CGSize(width: 5, height: 10), blur: 5.0, color: UIColor.black.withAlphaComponent(0.3).cgColor)
//            ctx.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
//            ctx.restoreGState()
//            
//            // Create the white border
//            // We do this by creating a slightly larger version of the image's alpha mask
//            guard let alphaMask = cgImage.alphaMask,
//                  let borderFilter = CIFilter(name: "CIMorphologyMaximum") else {
//                ctx.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
//                return
//            }
//            
//            let maskCI = CIImage(cgImage: alphaMask)
//            borderFilter.setValue(maskCI, forKey: kCIInputImageKey)
//            borderFilter.setValue(12, forKey: kCIInputRadiusKey) // Border width
//            
//            if let borderCI = borderFilter.outputImage {
//                let colorFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: CIColor.white])!
//                let borderWithColor = CIFilter(name: "CIBlendWithMask", parameters: [
//                    "inputImage": colorFilter.outputImage!,
//                    "inputBackgroundImage": CIImage(image: image)!,
//                    "inputMaskImage": borderCI
//                ])!
//                
//                if let finalCI = borderWithColor.outputImage, let finalCG = CIContext().createCGImage(finalCI, from: finalCI.extent) {
//                    ctx.draw(finalCG, in: CGRect(origin: .zero, size: image.size))
//                } else {
//                    ctx.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
//                }
//            } else {
//                ctx.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
//            }
//        }
//    }
}

// Helper to get an alpha mask from a CGImage
//extension CGImage {
//    var alphaMask: CGImage? {
//        guard let alphaData = CFDataCreateMutable(nil, 0) else { return nil }
//        guard let alphaOnlyContext = CGContext(
//            data: CFDataGetMutableBytePtr(alphaData),
//            width: self.width,
//            height: self.height,
//            bitsPerComponent: 8,
//            bytesPerRow: self.width,
//            space: CGColorSpaceCreateDeviceGray(),
//            bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue
//        ) else { return nil }
//        
//        alphaOnlyContext.draw(self, in: CGRect(origin: .zero, size: CGSize(width: self.width, height: self.height)))
//        return alphaOnlyContext.makeImage()
//    }
//}
