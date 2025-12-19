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
    
    // Reticle elements
    private var outerFrame: SKNode?
    private var innerCrosshair: SKShapeNode?
    
    // Current and target positions for smooth movement
    private var outerFramePosition = CGPoint.zero
    private var currentMousePosition = CGPoint.zero
    
    // Colors for button states
    private let normalColor = SKColor.blue
    private let hoverColor = SKColor.cyan
    private let activeColor = SKColor.green
    
    // Dwell timing
    private var dwellTimer: TimeInterval = 0
    private let dwellDuration: TimeInterval = 0.6  // 600ms
    private var isHovering = false
    
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
        let label = SKLabelNode(text: "DWELL TO FIRE")
        label.fontName = "Arial-BoldMT"
        label.fontSize = 24
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        label.position = CGPoint.zero
        
        button?.addChild(label)
        
        // Create reticle
        createReticle()
    }
    
    func createReticle() {
        // Outer frame container
        outerFrame = SKNode()
        outerFrame?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(outerFrame!)
        
        // Outer frame corners (like your screenshot)
        let cornerSize: CGFloat = 40
        let frameSize: CGFloat = 120
        let cornerThickness: CGFloat = 2
        
        // Top-left corner
        let topLeft = SKShapeNode()
        let topLeftPath = CGMutablePath()
        topLeftPath.move(to: CGPoint(x: -frameSize/2, y: frameSize/2))
        topLeftPath.addLine(to: CGPoint(x: -frameSize/2 + cornerSize, y: frameSize/2))
        topLeftPath.move(to: CGPoint(x: -frameSize/2, y: frameSize/2))
        topLeftPath.addLine(to: CGPoint(x: -frameSize/2, y: frameSize/2 - cornerSize))
        topLeft.path = topLeftPath
        topLeft.strokeColor = SKColor.white
        topLeft.lineWidth = cornerThickness
        outerFrame?.addChild(topLeft)
        
        // Top-right corner
        let topRight = SKShapeNode()
        let topRightPath = CGMutablePath()
        topRightPath.move(to: CGPoint(x: frameSize/2, y: frameSize/2))
        topRightPath.addLine(to: CGPoint(x: frameSize/2 - cornerSize, y: frameSize/2))
        topRightPath.move(to: CGPoint(x: frameSize/2, y: frameSize/2))
        topRightPath.addLine(to: CGPoint(x: frameSize/2, y: frameSize/2 - cornerSize))
        topRight.path = topRightPath
        topRight.strokeColor = SKColor.white
        topRight.lineWidth = cornerThickness
        outerFrame?.addChild(topRight)
        
        // Bottom-left corner
        let bottomLeft = SKShapeNode()
        let bottomLeftPath = CGMutablePath()
        bottomLeftPath.move(to: CGPoint(x: -frameSize/2, y: -frameSize/2))
        bottomLeftPath.addLine(to: CGPoint(x: -frameSize/2 + cornerSize, y: -frameSize/2))
        bottomLeftPath.move(to: CGPoint(x: -frameSize/2, y: -frameSize/2))
        bottomLeftPath.addLine(to: CGPoint(x: -frameSize/2, y: -frameSize/2 + cornerSize))
        bottomLeft.path = bottomLeftPath
        bottomLeft.strokeColor = SKColor.white
        bottomLeft.lineWidth = cornerThickness
        outerFrame?.addChild(bottomLeft)
        
        // Bottom-right corner
        let bottomRight = SKShapeNode()
        let bottomRightPath = CGMutablePath()
        bottomRightPath.move(to: CGPoint(x: frameSize/2, y: -frameSize/2))
        bottomRightPath.addLine(to: CGPoint(x: frameSize/2 - cornerSize, y: -frameSize/2))
        bottomRightPath.move(to: CGPoint(x: frameSize/2, y: -frameSize/2))
        bottomRightPath.addLine(to: CGPoint(x: frameSize/2, y: -frameSize/2 + cornerSize))
        bottomRight.path = bottomRightPath
        bottomRight.strokeColor = SKColor.white
        bottomRight.lineWidth = cornerThickness
        outerFrame?.addChild(bottomRight)
        
        // Inner crosshair (fast-moving)
        innerCrosshair = SKShapeNode()
        let crosshairPath = CGMutablePath()
        let crosshairSize: CGFloat = 20
        // Horizontal line
        crosshairPath.move(to: CGPoint(x: -crosshairSize, y: 0))
        crosshairPath.addLine(to: CGPoint(x: crosshairSize, y: 0))
        // Vertical line
        crosshairPath.move(to: CGPoint(x: 0, y: -crosshairSize))
        crosshairPath.addLine(to: CGPoint(x: 0, y: crosshairSize))
        innerCrosshair?.path = crosshairPath
        innerCrosshair?.strokeColor = SKColor.white
        innerCrosshair?.lineWidth = 2
        innerCrosshair?.position = CGPoint.zero
        
        self.addChild(innerCrosshair!)
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
            
            currentMousePosition = mousePosition
            
            // Update inner crosshair (fast, direct tracking)
            innerCrosshair?.position = mousePosition
            
            // Update outer frame (slow, smoothed tracking)
            let smoothingFactor: CGFloat = 0.1  // Lower = slower/smoother
            outerFramePosition.x += (mousePosition.x - outerFramePosition.x) * smoothingFactor
            outerFramePosition.y += (mousePosition.y - outerFramePosition.y) * smoothingFactor
            outerFrame?.position = outerFramePosition
            
            // Check if mouse is over the button
            if let button = button, button.contains(mousePosition) {
                // Mouse is hovering
                if !isHovering {
                    // Just started hovering
                    isHovering = true
                    dwellTimer = 0
                }
                
                // Increment dwell timer
                dwellTimer += 1.0 / 60.0  // Assuming 60 FPS
                
                // Update button color based on dwell progress
                if dwellTimer >= dwellDuration {
                    // Dwell complete - FIRE!
                    button.fillColor = activeColor
                    activateButton()
                } else {
                    // Still dwelling - show progress
                    button.fillColor = hoverColor
                }
                
            } else {
                // Mouse is not hovering - reset
                if isHovering {
                    isHovering = false
                    dwellTimer = 0
                    button?.fillColor = normalColor
                }
            }
        }
    }
    
    func activateButton() {
        print("BUTTON ACTIVATED!")
        
        // Reset after activation
        dwellTimer = 0
        
        // Flash effect
        if let button = button {
            button.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.run { button.fillColor = self.normalColor }
            ]))
        }
    }
}
