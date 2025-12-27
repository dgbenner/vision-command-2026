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
    private let dwellMovementTolerance: CGFloat = 80.0
    
    // Minimum distance to move before allowing another fire
    private let refireDistanceThreshold: CGFloat = 100.0
    
    // Frame rate throttling
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 1.0 / 30.0  // 30 FPS instead of 60
    
    // Missile spawning
    private var missileSpawnTimer: TimeInterval = 0
    private let missileSpawnInterval: TimeInterval = 6.0  // 1 missile every 6 seconds
    private var missiles: [Missile] = []
    
    // Missile types (color, speed)
    private let missileTypes: [(color: SKColor, speed: CGFloat)] = [
        (SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), 150),  // Yellow - fastest
        (SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0), 120),  // Orange
        (SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0), 90),   // Red-orange
        (SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), 75)    // Red - slowest
    ]
    
    override func didMove(to view: SKView) {
        // Enable mouse tracking
        view.window?.acceptsMouseMovedEvents = true
        
        // Set background color
        self.backgroundColor = SKColor.black
        
        // Add background image (behind everything)
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.size = self.size  // Scale to match scene size
        background.zPosition = -100  // Behind everything
        self.addChild(background)
        
        // Create reticle
        createReticle()
        
        // Add foreground image (in front of game elements)
        let foreground = SKSpriteNode(imageNamed: "foreground")
        foreground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        foreground.size = self.size  // Scale to match scene size
        foreground.zPosition = 100  // In front of everything
        self.addChild(foreground)
    }
    
    func createReticle() {
        // Outer frame container
        outerFrame = SKNode()
        outerFrame?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        outerFrame?.zPosition = 50
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
        innerCrosshair?.zPosition = 51
        
        self.addChild(innerCrosshair!)
    }
    
    func spawnMissile() {
        // Random missile type
        let missileType = missileTypes.randomElement()!
        
        // Random spawn position along top of screen
        let spawnX = CGFloat.random(in: 50...(self.size.width - 50))
        let spawnY = self.size.height
        
        // Random target position along bottom of screen
        let targetX = CGFloat.random(in: 50...(self.size.width - 50))
        let targetY: CGFloat = 0
        
        let missile = Missile(
            startPosition: CGPoint(x: spawnX, y: spawnY),
            targetPosition: CGPoint(x: targetX, y: targetY),
            color: missileType.color,
            speed: missileType.speed
        )
        
        self.addChild(missile)
        missiles.append(missile)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Throttle updates to 30 FPS
        if currentTime - lastUpdateTime < updateInterval {
            return
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Missile spawning timer
        missileSpawnTimer += deltaTime
        if missileSpawnTimer >= missileSpawnInterval {
            spawnMissile()
            missileSpawnTimer = 0
        }
        
        // Update missiles
        for missile in missiles {
            missile.update(deltaTime: deltaTime)
        }
        
        // Remove missiles that reached bottom
        missiles.removeAll { missile in
            if missile.position.y <= 0 {
                missile.removeFromParent()
                return true
            }
            return false
        }
        
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
                        dwellTimer += deltaTime
                        
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
        explosion.zPosition = 10
        
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

// MARK: - Missile Class

class Missile: SKNode {
    
    private var warhead: SKShapeNode!
    private var glow: SKShapeNode!
    private var trail: SKShapeNode!
    
    private var velocity: CGVector!
    private var missileColor: SKColor!
    private var missileSpeed: CGFloat!
    
    private var trailPoints: [CGPoint] = []
    private let maxTrailLength: Int = 30
    
    init(startPosition: CGPoint, targetPosition: CGPoint, color: SKColor, speed: CGFloat) {
        super.init()
        
        self.position = startPosition
        self.missileColor = color
        self.missileSpeed = speed
        
        // Calculate velocity toward target
        let dx = targetPosition.x - startPosition.x
        let dy = targetPosition.y - startPosition.y
        let distance = hypot(dx, dy)
        velocity = CGVector(dx: (dx / distance) * speed, dy: (dy / distance) * speed)
        
        // Create warhead (2x2 pixel dot)
        warhead = SKShapeNode(rectOf: CGSize(width: 2, height: 2))
        warhead.fillColor = color
        warhead.strokeColor = color
        warhead.zPosition = 2
        self.addChild(warhead)
        
        // Create glow (pulsing darker version)
        glow = SKShapeNode(circleOfRadius: 8)
        glow.fillColor = color.withAlphaComponent(0.3)
        glow.strokeColor = SKColor.clear
        glow.zPosition = 1
        self.addChild(glow)
        
        // Slow pulse animation (2-4 seconds)
        let pulseOut = SKAction.scale(to: 2.0, duration: 3.0)
        let pulseIn = SKAction.scale(to: 1.0, duration: 3.0)
        let pulseSequence = SKAction.sequence([pulseOut, pulseIn])
        let pulseForever = SKAction.repeatForever(pulseSequence)
        glow.run(pulseForever)
        
        // Create trail
        trail = SKShapeNode()
        trail.strokeColor = color
        trail.lineWidth = 1
        trail.zPosition = 0
        self.addChild(trail)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: TimeInterval) {
        // Move missile
        self.position.x += velocity.dx * CGFloat(deltaTime)
        self.position.y += velocity.dy * CGFloat(deltaTime)
        
        // Add current position to trail
        trailPoints.insert(self.position, at: 0)
        
        // Limit trail length
        if trailPoints.count > maxTrailLength {
            trailPoints.removeLast()
        }
        
        // Update trail rendering
        updateTrail()
    }
    
    func updateTrail() {
        let path = CGMutablePath()
        
        if trailPoints.count > 1 {
            // Start from first point (relative to missile position)
            let firstPoint = CGPoint(
                x: trailPoints[0].x - self.position.x,
                y: trailPoints[0].y - self.position.y
            )
            path.move(to: firstPoint)
            
            // Draw fading trail
            for i in 1..<trailPoints.count {
                let point = CGPoint(
                    x: trailPoints[i].x - self.position.x,
                    y: trailPoints[i].y - self.position.y
                )
                path.addLine(to: point)
            }
        }
        
        trail.path = path
        
        // Fade trail opacity based on length
        trail.alpha = 0.8
    }
}
