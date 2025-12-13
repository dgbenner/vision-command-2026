//
//  GameScene.swift
//  VisionCommand
//
//  Created by Dan Benner on 12/13/25.
//

import SpriteKit

class GameScene: SKScene {
    
    // Our test button
    private var button: SKShapeNode?
    
    // Colors for button states
    private let normalColor = SKColor.blue
    private let hoverColor = SKColor.cyan
    
    override func didMove(to view: SKView) {
        // Enable mouse tracking
        view.window?.acceptsMouseMovedEvents = true
        
        // Set background color
        self.backgroundColor = SKColor.black
        
        // Create a rectangular button in the center of the screen
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 100
        
        button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        button?.fillColor = normalColor
        button?.strokeColor = SKColor.white
        button?.lineWidth = 3
        button?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        if let button = button {
            self.addChild(button)
        }
        
        // Add label to button
        let label = SKLabelNode(text: "HOVER ME")
        label.fontName = "Arial-BoldMT"
        label.fontSize = 24
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        label.position = CGPoint.zero
        
        button?.addChild(label)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Check mouse position every frame
        if let view = self.view,
           let window = view.window {
            
            // Get mouse location in window coordinates
            let mouseLocationInWindow = window.mouseLocationOutsideOfEventStream
            
            // Convert to view coordinates
            let mouseLocationInView = view.convert(mouseLocationInWindow, from: nil)
            
            // Convert to scene coordinates
            let mousePosition = self.convertPoint(fromView: mouseLocationInView)
            
            // Check if mouse is over the button
            if let button = button, button.contains(mousePosition) {
                // Mouse is hovering - change to hover color
                button.fillColor = hoverColor
            } else {
                // Mouse is not hovering - change back to normal color
                button?.fillColor = normalColor
            }
        }
    }
}
