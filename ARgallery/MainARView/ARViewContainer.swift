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
    @Binding var isFrontCamera: Bool

    func makeUIView(context: Context) -> ARView {

        let arView = CustomARView(frame: .zero, isFrontCamera: isFrontCamera)

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
            customARView.setupARView(isFrontCamera: isFrontCamera)
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

                    if isBox {
                        modelEntity = ModelEntity(mesh: .generateBox(size: 0.3), materials: [material])
                    }

                    if isFrontCamera {
                        let anchorEntity = AnchorEntity(world: SIMD3(x: 0, y: 0, z: -2))
                        anchorEntity.addChild(modelEntity)
                        view.scene.addAnchor(anchorEntity)
                        modelEntity.generateCollisionShapes(recursive: true)
                        view.installGestures([.translation], for: modelEntity)
                    } else {
                        modelEntity.transform = Transform(pitch: -.pi/2, yaw: 0, roll: 0)
                        let anchorEntity = AnchorEntity(plane: .any)
                        anchorEntity.addChild(modelEntity.clone(recursive: true))
                        view.scene.addAnchor(anchorEntity)
                    }
                    collectibleForPlacement = nil

                } catch {
                    print(error)
                }
            }
        }
    }
}

class CustomARView: ARView {
    let focusSquare = FESquare()
    var wasFrontCamera: Bool = false

    required init(frame frameRect: CGRect, isFrontCamera: Bool) {

        super.init(frame: frameRect)

        focusSquare.viewDelegate = self
        focusSquare.setAutoUpdate(to: true)

        setupARView(isFrontCamera: isFrontCamera)
    }

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor @objc override required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    func setupARView(isFrontCamera: Bool) {
        if isFrontCamera {
            let configuration = ARFaceTrackingConfiguration()
            if #available(iOS 13.0, *) {
                configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
            }
            configuration.isLightEstimationEnabled = true
            self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.environmentTexturing = .automatic
            configuration.frameSemantics.insert(.personSegmentationWithDepth)

            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
            }

            if isFrontCamera == wasFrontCamera {
                self.session.run(configuration)
            } else {
                self.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
            }
        }

        wasFrontCamera = isFrontCamera
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
