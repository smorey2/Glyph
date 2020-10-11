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
import CoreBluetooth

// https://medium.com/better-programming/how-to-use-a-swiftui-view-in-anarkit-scenekit-app-d6504d7b92d2
// https://github.com/CocoaHeadsDetroit/ARKit2DTracking/blob/master/CocoaHeadDemo/ViewController.swift
// https://www.freecodecamp.org/news/ultimate-how-to-bluetooth-swift-with-hardware-in-20-minutes/
class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    /// An object that detects new barcodes in the user's environment.
    let barcodeDetector = BarcodeDetector()
    
    /// An object that detects new barcodes in the user's environment.
    let glyphFactory = GlyphFactory()
    
    // ChromeView
    var chromeStateModel = ChromeStateModel()
    var chromeViewController:UIHostingController<ChromeView>!
    
    // Bluetooth
    var blueManager = BlueManager()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        chromeViewController = UIHostingController<ChromeView>(rootView: ChromeView(model: chromeStateModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeDetector.delegate = self
        glyphFactory.parent = self
        sceneView.delegate = self
        sceneView.session.delegate = barcodeDetector
        sceneView.showsStatistics = true
        chromeViewController.willMove(toParent: self)
        chromeViewController.view.backgroundColor = .clear
        updateChrome(size: view.frame.size)
        //        blueManager.startup()
        self.addChild(chromeViewController)
        self.view.addSubview(chromeViewController.view)
    }
    
    func updateChrome(size: CGSize) {
        chromeViewController.view.frame = CGRect(
            x: 0,
            y: 0,
            width: size.width,
            height: size.height * 0.2)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateChrome(size: size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Prevent the screen from being dimmed after a while.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Restart the session and remove any image anchors that may have been detected previously.
        runImageTrackingSession(with: [], runOptions: [.removeExistingAnchors, .resetTracking])
        
        // message
        chromeStateModel.title = "Look for a QR code."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    /// Called when the app starts a new image tracking session.
    /// - Tag: ImageTrackingSession
    func runImageTrackingSession(with trackingImages: Set<ARReferenceImage>,
                                 runOptions: ARSession.RunOptions = [.removeExistingAnchors]) {
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = trackingImages.count
        sceneView.session.run(configuration, options: runOptions)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        return glyphFactory.create(for: imageAnchor, detector: barcodeDetector)
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
    /// Called when the app recognized a new barcode in the user's environment.
    /// - Tag: UpdateReferenceImages
    func barcodeUpdated(with trackingImages: Set<ARReferenceImage>) {
        // Start the session with the newly recognized image.
        DispatchQueue.main.async {
            self.runImageTrackingSession(with: trackingImages)
        }
    }
}
