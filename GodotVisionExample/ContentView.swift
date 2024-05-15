//  Created by Kevin Watters on 12/27/23.

import SwiftUI
import RealityKit
import GodotVision


struct ContentView: View {
    var scale: Float = 1
    var offset: simd_float3 = .zero

    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var godotVision = GodotVisionCoordinator()
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        GeometryReader3D { (geometry: GeometryProxy3D) in
            RealityView { content, attachments in
                
                let pathToGodotProject = "Godot_Project" // The path to the folder containing the "project.godot" you wish Godot to load.
                
                // Initialize Godot
                let rkEntityGodotRoot = godotVision.setupRealityKitScene(content,
                                                                         volumeSize: VOLUME_SIZE,
                                                                         projectFileDir: pathToGodotProject)
                godotVision.extraScale = scale
                godotVision.extraOffset = offset

                print("Godot scene root: \(rkEntityGodotRoot)")
                if let uiPanel = attachments.entity(for: "ui_panel") {
                    content.add(uiPanel)
                    uiPanel.position = .init(0, Float(VOLUME_SIZE.y / -2 + 0.08), Float(VOLUME_SIZE.z / 2 - 0.01))
                }
            } update: { content, attachments in
                // update called when SwiftUI @State in this ContentView changes. See docs for RealityView.
                // user can change the volume size from the default by selecting a different zoom level.
                // we watch for changes via the GeometryReader and scale the godot root accordingly
                let frame = content.convert(geometry.frame(in: .local), from: .local, to: .scene)
                let volumeSize = simd_double3(frame.max - frame.min)
                godotVision.changeScaleIfVolumeSizeChanged(volumeSize)
            } attachments: {
                Attachment(id: "ui_panel") {
                    HStack {
                        Button { godotVision.reloadScene() } label: {
                            // this should open a window with instructions for downloading the controller app
                            Text("Reload Scene")
                        }
                        Button { appState.mcServiceAdvertiser.startAdvertisingPeer() } label: {
                            Text("Connect to iPhone")
                        }
                        Button {
                            godotVision.sceneTree?.paused.toggle()
                            
                        } label: {
                            Text("Pause")
                        }
                    }.padding(36).frame(width: 700).glassBackgroundEffect()
                }
            }
        }
        .modifier(GodotVisionRealityViewModifier(coordinator: godotVision))
        .onChange(of: scenePhase) {
            let paused: Bool
            switch scenePhase {
            case .active:
                paused = false
            default:
                paused = true
            }
            
            if let sceneTree = godotVision.sceneTree {
                if paused != sceneTree.paused {
                    print(paused ? "PAUSE" : "UNPAUSE")
                    sceneTree.paused = paused
                }
            }
        }
    }
        
    @ViewBuilder
    func sceneButton(label: String, resourcePath: String) -> some View {
        Button {
            godotVision.changeSceneToFile(atResourcePath: resourcePath)
        } label: {
            Text(label)
        }
    }
}
