//
//  ConstellationView.swift
//  Reverie
//
//  Created by Isha Jain on 10/9/25.
//

import SwiftUI
import SceneKit

let (testDreams, testSimMatrix) = generateRandomDreamsAndMatrix(count: 20)

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
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: DreamSimilarityGraph
        init(_ parent: DreamSimilarityGraph) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let scnView = gesture.view as! SCNView
            let location = gesture.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: nil)
            if let hit = hitResults.first, let dreamName = hit.node.name {
                if let dream = parent.dreams.first(where: { $0.loggedContent == dreamName }) {
                    parent.selectedDream = dream
                }
            }
        }
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        var nodes: [SCNNode] = []

        for (_, dream) in dreams.enumerated() {
            let sphere = SCNSphere(radius: 0.1)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 1)
            material.emission.contents = UIColor(red: 0.3, green: 0.4, blue: 1.0, alpha: 1)
            material.emission.intensity = 0.4
            sphere.materials = [material]

            let node = SCNNode(geometry: sphere)
            node.name = dream.loggedContent
            node.position = SCNVector3(
                Float.random(in: -2...2),
                Float.random(in: -2...2),
                Float.random(in: -2...2)
            )
            let floatUp = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1)
            floatUp.timingMode = .easeInEaseOut
            let floatDown = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1)
            floatDown.timingMode = .easeInEaseOut
            let floatLoop = SCNAction.repeatForever(SCNAction.sequence([floatUp, floatDown]))
            node.runAction(floatLoop)
            scene.rootNode.addChildNode(node)
            nodes.append(node)
        }

        for i in 0..<dreams.count {
            for j in i+1..<dreams.count {
                let similarity = similarityMatrix[i][j]
                guard similarity > threshold else { continue }
                let edgeNode = lineBetween(nodes[i], nodes[j], strength: similarity)
                scene.rootNode.addChildNode(edgeNode)
            }
        }

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
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
        let rotateForever = SCNAction.repeatForever(rotate)
        scene.rootNode.runAction(rotateForever)

        return scene
    }

    private func lineBetween(_ node1: SCNNode, _ node2: SCNNode, strength: Double) -> SCNNode {
        let start = node1.position
        let end = node2.position
        let vector = SCNVector3(end.x - start.x, end.y - start.y, end.z - start.z)
        let distance = CGFloat(sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z))

        let cylinder = SCNCylinder(radius: CGFloat(0.01 + 0.015 * strength), height: distance)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.5, green: 0.6, blue: 1.0, alpha: CGFloat(0.1 + 0.3 * strength))
        material.lightingModel = .constant
        cylinder.materials = [material]

        let lineNode = SCNNode(geometry: cylinder)
        lineNode.position = SCNVector3(
            (start.x + end.x) / 2,
            (start.y + end.y) / 2,
            (start.z + end.z) / 2
        )

        let dir = SCNVector3Normalize(vector)
        let up = SCNVector3(0, 1, 0)
        let cross = SCNVector3CrossProduct(up, dir)
        let dot = SCNVector3DotProduct(up, dir)
        let angle = acos(dot)
        if abs(angle) > 0.0001 {
            lineNode.rotation = SCNVector4(cross.x, cross.y, cross.z, angle)
        }

        return lineNode
    }

    func SCNVector3Normalize(_ v: SCNVector3) -> SCNVector3 {
        let length = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
        return SCNVector3(v.x / length, v.y / length, v.z / length)
    }

    func SCNVector3CrossProduct(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        return SCNVector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
    }

    func SCNVector3DotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        return a.x * b.x + a.y * b.y + a.z * b.z
    }
}

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
            Color(red: 0.28, green: 0.35, blue: 0.95, opacity: 0.6),
            Color(red: 0.18, green: 0.22, blue: 0.65, opacity: 0.6),
            Color(red: 0.12, green: 0.15, blue: 0.5, opacity: 0.6)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    private let popupShadow = Color(red: 0.3, green: 0.4, blue: 1.0).opacity(0.5)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.loggedContent)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(dream.genereatedContent)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Text(dream.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
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

struct ConstellationView: View {
    let dreams: [DreamModel]
    let similarityMatrix: [[Double]]
    let threshold: Double
    @State private var selectedDream: DreamModel? = nil

    var body: some View {
        ZStack {
            DreamSimilarityGraph(
                dreams: dreams,
                similarityMatrix: similarityMatrix,
                threshold: threshold,
                selectedDream: $selectedDream
            )

            if let dream = selectedDream {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { selectedDream = nil }

                DreamPopupView(dream: dream)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: selectedDream?.id)
                    .scaleEffect(selectedDream == nil ? 0.95 : 1.0)
            }
        }
    }
}

import Foundation

func generateRandomDreamsAndMatrix(count: Int, strongConnections: Int = 3) -> ([DreamModel], [[Double]]) {
    var dreams: [DreamModel] = []

    for i in 0..<count {
        let randomTags = DreamModel.Tags.allCases.shuffled().prefix(Int.random(in: 1...4))
        let allEmotions = DreamModel.Emotions.allCases

        let dream = DreamModel(
            userId: "user\(i)",
            id: UUID().uuidString,
            date: Date(),
            loggedContent: "Dream \(i + 1)",
            generatedContent: "Generated content for dream \(i + 1)",
            tags: Array(randomTags),
            image: "placeholder",
            emotion: allEmotions.randomElement()!
        )
        dreams.append(dream)
    }

    var similarityMatrix = Array(repeating: Array(repeating: 0.0, count: count), count: count)

    for i in 0..<count {
        similarityMatrix[i][i] = 1.0
    }

    for i in 0..<count {
        let indices = Array(0..<count).filter { $0 != i }.shuffled()
        for j in indices.prefix(strongConnections) {
            let sim = Double.random(in: 0.5...1.0)
            similarityMatrix[i][j] = sim
            similarityMatrix[j][i] = sim
        }
    }

    for i in 0..<count {
        for j in i+1..<count {
            if similarityMatrix[i][j] == 0.0 {
                let sim = Double.random(in: 0...0.3)
                similarityMatrix[i][j] = sim
                similarityMatrix[j][i] = sim
            }
        }
    }

    return (dreams, similarityMatrix)
}

#Preview {
    ConstellationView(dreams: testDreams, similarityMatrix: testSimMatrix, threshold: 0.4)
        .background(BackgroundView())
}
