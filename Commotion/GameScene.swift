//
//  GameScene.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate {

    //@IBOutlet weak var scoreLabel: UILabel!
    
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
            self.physicsWorld.gravity = CGVector(dx: CGFloat(6*gravity.x), dy: CGFloat(6*gravity.y))
        }
    }
    
    // MARK: View Hierarchy Functions
    let spinBlock = SKSpriteNode()
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Set the background color using RGBA values
        backgroundColor = SKColor(red: 2/255.0, green: 255/255.0, blue: 254/255.0, alpha: 1.0)
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addAllTheGameWalls()
        
        self.addSpriteBottle()
        
        self.addScore()
        
        self.score = 0
    }
    
    // MARK: Create Sprites Functions
    func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }
    
    
    func addSpriteBottle(){
        let spriteA = SKSpriteNode(imageNamed: "sprite") // this is literally a sprite bottle... 😎
        
        spriteA.size = CGSize(width:size.width*0.1,height:size.height * 0.1)
        
        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        spriteA.position = CGPoint(x: size.width * randNumber, y: size.height * 0.75)
        
        spriteA.physicsBody = SKPhysicsBody(rectangleOf:spriteA.size)
        spriteA.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
        spriteA.physicsBody?.isDynamic = true
        spriteA.physicsBody?.contactTestBitMask = 0x00000001
        spriteA.physicsBody?.collisionBitMask = 0x00000001
        spriteA.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(spriteA)
    }
    
    func addBlockAtPoint(_ point:CGPoint){
        
        spinBlock.color = UIColor.red
        spinBlock.size = CGSize(width:size.width*0.15,height:size.height * 0.05)
        spinBlock.position = point
        
        spinBlock.physicsBody = SKPhysicsBody(rectangleOf:spinBlock.size)
        spinBlock.physicsBody?.contactTestBitMask = 0x00000001
        spinBlock.physicsBody?.collisionBitMask = 0x00000001
        spinBlock.physicsBody?.categoryBitMask = 0x00000001
        spinBlock.physicsBody?.isDynamic = true
        spinBlock.physicsBody?.pinned = true
        
        self.addChild(spinBlock)

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
        self.addSpriteBottle()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == spinBlock || contact.bodyB.node == spinBlock {
            self.score += 1
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
