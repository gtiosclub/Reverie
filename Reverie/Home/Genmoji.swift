//
//  Genmoji.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/18/25.
//

import SwiftUI
import UIKit
import ImagePlayground

struct ContentView: View {
    @State private var uiImages: [UIImage] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if uiImages.isEmpty {
                    Text("Generating images...")
                        .foregroundColor(.gray)
                } else {
                    ForEach(uiImages, id: \.self) { img in
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .padding()
        }
        .task {
            await generateImages()
        }
    }
    
    func generateImages() async {
        do {
            let creator = try await ImageCreator()
            guard let style = creator.availableStyles.first else { return }
            
            // Start the async stream
            let imageStream = creator.images(
                for: [.text("A cat wearing mittens.")],
                style: style,
                limit: 1
            )
            
            for try await result in imageStream {
                // Convert CGImage to UIImage
                let uiImage = UIImage(cgImage: result.cgImage)
                
                // Append to state on main thread
                await MainActor.run {
                    uiImages.append(uiImage)
                }
            }
        } catch ImageCreator.Error.notSupported {
            print("Image creation not supported on this device.")
        } catch {
            print("Error generating images: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
