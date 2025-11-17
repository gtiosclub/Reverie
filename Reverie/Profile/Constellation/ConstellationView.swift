//
//  ConstellationView.swift
//  Reverie
//
//  Created by Isha Jain on 10/9/25.
//

import SwiftUI
import SceneKit

// MARK: - Hex Color helper
//extension Color {
//    init?(hex: String) {
//        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        if s.hasPrefix("#") { s.removeFirst() }
//        guard s.count == 6, let v = Int(s, radix: 16) else { return nil }
//        let r = Double((v >> 16) & 0xFF) / 255.0
//        let g = Double((v >> 8) & 0xFF) / 255.0
//        let b = Double(v & 0xFF) / 255.0
//        self = Color(red: r, green: g, blue: b)
//    }
//}

// MARK: - SwiftUI Color → UIColor bridge for SceneKit, Emotion Colors
extension Color {
    var uiColor: UIColor { UIColor(self) }
}
extension DreamModel.Emotions {
    var swatchColor: Color {
        switch self {
        case .sadness:        return DreamModel.Color(hex: "#3089D3") ?? .blue
        case .happiness:      return DreamModel.Color(hex: "#E0C341") ?? .yellow
        case .fear:           return DreamModel.Color(hex: "#9B32EC") ?? .purple
        case .anger:          return DreamModel.Color(hex: "#CD3838") ?? .red
        case .embarrassment:  return DreamModel.Color(hex: "#77A437") ?? .green
        case .anxiety:        return DreamModel.Color(hex: "#B96531") ?? .orange
        case .neutral:        return DreamModel.Color(hex: "#D9D9D9") ?? .gray
        }
    }
}

// MARK: - Dream Network Builder (Matrix Logic) — added
struct DreamNetworkBuilder {
    /// Build similarity matrix between all dreams
    static func buildMatrix(from dreams: [DreamModel]) -> [[Double]] {
        let n = dreams.count
        var matrix = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        for i in 0..<n {
            for j in i+1..<n {
                let sim = DreamModel.calculateSimilarity(between: dreams[i], and: dreams[j])
                matrix[i][j] = sim
                matrix[j][i] = sim
            }
        }
        return matrix
    }

    /// Determine threshold dynamically to balance connection density
    static func determineDynamicThreshold(matrix: [[Double]], targetDensity: Double = 0.25) -> Double {
        var values: [Double] = []
        for i in 0..<matrix.count {
            for j in i+1..<matrix.count {
                values.append(matrix[i][j])
            }
        }
        guard !values.isEmpty else { return 0.0 }
        let sorted = values.sorted()
        let idx = Int(Double(sorted.count - 1) * (1.0 - targetDensity))
        return sorted[max(0, min(idx, sorted.count - 1))]
    }

    /// Create adjacency matrix using binary logic (1 = connected, 0 = not connected)
    static func adjacencyMatrix(from matrix: [[Double]], threshold: Double) -> [[Int]] {
        matrix.map { row in row.map { $0 > threshold ? 1 : 0 } }
    }

    /// Find clusters (connected components) using DFS
    static func findClusters(adj: [[Int]]) -> [[Int]] {
        var visited = Set<Int>()
        var clusters: [[Int]] = []

        func dfs(_ i: Int, _ cluster: inout [Int]) {
            visited.insert(i)
            cluster.append(i)
            for j in 0..<adj.count where adj[i][j] == 1 && !visited.contains(j) {
                dfs(j, &cluster)
            }
        }

        for i in 0..<adj.count where !visited.contains(i) {
            var cluster: [Int] = []
            dfs(i, &cluster)
            clusters.append(cluster)
        }
        return clusters
    }
}
let (testDreams, testSimMatrix) = generateRandomDreamsAndMatrix(count: 20)

