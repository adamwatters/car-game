//
//  AppState.swift
//  GodotVisionExample
//
//  Created by Adam Watters on 4/23/24.
//

import MultipeerConnectivity
import simd

class AppState: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    @Published var mcSession: MCSession
    var mcServiceAdvertiser: MCNearbyServiceAdvertiser
    var mcBrowser: MCBrowserViewController?
    @Published var joystickPosition: simd_float2?
    
    override init() {
        var session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        self.mcSession = session
        self.mcServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "godot")
        super.init()
        mcSession.delegate = self
        mcServiceAdvertiser.delegate = self
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
        let x = data.prefix(upTo: 4).withUnsafeBytes({ bytes in
            bytes.load(as: Float.self)
        })
        let y = data.advanced(by: 4).withUnsafeBytes({ bytes in
            bytes.load(as: Float.self)
        })
        
        
        // how can we get this to Godot more directly?
        DispatchQueue.main.async {
            self.joystickPosition = simd_float2(x, y)
        }
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
