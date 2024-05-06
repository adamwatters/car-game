//
//  AppState.swift
//  GodotVisionExample
//
//  Created by Adam Watters on 4/23/24.
//

import MultipeerConnectivity
import simd
import GodotVision

class AppState: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    @Published var mcSession: MCSession
    var mcServiceAdvertiser: MCNearbyServiceAdvertiser
    var mcBrowser: MCBrowserViewController?
    @Published var controllerRotation: Float?
    var godotVision: GodotVisionCoordinator?
    
    override init() {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        self.mcSession = session
        self.mcServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "godot")
        super.init()
        mcSession.delegate = self
        mcServiceAdvertiser.delegate = self
    }
    
    func attachGodotVision(_ coordinator: GodotVisionCoordinator) {
        godotVision = coordinator
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mcSession)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session called")
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        default:
            print("unknown MCSessionState case")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(data.count)
        let rotation = data.prefix(upTo: 4).withUnsafeBytes({ bytes in
            bytes.load(as: Float.self)
        })
        let gasPressed = data.advanced(by: 4).prefix(upTo: 1).withUnsafeBytes({ bytes in
            bytes.load(as: Bool.self)
        })
        let brakePressed = data.advanced(by: 5).prefix(upTo: 1).withUnsafeBytes({ bytes in
            bytes.load(as: Bool.self)
        })
        receivedMultipeerInput(rotation, gasPressed, brakePressed)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("resource start")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("resource finished")
    }
}

import class SwiftGodot.Input

func receivedMultipeerInput(_ iphoneControllerRotation: Float?, _ buttonOnePressed: Bool, _ buttonTwoPressed: Bool) {
    if let iphoneControllerRotation  {
        let rotation = Double(iphoneControllerRotation)
        if rotation > 0 {
            SwiftGodot.Input.actionRelease(action: "ui_left")
            SwiftGodot.Input.actionPress(action:"ui_right", strength: rotation)
        } else {
            SwiftGodot.Input.actionRelease(action: "ui_right")
            SwiftGodot.Input.actionPress(action:"ui_left", strength: Swift.abs(rotation))
        }
        if buttonOnePressed {
            SwiftGodot.Input.actionPress(action: "ui_accept")
        } else {
            SwiftGodot.Input.actionRelease(action: "ui_accept")
        }
        if buttonTwoPressed {
            SwiftGodot.Input.actionPress(action: "ui_select")
        } else {
            SwiftGodot.Input.actionRelease(action: "ui_select")
        }
    }
}
