//
//  ViewController.swift
//  CMSC428Quiz
//
//  Created by Hansin Dwivedi on 4/28/22.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController{
    
    @IBOutlet weak var startButton:UIButton!
    @IBOutlet weak var connectButton:UIButton!
    @IBOutlet weak var multiBar:UISegmentedControl!
    
    var session:MCSession!
    var advitiser:MCNearbyServiceAdvertiser!
    var peerID:MCPeerID!
    var browserView:MCBrowserViewController!
    var gameStart = false
    
    var multi = 0
    var players = 1
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID.init(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        advitiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "Quiz")
        
        advitiser.delegate = self
        session.delegate = self
    }
    
    @IBAction func connect(){
        browserView = MCBrowserViewController(serviceType: "Quiz", session: session)

        guard let browserView = browserView else {
            print("Couldn't create mcBrowser!")
            return
        }
        browserView.delegate = self
        present(browserView, animated: true)
        print("connect")
    }
    
    @IBAction func start(){
        print("start pushed")
        if(multi == 0){
            performSegue(withIdentifier: "quiz", sender: nil)
        } else {
            if !session.connectedPeers.isEmpty {
                do {
                    if(session.connectedPeers.count > 4){
                        return
                    }
                    let data = "quiz"
                    try session.send(data.data(using: String.Encoding.ascii, allowLossyConversion: true)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
                    performSegue(withIdentifier: "quiz", sender: nil)
                } catch {
                    print("error")
                }
            }
        }
    }
    
    @IBAction func segment(){
        switch multiBar.selectedSegmentIndex {
            case 0:
                multi = 0
            advitiser.stopAdvertisingPeer()
            case 1:
                multi = 1
            advitiser.startAdvertisingPeer()
            default:
                print("default")
        }
        print(multi)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension ViewController: MCBrowserViewControllerDelegate {

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}

extension ViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let string = String(data: data, encoding: String.Encoding.ascii){
            print(string)
            if(string == "quiz"){
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "quiz", sender: nil)
                }
            }
        }
            
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension ViewController: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerId: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("got invite from " + peerId.displayName)
        let inviteAlert = UIAlertController(title: "Invite", message:"invite from " + peerId.displayName, preferredStyle: UIAlertController.Style.alert)

        inviteAlert.addAction(UIAlertAction(title: "Decline", style: .default, handler: { [self] (action: UIAlertAction!) in
        invitationHandler(false, session)
          }))

        inviteAlert.addAction(UIAlertAction(title: "Accept", style: .cancel, handler: { [self] (action: UIAlertAction!) in
        invitationHandler(true, session)
          }))

        present(inviteAlert, animated: true, completion: nil)
    }
}

