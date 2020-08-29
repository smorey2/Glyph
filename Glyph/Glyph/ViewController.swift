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
    
    /// An object that detects new barcodes in the user's environment.
    let nodeFactory = NodeFactory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeDetector.delegate = self
        nodeFactory.parent = self
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
        return nodeFactory.create(for: imageAnchor)
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