// MARK: - SceneKit Graph
struct DreamSimilarityGraph: UIViewRepresentable {
    let dreams: [DreamModel]
    let similarityMatrix: [[Double]]
    let threshold: Double
    @Binding var selectedDream: DreamModel?

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = makeScene()
        view.backgroundColor = .clear
        view.allowsCameraControl = true
        
        if let camera = view.scene?.rootNode.childNodes.first(where: { $0.camera != nil })?.camera {
            camera.wantsHDR = true
            camera.bloomIntensity = 2.0
            camera.bloomThreshold = 0.5
        }
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject {
        var parent: DreamSimilarityGraph
        var lastSelectedNode: SCNNode?
        init(_ parent: DreamSimilarityGraph) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }
            let location = gesture.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: nil)
            guard let hit = hitResults.first,
                  let dreamName = hit.node.name,
                  let dream = parent.dreams.first(where: { $0.loggedContent == dreamName }),
                  let scene = scnView.scene
            else { return }

            parent.selectedDream = dream

            let node = hit.node
            let root = scene.rootNode
            guard let pov = scnView.pointOfView else { return }

            // Restart floating animation on previously selected node
            if let lastNode = lastSelectedNode, lastNode != node { restartFloating(lastNode) }

            // Stop floating animation on newly selected node
            node.removeAllActions()
            lastSelectedNode = node

            // Stops constellation rotation
            root.removeAllActions()
            scnView.allowsCameraControl = false

            // World positions
            let nodeWorldPos = node.presentation.worldPosition
            let cameraWorldPos = pov.presentation.worldPosition

            // vector cam -> node
            let toNode = SCNVector3(
                nodeWorldPos.x - cameraWorldPos.x,
                nodeWorldPos.y - cameraWorldPos.y,
                nodeWorldPos.z - cameraWorldPos.z
            )
            let toNodeLen = sqrt(toNode.x*toNode.x + toNode.y*toNode.y + toNode.z*toNode.z)
            guard toNodeLen > 0.001 else {
                pulse(node)
                scnView.allowsCameraControl = true
                restartRotation(root)
                return
            }
            let toNodeNorm = SCNVector3(toNode.x/toNodeLen, toNode.y/toNodeLen, toNode.z/toNodeLen)

            // camera forward (-Z in camera space)
            let cameraForward = pov.presentation.worldFront
            let camLen = sqrt(cameraForward.x*cameraForward.x + cameraForward.y*cameraForward.y + cameraForward.z*cameraForward.z)
            let camFwdNorm = SCNVector3(cameraForward.x/camLen, cameraForward.y/camLen, cameraForward.z/camLen)

            // angle between where camera looks and node direction
            let dot = max(-1, min(1, camFwdNorm.x*toNodeNorm.x + camFwdNorm.y*toNodeNorm.y + camFwdNorm.z*toNodeNorm.z))
            let baseAngle = acos(dot)
            let overshootFactor: Float = 3
            let angle: Float = baseAngle < .pi * 0.6 ? baseAngle * overshootFactor : baseAngle

            // if already centered, pulse
            guard angle > 0.02 else {
                pulse(node)
                scnView.allowsCameraControl = true
                restartRotation(root)
                return
            }

            let parentNode = pov.parent ?? root
            let originalLocalPos = pov.position

            // small forward zoom step
            let zoomInStep: Float = 0.4
            let zoomTargetWorldPos = SCNVector3(
                cameraWorldPos.x + toNodeNorm.x * zoomInStep,
                cameraWorldPos.y + toNodeNorm.y * zoomInStep,
                cameraWorldPos.z + toNodeNorm.z * zoomInStep
            )
            let targetLocalPos = parentNode.convertPosition(zoomTargetWorldPos, from: nil)

            let zoomIn = SCNAction.move(to: targetLocalPos, duration: 0.55)
            zoomIn.timingMode = .easeInEaseOut
            let hold = SCNAction.wait(duration: 0.15)
            let zoomOut = SCNAction.move(to: originalLocalPos, duration: 0.55)
            zoomOut.timingMode = .easeInEaseOut
            pov.runAction(.sequence([zoomIn, hold, zoomOut]))

            // rotate the constellation to center node
            let axis = SCNVector3(
                camFwdNorm.y*toNodeNorm.z - camFwdNorm.z*toNodeNorm.y,
                camFwdNorm.z*toNodeNorm.x - camFwdNorm.x*toNodeNorm.z,
                camFwdNorm.x*toNodeNorm.y - camFwdNorm.y*toNodeNorm.x
            )
            let axisLen = sqrt(axis.x*axis.x + axis.y*axis.y + axis.z*axis.z)
            guard axisLen > 0.001 else {
                pulse(node)
                scnView.allowsCameraControl = true
                restartRotation(root)
                return
            }
            let axisNorm = SCNVector3(axis.x/axisLen, axis.y/axisLen, axis.z/axisLen)
            let rotateAction = SCNAction.rotate(by: CGFloat(angle), around: axisNorm, duration: 0.7)
            rotateAction.timingMode = .easeInEaseOut

            root.runAction(rotateAction) {
                scnView.allowsCameraControl = true
                // keep rotation paused while node is selected
            }

            pulse(node)
        }

        private func restartRotation(_ root: SCNNode) {
            let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 120)
            root.runAction(.repeatForever(rotate))
        }

        private func restartFloating(_ node: SCNNode) {
            let up = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1)
            up.timingMode = .easeInEaseOut
            let down = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1)
            down.timingMode = .easeInEaseOut
            node.runAction(.repeatForever(.sequence([up, down])))
        }

        // Called when popup is dismissed
        func restartConstellationRotation(for scnView: SCNView) {
            guard let scene = scnView.scene else { return }
            if let last = lastSelectedNode {
                restartFloating(last)
                lastSelectedNode = nil
            }
            restartRotation(scene.rootNode)
        }

        private func pulse(_ node: SCNNode) {
            let up = SCNAction.scale(to: 1.5, duration: 0.3)
            let down = SCNAction.scale(to: 1.0, duration: 0.3)
            node.runAction(.sequence([up, down]))
        }
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // If selectedDream becomes nil (popup dismissed), restart rotation
        if selectedDream == nil {
            context.coordinator.restartConstellationRotation(for: uiView)
        }
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        var nodes: [SCNNode] = []

        // Dream nodes
        for (_, dream) in dreams.enumerated() {
            let sphere = SCNSphere(radius: 0.1)


            let ui = dream.emotion.swatchColor.uiColor

            let material = SCNMaterial()
            material.diffuse.contents = ui
            material.emission.contents = ui
//            material.emission.intensity = 0.25
            material.emission.intensity = 1.5

            material.lightingModel = .blinn
            material.isDoubleSided = false
            sphere.materials = [material]

            let node = SCNNode(geometry: sphere)

            node.name = dream.loggedContent
            node.position = SCNVector3(Float.random(in: -3...3),
                                       Float.random(in: -3...3),
                                       Float.random(in: -3...3))

            let up = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1)
            up.timingMode = .easeInEaseOut
            let down = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1)
            down.timingMode = .easeInEaseOut
            node.runAction(.repeatForever(.sequence([up, down])))

            scene.rootNode.addChildNode(node)
            nodes.append(node)
        }

        // Edges (use similarity + threshold; width/alpha scale with strength)
        for i in 0..<dreams.count {
            for j in i+1..<dreams.count {
                let s = similarityMatrix[i][j]
                guard s > threshold else { continue }
                let edge = lineBetween(nodes[i], nodes[j], strength: s)
                scene.rootNode.addChildNode(edge)
            }
        }

        // Camera + lights
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 6.5)
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(white: 0.3, alpha: 1)
        scene.rootNode.addChildNode(ambient)

        scene.fogStartDistance = 2
        scene.fogEndDistance = 10
        scene.fogColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1)

        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 120)
        scene.rootNode.runAction(.repeatForever(rotate))

        return scene
    }

    private func lineBetween(_ a: SCNNode, _ b: SCNNode, strength: Double) -> SCNNode {
        let start = a.position
        let end = b.position
        let v = SCNVector3(end.x - start.x, end.y - start.y, end.z - start.z)
        let d = CGFloat(sqrt(v.x*v.x + v.y*v.y + v.z*v.z))

        let cylinder = SCNCylinder(radius: CGFloat(0.01 + 0.015 * strength), height: d)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.5, green: 0.6, blue: 1.0, alpha: CGFloat(0.05 + 0.15 * strength))
        material.lightingModel = .constant
        material.emission.contents = UIColor.clear
        cylinder.materials = [material]

        let line = SCNNode(geometry: cylinder)
        line.position = SCNVector3((start.x + end.x)/2, (start.y + end.y)/2, (start.z + end.z)/2)

        let dir = SCNVector3Normalize(v)
        let up = SCNVector3(0, 1, 0)
        let cross = SCNVector3CrossProduct(up, dir)
        let dot = SCNVector3DotProduct(up, dir)
        let angle = acos(dot)
        if abs(angle) > 0.0001 {
            line.rotation = SCNVector4(cross.x, cross.y, cross.z, angle)
        }
        return line
    }

    func SCNVector3Normalize(_ v: SCNVector3) -> SCNVector3 {
        let len = sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
        return SCNVector3(v.x/len, v.y/len, v.z/len)
    }
    func SCNVector3CrossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        SCNVector3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x)
    }
    func SCNVector3DotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        a.x*b.x + a.y*b.y + a.z*b.z
    }
}

