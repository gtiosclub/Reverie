//
//  DreamBookView.swift
//  Reverie
//
//  Created by Amber Verma on 10/30/25.
//

import SwiftUI
import UIKit

struct DreamBookView: View {
    @State private var coverFlipped = false
    @State private var revealPages = false
    
    @State var dream: DreamModel
    
    let bookWidth: CGFloat = 350
    let bookHeight: CGFloat = 460

    var body: some View {
        ZStack {
            ZStack {
                if revealPages {
                    PageCurlBookView(imageURLs: dream.image ?? [])
                    .frame(width: bookWidth, height: bookHeight)
                    .cornerRadius(12)
                    .shadow(radius: 12)
                    .transition(.opacity)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.9),
                                    Color.blue.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: bookWidth, height: bookHeight)
                        .shadow(color: .black.opacity(0.4), radius: 10, x: 5, y: 5)

                    Text("")
                        .font(.title.bold())
                        .foregroundColor(.purple.opacity(0.85))
                        .shadow(radius: 3)
                }
                .rotation3DEffect(
                    .degrees(coverFlipped ? -180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    perspective: 0.8
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        coverFlipped = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            revealPages = true
                        }
                    }
                }
                .opacity(coverFlipped && revealPages ? 0 : 1)
            }
        }
        .task {
            do {
                if let updatedDream = try await FirebaseDreamService.shared.fetchDream(dreamID: dream.id) {
                    self.dream = updatedDream
                    print("Successfully fetched updated dream with image URLs.")
                }
            } catch {
                print("Error fetching updated dream: \(error.localizedDescription)")
            }
        }
    }
}

struct PageCurlBookView: UIViewControllerRepresentable {
    let imageURLs: [String?]

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal
        )
        controller.dataSource = context.coordinator
        controller.isDoubleSided = false
        controller.overrideUserInterfaceStyle = .light

        if let first = context.coordinator.controllers.first {
            controller.setViewControllers([first], direction: .forward, animated: false)
        }

        controller.view.clipsToBounds = true
        controller.view.layer.cornerRadius = 12
        return controller
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource {
        var parent: PageCurlBookView
        var controllers: [UIViewController]

        init(_ parent: PageCurlBookView) {
            self.parent = parent
            
            self.controllers = parent.imageURLs.map { urlString in
                
                let pageView = ZStack {
                    Color.white
                    AsyncImage(url: URL(string: urlString ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Image(systemName: "photo.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray.opacity(0.5))
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(20)
                }
                
                let vc = UIHostingController(rootView: pageView)
                vc.view.backgroundColor = .white
                return vc
            }
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController),
                  index > 0 else { return nil }
            return controllers[index - 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController),
                  index < controllers.count - 1 else { return nil }
            return controllers[index + 1]
        }
    }
}

#Preview {
    DreamBookView(dream: DreamModel(userID: "hi", id: "hi", title: "Dream 1", date: Date(), loggedContent: "hi", generatedContent: "hi", tags: [DreamModel.Tags.animals, DreamModel.Tags.forests], image: ["hi"], emotion: DreamModel.Emotions.sadness, finishedDream: "None"))
}
