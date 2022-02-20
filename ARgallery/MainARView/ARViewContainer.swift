//
//  ARViewContainer.swift
//  ModelPicker
//
//  Created by Michal Šimík on 11.02.2022.
//

import UIKit
import ARKit
import SwiftUI
import FocusEntity
import RealityKit
import SDWebImageSwiftUI

struct ARViewContainer: UIViewRepresentable {
    @Binding var collectibleForPlacement: Collectible?
    @Binding var isPlacementEnabled: Bool

    func makeUIView(context: Context) -> ARView {

        let arView = CustomARView(frame: .zero)

        #if !targetEnvironment(simulator)
        arView.addCoaching()
        #endif

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {

        if let collectible = collectibleForPlacement {

            let manager = ImageManager(url: collectible.getCollectibleURL())

            manager.setOnSuccess { image, _, _ in
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

                do {
                    let data = image.pngData()
                    try data?.write(to: fileURL)
                    let texture = try TextureResource.load(contentsOf: fileURL)
                    var material = SimpleMaterial()
                    material.baseColor = MaterialColorParameter.texture(texture)
                    let modelEntity = ModelEntity(mesh: .generateBox(size: 0.3), materials: [material])

                    let anchorEntity = AnchorEntity(plane: .any)
                    anchorEntity.addChild(modelEntity.clone(recursive: true))

                    uiView.scene.addAnchor(anchorEntity)

                    DispatchQueue.main.async {
                        collectibleForPlacement = nil
                    }
                } catch {
                    print(error)
                }
            }

            manager.load()
        }

        if let customARView = uiView as? CustomARView {
            print("custom view enabled \(collectibleForPlacement != nil)")
            customARView.focusSquare.isEnabled = isPlacementEnabled
        }
    }
}

class CustomARView: ARView {
    let focusSquare = FESquare()

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)

        focusSquare.viewDelegate = self
        focusSquare.setAutoUpdate(to: true)

        setupARView()
    }

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

        self.session.run(config)
    }
}

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        #if !targetEnvironment(simulator)
        coachingOverlay.session = self.session
        #endif
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
}
