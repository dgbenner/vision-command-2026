//
//  GameScene.swift
//  VisionCommand
//
//  Created by Dan Benner on 12/13/25.
//

import SpriteKit

class GameScene: SKScene {
    
    // Reticle elements
    private var outerFrame: SKNode?
    private var innerCrosshair: SKShapeNode?
    
    // Current and target positions for smooth movement
    private var outerFramePosition = CGPoint.zero
    private var currentMousePosition = CGPoint.zero
    
    // Dwell timing
    private var dwellTimer: TimeInterval = 0
    private let dwellDuration: TimeInterval = 0.4  // 400ms
    private var dwellStartPosition = CGPoint.zero
    private var isDwelling = false
    
    // Last fired position - prevents re-firing at same spot
    private var lastFiredPosition: CGPoint?
    
    // Movement tolerance (pixels) - movement beyond this cancels dwell
    private let dwellMovementTolerance: CGFloat = 30.0
    
    // Minimum distance to move before allowing another fire
    private let refireDistanceThreshold: CGFloat = 80.0
    
    override func didMove(to view: SKView) {
        // Enable mouse tracking
        view.window?.acceptsMouseMovedEvents = true
        
        // Set background color
        self.backgroundColor = SKColor.black
        
        // Create reticle
        createReticle()
    }
    
    func createReticle() {
        // Outer frame container
        outerFrame = SKNode()
        outerFrame?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(outerFrame!)
        
        // Outer frame corners
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
            
            // Check if we're far enough from last fired position
            var canFire = true
            if let lastFired = lastFiredPosition {
                let distanceFromLastFire = hypot(
                    mousePosition.x - lastFired.x,
                    mousePosition.y - lastFired.y
                )
                canFire = distanceFromLastFire > refireDistanceThreshold
            }
            
            // Handle dwell timing only if we can fire
            if canFire {
                if !isDwelling {
                    // Start dwelling
                    isDwelling = true
                    dwellStartPosition = mousePosition
                    dwellTimer = 0
                } else {
                    // Check if movement exceeds tolerance
                    let distance = hypot(
                        mousePosition.x - dwellStartPosition.x,
                        mousePosition.y - dwellStartPosition.y
                    )
                    
                    if distance > dwellMovementTolerance {
                        // Moved too far - reset dwell
                        dwellStartPosition = mousePosition
                        dwellTimer = 0
                    } else {
                        // Still within tolerance - increment timer
                        dwellTimer += 1.0 / 60.0  // Assuming 60 FPS
                        
                        if dwellTimer >= dwellDuration {
                            // Dwell complete - FIRE!
                            fireAtPosition(dwellStartPosition)
                            
                            // Record this position as last fired
                            lastFiredPosition = dwellStartPosition
                            
                            // Reset dwell state
                            isDwelling = false
                            dwellTimer = 0
                        }
                    }
                }
            } else {
                // Too close to last fire - can't dwell yet
                isDwelling = false
                dwellTimer = 0
            }
        }
    }
    
    func fireAtPosition(_ position: CGPoint) {
        print("FIRE at position: \(position)")
        
        // Create explosion circle
        let explosion = SKShapeNode(circleOfRadius: 10)
        explosion.fillColor = SKColor.clear
        explosion.strokeColor = SKColor.cyan
        explosion.lineWidth = 3
        explosion.position = position
        explosion.alpha = 1.0
        
        self.addChild(explosion)
        
        // Animate: small → large → small → disappear
        let expandAction = SKAction.scale(to: 8.0, duration: 0.3)
        let shrinkAction = SKAction.scale(to: 0.5, duration: 0.3)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)
        let removeAction = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([
            expandAction,
            shrinkAction,
            fadeAction,
            removeAction
        ])
        
        explosion.run(sequence)
    }
}