// MARK: - UI Stuff
struct ExtrasView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(6)
            .background(Color(red: 0.4, green: 0.55, blue: 0.98, opacity: 0.7))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(red: 0.6, green: 0.7, blue: 1.0, opacity: 0.5), lineWidth: 0.8)
            )
            .foregroundColor(.white)
    }
}

struct DreamPopupView: View {
    let dream: DreamModel

    private let popupGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.22, green: 0.15, blue: 0.65, opacity: 0.75), // lighter violet top
            Color(red: 0.13, green: 0.08, blue: 0.45, opacity: 0.75), // mid tone (base)
            Color(red: 0.07, green: 0.03, blue: 0.25, opacity: 0.75)  // deep indigo bottom
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    private let popupShadow = Color(red: 0.3, green: 0.4, blue: 1.0).opacity(0.4)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.loggedContent).font(.headline).fontWeight(.semibold)
                    Text(dream.generatedContent).font(.subheadline).foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Text(dream.date, style: .date).font(.caption).foregroundColor(.white.opacity(0.7))
            }

            HStack {
                ForEach(dream.tags, id: \.self) { tag in
                    ExtrasView(text: tag.rawValue)
                }
            }
            .padding(.top, 16)

            ExtrasView(text: "Emotion: " + dream.emotion.rawValue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(popupGradient)
                .shadow(color: popupShadow, radius: 12, x: 0, y: 0)
        )
        .foregroundColor(.white)
        .frame(maxWidth: 320)
    }
}

