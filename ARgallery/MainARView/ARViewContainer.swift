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
    @Binding var takeSnapshot: Bool
    @Binding var imageToShare: UIImage?

    let maximalSize = 0.5

    func makeUIView(context: Context) -> ARView {

        print("make")
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
            if takeSnapshot && !customARView.isTakingImage && imageToShare == nil {
                customARView
                    .takeImage(true)
                    .snapshot(saveToHDR: false) { image in
                        imageToShare = image
                        customARView.clearImage()
                    }
            }

            customARView.focusSquare.isEnabled = isPlacementEnabled
            customARView.setupARView(isFrontCamera: isFrontCamera)
        }
    }

    @MainActor
    private func downloadImage(from url: URL, view: ARView) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

                try data.write(to: fileURL)

                var imageRatio = CGSize(width: maximalSize, height: maximalSize)
                if let image = UIImage(data: data) {
                    let limitSize = max(image.size.width / maximalSize, image.size.height / maximalSize)
                    imageRatio = CGSize(width: image.size.width / limitSize, height: image.size.height / limitSize)
                }

                let texture = try TextureResource.load(contentsOf: fileURL)
                var material = SimpleMaterial()
                material.color = .init(tint: .white, texture: MaterialParameters.Texture(texture))

                print(imageRatio)

                var meshResource = MeshResource.generatePlane(width: Float(imageRatio.width), height: Float(imageRatio.height))
                if isBox {
                    meshResource = .generateBox(width: Float(imageRatio.width), height: Float(imageRatio.height), depth: Float(imageRatio.height))
                }

                let modelEntity = ModelEntity(mesh: meshResource, materials: [material])

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
            } catch {
                print(error)
            }
            collectibleForPlacement = nil
        }
    }
}

class CustomARView: ARView {
    let focusSquare = FESquare()
    var wasFrontCamera: Bool = false

    var isTakingImage = false

    required init(frame frameRect: CGRect, isFrontCamera: Bool) {

        super.init(frame: frameRect)

        focusSquare.viewDelegate = self
        focusSquare.setAutoUpdate(to: true)

        setupARView(isFrontCamera: isFrontCamera)
    }

    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor @objc required dynamic init(frame frameRect: CGRect) {
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

    func clearImage() {
        isTakingImage = false
    }

    func stopCamera() {

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

extension CustomARView {
    func takeImage(_ bool: Bool) -> CustomARView {
        let view = self
        view.isTakingImage = bool
        return view
    }
}
