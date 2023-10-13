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
    
    let MAX_SPEED_X:CGFloat = 10
    let MAX_SPEED_Y = 10
    
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
    let levelLabel = SKLabelNode(fontNamed: "Chalkduster")
    let player = SKSpriteNode(imageNamed: "larson") // this is our player
    let winnerScreen = SKSpriteNode(imageNamed: "winnerScreen")
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Set the background color using RGBA values
        backgroundColor = SKColor(red: 2/255.0, green: 255/255.0, blue: 254/255.0, alpha: 1.0)
        
        self.levelLabel.text = "Level 1"
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addAllTheGameWalls()
                
        self.addScore()
        
        self.score = 0
        self.addSidesAndTop()
        self.addFinishAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.35))
        
        self.createObstacleBlock(xPos: size.width * 0.2, yPos: size.height * 0.25)
        
        self.spawnPlayer()
        
        self.playWinSequence()
        
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
        finishLine.size = CGSize(width:size.width*0.15,height:size.height * 0.05)
        finishLine.position = point
        
        finishLine.physicsBody = SKPhysicsBody(rectangleOf:finishLine.size)
        finishLine.physicsBody?.contactTestBitMask = 0x00000001
        finishLine.physicsBody?.collisionBitMask = 0x00000001
        finishLine.physicsBody?.categoryBitMask = 0x00000001
        finishLine.physicsBody?.isDynamic = true
        finishLine.physicsBody?.pinned = true
        
        self.addChild(finishLine)

    }
    
    func spawnPlayer(){
        player.size = CGSize(width:size.width*0.1,height:size.height * 0.1)

        player.position = CGPoint(x: size.width * 0.3, y: size.height * 0.75)
        
        player.physicsBody = SKPhysicsBody(rectangleOf:player.size)
        player.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
        player.physicsBody?.isDynamic = true
        player.physicsBody?.contactTestBitMask = 0x00000001
        player.physicsBody?.collisionBitMask = 0x00000001
        player.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(player)
    }
    
    func playWinSequence() {
        winnerScreen.size = CGSize(width: size.width, height: size.height)
        winnerScreen.position = CGPoint(x: size.width * 0.3, y: size.height * 0.3)
        winnerScreen.physicsBody = SKPhysicsBody(rectangleOf:winnerScreen.size)
        winnerScreen.physicsBody?.isDynamic = true
        winnerScreen.physicsBody?.pinned = true
        winnerScreen.physicsBody?.allowsRotation = false
    }
    
    func addAllTheGameWalls() {
        // Dimensions for the maze walls
        let wallThickness = CGFloat(80)  // Wall thickness for most walls
        let horizontalWallThickness = CGFloat(60)  // The wall thickness for horizontal walls

        // Top wall
        let topWall = SKSpriteNode(color: .black, size: CGSize(width: size.width, height: wallThickness))
        topWall.position = CGPoint(x: size.width / 2, y: size.height - wallThickness / 2)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.isDynamic = false
        self.addChild(topWall)

        // Bottom wall
        let bottomWall = SKSpriteNode(color: .black, size: CGSize(width: size.width, height: wallThickness))
        bottomWall.position = CGPoint(x: size.width / 2, y: wallThickness / 2)
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.isDynamic = false
        self.addChild(bottomWall)

        // Left wall
        let leftWall = SKSpriteNode(color: .black, size: CGSize(width: wallThickness, height: size.height))
        leftWall.position = CGPoint(x: wallThickness / 2, y: size.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.isDynamic = false
        self.addChild(leftWall)

        // Right wall
        let rightWall = SKSpriteNode(color: .black, size: CGSize(width: wallThickness, height: size.height))
        rightWall.position = CGPoint(x: size.width - wallThickness / 2, y: size.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.isDynamic = false
        self.addChild(rightWall)
        
        // Sizes for inner all passages
        let horizontalWallThicknessThin = CGFloat(20) // Thin wall

        // First (bottom) horizontal inner wall
        let bottomHorizontalInnerWallLength = size.width * 0.4
        let bottomHorizontalInnerWall = SKSpriteNode(color: .black, size: CGSize(width: bottomHorizontalInnerWallLength, height: horizontalWallThickness))
        bottomHorizontalInnerWall.position = CGPoint(x: bottomHorizontalInnerWallLength / 2, y: size.height * 0.25)
        bottomHorizontalInnerWall.physicsBody = SKPhysicsBody(rectangleOf: bottomHorizontalInnerWall.size)
        bottomHorizontalInnerWall.physicsBody?.isDynamic = false
        self.addChild(bottomHorizontalInnerWall)
        
        // Second (middle) horizontal inner wall
        let middleHorizontalInnerWallLength = size.width * 0.5
        let middleHorizontalInnerWall = SKSpriteNode(color: .black, size: CGSize(width: middleHorizontalInnerWallLength, height: horizontalWallThicknessThin))
        middleHorizontalInnerWall.position = CGPoint(x: size.width - middleHorizontalInnerWallLength / 2, y: size.height * 0.5)
        middleHorizontalInnerWall.physicsBody = SKPhysicsBody(rectangleOf: middleHorizontalInnerWall.size)
        middleHorizontalInnerWall.physicsBody?.isDynamic = false
        self.addChild(middleHorizontalInnerWall)
        
        // Third (top) horizontal inner wall
        let topHorizontalInnerWallLength = size.width * 0.6
        let topHorizontalInnerWall = SKSpriteNode(color: .black, size: CGSize(width: topHorizontalInnerWallLength, height: horizontalWallThickness))
        topHorizontalInnerWall.position = CGPoint(x: topHorizontalInnerWallLength / 2, y: size.height * 0.75)
        topHorizontalInnerWall.physicsBody = SKPhysicsBody(rectangleOf: topHorizontalInnerWall.size)
        topHorizontalInnerWall.physicsBody?.isDynamic = false
        self.addChild(topHorizontalInnerWall)
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.addSpriteBottle()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == finishLine || contact.bodyB.node == finishLine {
            playWinSequence()
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

