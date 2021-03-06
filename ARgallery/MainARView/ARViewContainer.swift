//
//  ARViewContainer.swift
//  ModelPicker
//
//  Created by Michal Šimík on 11.02.2022.
//

import ARKit
import FocusEntity
import RealityKit
import SwiftUI
import UIKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isPlacementEnabled: Bool
    @Binding var collectibleForPlacement: Collectible?
    @Binding var isBox: Bool
    @Binding var isFrontCamera: Bool
    @Binding var removeObjects: Bool
    @Binding var takeSnapshot: Bool
    @Binding var imageToShare: UIImage?

    @State var entities: [AnchorEntity] = []

    let maximalSize = 0.3

    func makeUIView(context _: Context) -> ARView {
        let arView = CustomARView(frame: .zero, isFrontCamera: isFrontCamera)

        #if !targetEnvironment(simulator)
            arView.addCoaching()
        #endif

        return arView
    }

    func updateUIView(_ uiView: ARView, context _: Context) {
        if let url = collectibleForPlacement?.getCollectibleURL() {
            addImageToScene(from: url, view: uiView)
        }

        if let customARView = uiView as? CustomARView {
            if removeObjects {
                for entity in entities {
                    customARView.scene.removeAnchor(entity)
                }
                print("removed")
            }

            if takeSnapshot, imageToShare == nil {
                customARView
                    .takeImage(true)
                    .snapshot(saveToHDR: false) { image in
                        imageToShare = image
                    }
            }

            customARView.focusSquare.isEnabled = isPlacementEnabled
            customARView.setupARView(isFrontCamera: isFrontCamera)
        }
    }

    @MainActor
    private func addImageToScene(from url: URL, view: ARView) {
        Task {
            do {
                removeObjects = false

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

                var meshResource = MeshResource.generatePlane(width: Float(imageRatio.width), height: Float(imageRatio.height))
                if isBox {
                    meshResource = .generateBox(width: Float(imageRatio.width), height: Float(imageRatio.height), depth: Float(imageRatio.height))
                }

                let modelEntity = ModelEntity(mesh: meshResource, materials: [material])

                if isFrontCamera {
                    let anchorEntity = AnchorEntity(world: SIMD3(x: 0, y: 0, z: -2))
                    anchorEntity.addChild(modelEntity)
                    view.scene.addAnchor(anchorEntity)
                    entities.append(anchorEntity)
                    modelEntity.generateCollisionShapes(recursive: true)

                    view.installGestures([.translation], for: modelEntity)
                } else {
                    modelEntity.transform = Transform(pitch: -.pi / 2, yaw: 0, roll: 0)
                    let anchorEntity = AnchorEntity(plane: .any)
                    entities.append(anchorEntity)
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
    var wasFrontCamera: Bool?

    required init(frame frameRect: CGRect, isFrontCamera: Bool) {
        super.init(frame: frameRect)

        focusSquare.viewDelegate = self
        focusSquare.setAutoUpdate(to: true)

        setupARView(isFrontCamera: isFrontCamera)
    }

    @available(*, unavailable)
    @objc dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor @objc dynamic required init(frame _: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    func setupARView(isFrontCamera: Bool) {
        if isFrontCamera, isFrontCamera != wasFrontCamera {
            let configuration = ARFaceTrackingConfiguration()
            if #available(iOS 13.0, *) {
                configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
            }
            configuration.isLightEstimationEnabled = true
            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        } else if isFrontCamera != wasFrontCamera {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.environmentTexturing = .automatic
            configuration.frameSemantics.insert(.personSegmentationWithDepth)

            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
            }

            session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        }

        wasFrontCamera = isFrontCamera
    }

    func stopCamera() {}
}

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        #if !targetEnvironment(simulator)
            coachingOverlay.session = session
        #endif
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .tracking
        addSubview(coachingOverlay)
    }
}

extension CustomARView {
    func takeImage(_: Bool) -> CustomARView {
        let view = self
        return view
    }
}
