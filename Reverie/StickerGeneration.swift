//
//  StickerGeneration.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/1/25.
//

import SwiftUI
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

func stickerGeneration(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
    guard let cgImage = image.cgImage else {
        print("❌ DEBUG: Failed to get CGImage from input UIImage.")
        completion(nil)
        return
    }

    let request = VNGenerateForegroundInstanceMaskRequest()
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([request])
            
            guard let result = request.results?.first else {
                print("❌ DEBUG: Vision request did not find any subject.")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let maskPixelBuffer = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: false
            )

            let originalCIImage = CIImage(cgImage: cgImage)
            let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer)

            let explicitFrame = CGRect(x: 0, y: 0, width: 512, height: 512)

            let croppedOriginal = originalCIImage.cropped(to: explicitFrame)
            let croppedMask = maskCIImage.cropped(to: explicitFrame)

            guard let compositingFilter = CIFilter(name: "CISourceInCompositing") else {
                print("❌ DEBUG: Could not create the compositing filter.")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            compositingFilter.setValue(croppedOriginal, forKey: kCIInputImageKey)
            compositingFilter.setValue(croppedMask, forKey: kCIInputBackgroundImageKey)

            guard let outputCIImage = compositingFilter.outputImage else {
                print("❌ DEBUG: The compositing filter failed to produce an output.")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            if outputCIImage.extent.isInfinite {
                print("❌ DEBUG: The output CIImage has an infinite extent (size).")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            if outputCIImage.extent.isEmpty {
                print("❌ DEBUG: The output CIImage has an empty extent (zero size). This likely means the mask was empty.")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let context = CIContext(options: nil)
            guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                print("❌ DEBUG: Failed to create CGImage from final CIImage.")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let finalImage = UIImage(cgImage: outputCGImage)
            DispatchQueue.main.async {
                completion(finalImage)
            }
            
        } catch {
            print("❌ DEBUG: An error occurred in the Vision request: \(error.localizedDescription)")
            DispatchQueue.main.async { completion(nil) }
        }
    }
}
