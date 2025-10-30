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

    let bookWidth: CGFloat = 350
    let bookHeight: CGFloat = 460

    var body: some View {
        ZStack {
            ZStack {
                if revealPages {
                    PageCurlBookView(imageNames: [
                        "moon.stars.fill",
                        "cloud.fill",
                        "sparkles"
                    ])
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
    }
}

struct PageCurlBookView: UIViewControllerRepresentable {
    let imageNames: [String]

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

            self.controllers = parent.imageNames.map { imageName in
                let vc = UIViewController()
                vc.view.backgroundColor = .white

                let imageView = UIImageView(image: UIImage(named: imageName))
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false

                vc.view.addSubview(imageView)
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
                    imageView.widthAnchor.constraint(lessThanOrEqualTo: vc.view.widthAnchor, multiplier: 0.9),
                    imageView.heightAnchor.constraint(lessThanOrEqualTo: vc.view.heightAnchor, multiplier: 0.9)
                ])
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
    DreamBookView()
}
