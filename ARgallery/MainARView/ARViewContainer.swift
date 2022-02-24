//
//  ARViewContainer.swift
//  ModelPicker
//
//  Created by Michal Šimík on 11.02.2022.
//

import UIKit
import SwiftUI
import FocusEntity
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isPlacementEnabled: Bool
    @Binding var collectibleForPlacement: Collectible?
    @Binding var isBox: Bool

    func makeUIView(context: Context) -> ARView {

        let arView = CustomARView(frame: .zero)

        #if !targetEnvironment(simulator)
        arView.addCoaching()
        #endif

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if let url = collectibleForPlacement?.getCollectibleURL() {
                downloadImage(from: url, view: uiView)
        }

        if let customARView = uiView as? CustomARView {
            customARView.focusSquare.isEnabled = isPlacementEnabled
        }
    }

    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    private func downloadImage(from url: URL, view: ARView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)

            DispatchQueue.main.async {
                do {
                    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

                    try data.write(to: fileURL)
                    let texture = try TextureResource.load(contentsOf: fileURL)
                    var material = SimpleMaterial()
                    material.baseColor = MaterialColorParameter.texture(texture)

                    var modelEntity = ModelEntity(mesh: .generatePlane(width: 0.3, height: 0.3), materials: [material])
                    modelEntity.transform = Transform(pitch: -.pi/2, yaw: 0, roll: 0)

                    if isBox {
                        modelEntity = ModelEntity(mesh: .generateBox(size: 0.3), materials: [material])
                    }

                    let anchorEntity = AnchorEntity(plane: .any)
                    anchorEntity.addChild(modelEntity.clone(recursive: true))

                    view.scene.addAnchor(anchorEntity)

                    collectibleForPlacement = nil

                } catch {
                    print(error)
                }
            }
        }
    }

    func showImagePreview() {
        
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
        config.frameSemantics.insert(.personSegmentationWithDepth)

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
        coachingOverlay.goal = .tracking
        self.addSubview(coachingOverlay)
    }
}
