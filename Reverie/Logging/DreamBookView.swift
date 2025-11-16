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
                        .transition(.opacity)
                }

                coverView
                    .frame(width: bookWidth, height: bookHeight)
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
                }
            } catch {
                print("Error fetching updated dream: \(error.localizedDescription)")
            }
        }
    }

    var coverView: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .blur(radius: 8)
                .offset(x: 6, y: 6)

            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.55),
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.02)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.trailing, 60)

            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 40/255, green: 0, blue: 70/255),
                            Color(red: 70/255, green: 0, blue: 130/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.clear
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    ),
                    lineWidth: 2
                )
                .blur(radius: 2)
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

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController),
                  index > 0 else { return nil }
            return controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController),
                  index < controllers.count - 1 else { return nil }
            return controllers[index + 1]
        }
    }
}


#Preview {
    DreamBookView(
        dream: DreamModel(
            userID: "hi",
            id: "hi",
            title: "Dream 1",
            date: Date(),
            loggedContent: "hi",
            generatedContent: "hi",
            tags: [.animals, .forests],
            image: ["hi"],
            emotion: .sadness,
            finishedDream: "None"
        )
    )
}

