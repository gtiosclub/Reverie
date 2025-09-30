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

struct ImageGenerationView: View {
    
    @State private var prompt = "one goldendoodle cute dog sticker"
    @State private var generatedImage: UIImage?
    
    @State private var isLoading = false
    @State private var loadingStateText = "Initializing..."
    
    @State private var pipeline: StableDiffusionPipeline?
    @State private var progress: StableDiffusionPipeline.Progress?
    
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
            }
        }
    }
    
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
    
    @MainActor
    private func generateImage() async {
        guard let pipeline = pipeline else { return }
        
        isLoading = true
        loadingStateText = "Generating..."
        generatedImage = nil
        progress = nil
        
        do {
            var configuration = StableDiffusionPipeline.Configuration(prompt: prompt)
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
                self.generatedImage = finalUIImage // In future can make image into sticker here
            }
            
        } catch {
            print("Error generating image: \(error.localizedDescription)")
        }
        
        isLoading = false
        loadingStateText = ""
        progress = nil
    }
}

#Preview {
    ImageGenerationView()
}