// MARK: - SwiftUI container
struct ConstellationView: View {
    let dreams: [DreamModel]
    let similarityMatrix: [[Double]]
    let threshold: Double
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDream: DreamModel? = nil

    var body: some View {
        // Auto threshold if requested
        let effectiveThreshold: Double = threshold.isNaN
            ? DreamNetworkBuilder.determineDynamicThreshold(matrix: similarityMatrix, targetDensity: 0.25)
            : threshold
        ZStack {
            BackgroundView().ignoresSafeArea()

                   DreamSimilarityGraph(
                       dreams: dreams,
                       similarityMatrix: similarityMatrix,
                       threshold: effectiveThreshold,
                       selectedDream: $selectedDream
                   )
                   .ignoresSafeArea()

//                   LinearGradient(
//                       gradient: Gradient(colors: [
//                           Color.black.opacity(0.9),
//                           Color.black.opacity(0.6),
//                           Color.black.opacity(0.3),
//                           Color.black.opacity(0)
//                       ]),
//                       startPoint: .top,
//                       endPoint: .bottom
//                   )
//                   .frame(height: 90)
//                   .ignoresSafeArea(edges: .top)
//                  // .blendMode(.overlay)

                   VStack(spacing: 0) {
                       HStack {
                           Button(action: { dismiss() }) {
                               ZStack {
                                   Circle()
                                       .fill(
                                           LinearGradient(
                                               colors: [
                                                   Color(red: 5/255, green: 7/255, blue: 20/255),
                                                   Color(red: 17/255, green: 18/255, blue: 32/255)
                                               ],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing
                                           )
                                       )
                                       .frame(width: 55, height: 55)
                                       .overlay(
                                           Circle()
                                               .strokeBorder(
                                                   AngularGradient(
                                                       gradient: Gradient(colors: [
                                                           Color.white.opacity(0.8),
                                                           Color.white.opacity(0.1),
                                                           Color.white.opacity(0.6),
                                                           Color.white.opacity(0.1),
                                                           Color.white.opacity(0.8)
                                                       ]),
                                                       center: .center
                                                   ),
                                                   lineWidth: 0.5
                                               )
                                               .blendMode(.screen)
                                       )
                                   Image(systemName: "chevron.left")
                                       .resizable()
                                       .scaledToFit()
                                       .frame(width: 20, height: 20)
                                       .foregroundColor(.white)
                                       .padding(.leading, -4)
                                       .bold(true)
                               }
                           }
                           .buttonStyle(.plain)
                           .padding(.leading, 8)

                           Spacer()

                           Text("Constellation")
                               .font(.system(size: 18, weight: .semibold))
                               .foregroundColor(.white)
                               .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                               .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)
                               .dreamGlow()

                           Spacer()

                           Rectangle()
                               .fill(Color.clear)
                               .frame(width: 55, height: 55)
                       }
                       .padding(.horizontal)
                       .padding(.top, 8)
                       .padding(.bottom, 4)
                       .background(
                           LinearGradient(
                               gradient: Gradient(stops: [
                                   .init(color: Color(hex: "#010023"), location: 0.0),
                                   .init(color: Color.clear, location: 1.0)
                               ]),
                               startPoint: .top,
                               endPoint: .bottom
                           )
                       )

                       Text("Move around to explore. Select a dream to see its connections.")
                           .font(.system(size: 14))
                           .foregroundColor(.white.opacity(0.85))
                           .multilineTextAlignment(.center)
                           .padding(.top, 8)
                           .padding(.bottom, 12)
                           .padding(.horizontal, 20)

                       Spacer() 
                   }

                   // MARK: - Popup overlay for selected dream
                   if let dream = selectedDream {
                       Color.black.opacity(0.001)
                           .ignoresSafeArea()
                           .onTapGesture { selectedDream = nil }

                       VStack {
                           Spacer()

                           NavigationLink(
                               destination: DreamEntryView(dream: dream, backToArchive: false)
                           ) {
                               SectionView(
                                   title: dream.title,
                                   date: dream.date.formatted(),
                                   tags: dream.tags,
                                   description: dream.loggedContent,
                                   line: false
                               )
                               .padding(.horizontal, 5)
                               .padding(.top, 3)
                               .darkGloss()
                               .padding(.bottom, 40)
                           }
                       }
                       .ignoresSafeArea(edges: .bottom)
                   }
               }
               .navigationBarHidden(true)
           }
       }

       // MARK: - Preview
       #Preview {
           ConstellationView(dreams: testDreams, similarityMatrix: testSimMatrix, threshold: 0.4)
               .background(BackgroundView())
       }
