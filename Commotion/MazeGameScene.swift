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
            self.physicsWorld.gravity = CGVector(dx: CGFloat(0.001*gravity.x), dy: CGFloat(0.001*gravity.y))
        }
    }
    
    // MARK: View Hierarchy Functions
    let finishLine = SKSpriteNode()
    let levelLabel = SKLabelNode(fontNamed: "Chalkduster")
    let player = SKSpriteNode(imageNamed: "larson") // this is our player
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        self.levelLabel.text = "Level 1"
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addSidesAndTop()
        self.addFinishAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.35))
        
        self.createObstacleBlock(xPos: size.width * 0.2, yPos: size.height * 0.25)
        
        self.spawnPlayer()
        
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
        
    }
    
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        for obj in [left,right,top]{
            obj.color = UIColor.red
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // MARK: =====Delegate Functions=====
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

