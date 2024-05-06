//  Created by Kevin Watters on 12/27/23.

import SwiftUI
import MultipeerConnectivity

// visionOS will silently clamp to volume size if set above or below limits
// max for all dimensions is 1.98
// min for all dimensions is 0.24
let VOLUME_SIZE = simd_double3(1.6, 0.941, 1.6)

@main
struct GodotVisionExample: App {
    @StateObject var appState = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: VOLUME_SIZE.x, height: VOLUME_SIZE.y, depth: VOLUME_SIZE.z, in: .meters)
    }
}
    
