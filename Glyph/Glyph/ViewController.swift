//
//  ViewController.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI

// https://medium.com/better-programming/how-to-use-a-swiftui-view-in-anarkit-scenekit-app-d6504d7b92d2
// https://github.com/CocoaHeadsDetroit/ARKit2DTracking/blob/master/CocoaHeadDemo/ViewController.swift
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    /// An object that detects new barcodes in the user's environment.
    let barcodeDetector = BarcodeDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeDetector.delegate = self
        sceneView.delegate = self
        sceneView.session.delegate = barcodeDetector
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Prevent the screen from being dimmed after a while.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Restart the session and remove any image anchors that may have been detected previously.
        runImageTrackingSession(with: [], runOptions: [.removeExistingAnchors, .resetTracking])
        
//        showMessage("Look for a rectangular image.", autoHide: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    /// - Tag: ImageTrackingSession
    func runImageTrackingSession(with trackingImages: Set<ARReferenceImage>,
                                 runOptions: ARSession.RunOptions = [.removeExistingAnchors]) {
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = trackingImages.count
        sceneView.session.run(configuration, options: runOptions)
    }
    
    // MARK: - Message
    
    // The timer for message presentation.
    var messageHideTimer: Timer?
    
    func showMessage(_ message: String, autoHide: Bool = true) {
        DispatchQueue.main.async {
            self.messageLabel.text = message
            self.setMessageHidden(false)
            
            self.messageHideTimer?.invalidate()
            if autoHide {
                self.messageHideTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                    self?.setMessageHidden(true)
                }
            }
        }
    }
    
    func setMessageHidden(_ hide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: {
                self.messagePanel.alpha = hide ? 0 : 1
            })
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        
        let node = SCNNode()
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                             height: imageAnchor.referenceImage.physicalSize.height)
        
        let planeNode = SCNNode(geometry: plane)
        // When a plane geometry is created, by default it is oriented vertically
        // so we have to rotate it on X-axis by -90 degrees to make it flat to the image detected
        planeNode.eulerAngles.x = -.pi / 2
        
        createHostingController(for: planeNode)
        
        node.addChildNode(planeNode)
        return node
    }
    
    func createHostingController(for node: SCNNode) {
        // create a hosting controller with SwiftUI view
        let arVC = UIHostingController(rootView: SampleView())
        
        // Do this on the main thread
        DispatchQueue.main.async {
            arVC.willMove(toParent: self)
            // make the hosting VC a child to the main view controller
            self.addChild(arVC)
            
            // set the pixel size of the Card View
            arVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
            
            // add the ar card view as a subview to the main view
            self.view.addSubview(arVC.view)
            
            // render the view on the plane geometry as a material
            self.show(hostingVC: arVC, on: node)
        }
    }
    
    func show(hostingVC: UIHostingController<SampleView>, on node: SCNNode) {
        // create a new material
        let material = SCNMaterial()
        
        // this allows the card to render transparent parts the right way
        hostingVC.view.isOpaque = false
        
        // set the diffuse of the material to the view of the Hosting View Controller
        material.diffuse.contents = hostingVC.view
        
        // Set the material to the geometry of the node (plane geometry)
        node.geometry?.materials = [material]
        
        hostingVC.view.backgroundColor = UIColor.clear
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

extension ViewController: BarcodeDetectorDelegate {
    /// Called when the app recognized a new barcode in the user's envirnment.
    /// - Tag: UpdateReferenceImages
    func barcodeUpdated(with trackingImages: Set<ARReferenceImage>) {
        DispatchQueue.main.async {
            // Start the session with the newly recognized image.
            self.runImageTrackingSession(with: trackingImages)
        }
    }
}
