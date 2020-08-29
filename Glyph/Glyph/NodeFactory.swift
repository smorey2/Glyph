//
//  NodeHandler.swift
//  Glyph
//
//  Created by Sky Morey on 8/24/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI

class NodeFactory {

    // Callback
    public weak var parent: UIViewController?
    
    // Shared session
    let session: URLSession = URLSession.shared
    
    // MARK: - Factory
    
    func create(for imageAnchor: ARImageAnchor) -> SCNNode? {
        let node = SCNNode()
        node.opacity = 0.5
        
        // Create a plan that has the same real world height and width as our detected image
        let chrome:CGFloat = 0.03
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width + chrome,
                             height: imageAnchor.referenceImage.physicalSize.height + chrome)
        
        // Create a node out of the plane
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
        
        let url = URL(string: "http://192.168.1.3/Glyph/image.json")!
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                node.opacity = 0
                return
            }
            self.factory(json: json, plane: plane, planeNode: planeNode)
            node.opacity = 1
        }).resume()

        // return node
        return node
    }
        
    func factory(json: [String:Any], plane: SCNPlane, planeNode: SCNNode) {
        print(json)
        // Factory
        let type = "image"
        switch type {
        case "image": createHostingController(for: planeNode, view: ImageView(info: ImageInfo()))
        case "avplayer": createAVPlayer(for: plane, info: AVPlayerInfo())
        case "ui": createHostingController(for: planeNode, view: SampleView())
        case "web": createHostingController(for: planeNode, view: WebContentView())
        case "button": createHostingController(for: planeNode, view: ButtonView(info: ButtonInfo()))
        default:
            print("unknown \(type)")
        }
    }
    
    func createAVPlayer(for plane: SCNPlane, info: AVPlayerInfo) {
        let url = URL(string: info.url)!
        
        // find our video file
        let videoItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: videoItem)
        let videoNode = SKVideoNode(avPlayer: player)
          
        player.play()
        
        // add observer when our player.currentItem finishes player, then start playing from the beginning
        if (info.loop) {
            // TODO: LEAKY
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { (notification) in
                player.seek(to: CMTime.zero)
                player.play()
                print("Looping Video")
            }
        }
        
        // set the size (just a rough one will do)
        let videoScene = SKScene(size: CGSize(width: 480, height: 360))
        
        // center our video to the size of our video scene
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        
        // invert our video so it does not look upside down
        videoNode.yScale = -1.0
        
        // add the video to our scene
        videoScene.addChild(videoNode)

        // set the first materials content to be our video scene
        plane.firstMaterial?.diffuse.contents = videoScene
    }
    
    func createHostingController<Content>(for node: SCNNode, view: Content) where Content : View {
        // create a hosting controller with SwiftUI view
        let arVC = UIHostingController<Content>(rootView: view)
        
        // Do this on the main thread
        DispatchQueue.main.async {
            guard let parent = self.parent else { return }
            
            arVC.willMove(toParent: parent)
            // make the hosting VC a child to the main view controller
            parent.addChild(arVC)
            
            // set the pixel size of the Card View
            arVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
            
            // add the ar card view as a subview to the main view
            parent.view.addSubview(arVC.view)
            
            // render the view on the plane geometry as a material
            self.show(hostingVC: arVC, on: node)
        }
    }
    
    func show<Content>(hostingVC: UIHostingController<Content>, on node: SCNNode) {
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
}
