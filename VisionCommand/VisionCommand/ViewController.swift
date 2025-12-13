//
//  ViewController.swift
//  VisionCommand
//
//  Created by Dan Benner on 12/13/25.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {
    
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            // Create the scene programmatically instead of loading from .sks
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            // Enable mouse tracking for hover detection
            let trackingArea = NSTrackingArea(
                rect: view.bounds,
                options: [.activeAlways, .mouseMoved, .inVisibleRect],
                owner: self,
                userInfo: nil
            )
            view.addTrackingArea(trackingArea)
        }
    }
}
