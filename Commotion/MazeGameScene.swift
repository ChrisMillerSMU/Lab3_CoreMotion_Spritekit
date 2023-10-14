//
//  MazeGameScene.swift
//  Commotion
//
//  Created by Reece Iriye on 10/12/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class MazeGameScene: SKScene, SKPhysicsContactDelegate {

    //@IBOutlet weak var scoreLabel: UILabel!
    
    let MAX_SPEED_X:CGFloat = 1
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(gravity.x), dy: CGFloat(gravity.y))
        }
    }
    
    // MARK: View Hierarchy Functions
    let finishLine = SKSpriteNode()
    
    let topWall = SKSpriteNode()
    let bottomWall = SKSpriteNode()
    let leftWall = SKSpriteNode()
    let rightWall = SKSpriteNode()
    
    let bottomInnerWall = SKSpriteNode()
    let middleInnerWall = SKSpriteNode()
    let topInnerWall = SKSpriteNode()
    
    let levelLabel = SKLabelNode(fontNamed: "Chalkduster")
    let player = SKSpriteNode(imageNamed: "larson") // this is our player
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Set the background color using RGBA values
        backgroundColor = SKColor(red: 2/255.0, green: 255/255.0, blue: 254/255.0, alpha: 1.0)
        
        self.levelLabel.text = "Level 1"
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addFinishAtPoint(CGPoint(x: size.width * 0.25, y: size.height * 0.85))
        
        self.spawnPlayer()
        self.addAllTheGameWalls()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { timer in
            self.playWinSequence()
        }
        
    }
    
    override func didEvaluateActions() {
        if (self.physicsWorld.speed > MAX_SPEED_X) {
            self.physicsWorld.speed = MAX_SPEED_X
        }
    }
    
    // MARK: Create Sprites Functions
    func createObstacleBlock(xPos:Double, yPos:Double) {
        // Create obstacle sprite node
        let obstacleBlock = SKSpriteNode(imageNamed: "block") // this is literally a block
        
        obstacleBlock.size = CGSize(
            width: size.width*0.1,
            height: size.height*0.1
        )
        
        obstacleBlock.position = CGPoint(
            x: xPos,
            y: yPos
        )
        
        // Set a y-constraint to ensure block stays on the y-level it's created on
        let yConstraint = SKConstraint.positionY(SKRange(constantValue: yPos))
        obstacleBlock.constraints = [yConstraint]
        
        obstacleBlock.physicsBody = SKPhysicsBody(
            rectangleOf:obstacleBlock.size
        )
        obstacleBlock.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
        obstacleBlock.physicsBody?.isDynamic = true
        obstacleBlock.physicsBody?.contactTestBitMask = 0x00000001
        obstacleBlock.physicsBody?.collisionBitMask = 0x00000001
        obstacleBlock.physicsBody?.categoryBitMask = 0x00000001
    }
    
    func addFinishAtPoint(_ point:CGPoint){
        
        finishLine.color = UIColor.red
        finishLine.size = CGSize(width:size.width*0.05,height:size.height * 0.11)
        finishLine.position = point
        
        finishLine.physicsBody = SKPhysicsBody(rectangleOf:finishLine.size)
        finishLine.physicsBody?.contactTestBitMask = 0x00000001
        finishLine.physicsBody?.collisionBitMask = 0x00000001
        finishLine.physicsBody?.categoryBitMask = 0x00000001
        finishLine.physicsBody?.isDynamic = true
        finishLine.physicsBody?.pinned = true
        
        self.addChild(finishLine)

    }
    
    func spawnPlayer() {
        player.size = CGSize(width:size.width*0.1,height:size.width*0.1)

        player.position = CGPoint(x: size.width * 0.30, y: size.height * 0.15)
        
        player.physicsBody = SKPhysicsBody(rectangleOf:player.size)
        player.physicsBody?.restitution = 0.01
        player.physicsBody?.linearDamping = 35
        player.physicsBody?.isDynamic = true
        player.physicsBody?.contactTestBitMask = 0x00000001
        player.physicsBody?.collisionBitMask = 0x00000001
        player.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(player)
    }
    
    // Code to remove the player node from the game
    func deletePlayer() {
        self.player.removeFromParent()
    }
    
    func playWinSequence() {
        deletePlayer()
        deleteWallsAndFinish()
        
        backgroundColor = .black
        
        let scaleUpAction = SKAction.scale(to: 4.0, duration: 0.05) // Scale up to 2x in 0.5 seconds
        
        
        let scaleDownAction = SKAction.scale(to: 2.0, duration: 0.5) // Scale back to original size in 0.1 seconds
        
        
        let backgroundImage = SKSpriteNode(imageNamed: "winnerScreen")
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundImage.xScale = 2.0 // Increase the width by a factor of 2
        backgroundImage.yScale = 2.0 // Increase the height by a factor of 2
        self.addChild(backgroundImage)
        
        backgroundImage.run(scaleUpAction) {
            backgroundImage.run(scaleDownAction)
        }
    }
    
    func addAllTheGameWalls() {
        // Dimensions for the maze walls
        let wallThickness = CGFloat(80)  // Wall thickness for most walls
        let horizontalWallThickness = CGFloat(60)  // The wall thickness for horizontal walls

        // Top wall
        topWall.size = CGSize(width: size.width, height: wallThickness)
        topWall.position = CGPoint(x: size.width / 2, y: size.height - wallThickness / 2)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.isDynamic = false
        self.addChild(topWall)

        // Bottom wall
        bottomWall.color = .black
        bottomWall.size = CGSize(width: size.width, height: wallThickness)
        bottomWall.position = CGPoint(x: size.width / 2, y: wallThickness / 2)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.isDynamic = false
        self.addChild(bottomWall)

        // Left wall
        leftWall.color = .black
        leftWall.size = CGSize(width: wallThickness, height: size.height)
        leftWall.position = CGPoint(x: wallThickness / 2, y: size.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.isDynamic = false
        self.addChild(leftWall)

        // Right wall
        rightWall.color = .black
        rightWall.size = CGSize(width: wallThickness, height: size.height)
        rightWall.position = CGPoint(x: size.width - wallThickness / 2, y: size.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.isDynamic = false
        self.addChild(rightWall)
        
        // Sizes for inner all passages
        let horizontalWallThicknessThin = CGFloat(20) // Thin wall

        // First (bottom) horizontal inner wall
        let bottomInnerWallLength = size.width * 0.4
        bottomInnerWall.color = .black
        bottomInnerWall.size = CGSize(width: bottomInnerWallLength, height: horizontalWallThickness)
        bottomInnerWall.position = CGPoint(x: bottomInnerWallLength / 2, y: size.height * 0.25)
        bottomInnerWall.physicsBody = SKPhysicsBody(rectangleOf: bottomInnerWall.size)
        bottomInnerWall.physicsBody?.isDynamic = false
        self.addChild(bottomInnerWall)
        
        // Second (middle) horizontal inner wall
        let middleInnerWallLength = size.width * 0.5
        middleInnerWall.color = .black
        middleInnerWall.size = CGSize(width: middleInnerWallLength, height: horizontalWallThicknessThin)
        middleInnerWall.position = CGPoint(x: size.width - middleInnerWallLength / 2, y: size.height * 0.5)
        middleInnerWall.physicsBody = SKPhysicsBody(rectangleOf: middleInnerWall.size)
        middleInnerWall.physicsBody?.isDynamic = false
        self.addChild(middleInnerWall)
        
        // Third (top) horizontal inner wall
        let topInnerWallLength = size.width * 0.6
        topInnerWall.color = .black
        topInnerWall.size = CGSize(width: topInnerWallLength, height: horizontalWallThickness)
        topInnerWall.position = CGPoint(x: topInnerWallLength / 2, y: size.height * 0.75)
        topInnerWall.physicsBody = SKPhysicsBody(rectangleOf: topInnerWall.size)
        topInnerWall.physicsBody?.isDynamic = false
        self.addChild(topInnerWall)
    }
    
    func deleteWallsAndFinish() {
        self.topWall.removeFromParent()
        self.bottomWall.removeFromParent()
        self.leftWall.removeFromParent()
        self.rightWall.removeFromParent()
        
        self.topInnerWall.removeFromParent()
        self.middleInnerWall.removeFromParent()
        self.bottomInnerWall.removeFromParent()
        
        self.finishLine.removeFromParent()
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.addSpriteBottle()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == finishLine || contact.bodyB.node == finishLine {
            playWinSequence()
        }
        
        if contact.bodyA.node == player || contact.bodyB.node == player {
            deletePlayer()
            spawnPlayer()
        }
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
}

