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

extension SKAction {

    // amplitude  - the amount the height will vary by, set this to 200 in your case.
    // timePeriod - the time it takes for one complete cycle
    // midPoint   - the point around which the oscillation occurs.

    static func oscillation(amplitude a: CGFloat, timePeriod t: Double, midPoint: CGPoint) -> SKAction {
        let action = SKAction.customAction(withDuration: t) { node, currentTime in
            let displacement = a * sin(2 * .pi * currentTime / CGFloat(t))
            node.position.x = midPoint.x + displacement
        }

        return action
    }
}

class MazeGameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical,
                to: OperationQueue.main,
                withHandler: self.handleMotion
            )
        }
    }
    
    //Using the roll and pitch attitude measurements from CMMotion Device to create gravity
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let attitude = motionData?.attitude {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(5*attitude.roll), dy: CGFloat(-5*attitude.pitch))
            print("roll:", attitude.roll)
            print("Pitch:", attitude.pitch)
        }
    }
    
    // MARK: View Hierarchy Functions
    //Declaring wall variables
    let topWall = SKSpriteNode()
    let bottomWall = SKSpriteNode()
    let leftWall = SKSpriteNode()
    let rightWall = SKSpriteNode()
    
    let bottomInnerWall = SKSpriteNode()
    let middleInnerWall = SKSpriteNode()
    let topInnerWall = SKSpriteNode()
    
    //Declaring other variables
    let player = SKSpriteNode(imageNamed: "larson")
    let gameplayAudio = SKAudioNode(fileNamed: "GameAudio")
    let finishLine = SKSpriteNode()
    // Create obstacle sprite node
    let obstacleBlock = SKSpriteNode() // this is literally a block

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        // Set the background color using RGBA values
        self.backgroundColor = SKColor(red: 2/255.0, green: 255/255.0, blue: 254/255.0, alpha: 1.0)

        // start motion for gravity
        self.startMotionUpdates()
        
        // Add the walls, finish, and player
        self.addFinishAtPoint(CGPoint(x: size.width * 0.25, y: size.height * 0.85))
        self.spawnPlayer()
        self.addAllTheGameWalls()
        
        //starts gameplay audio
        self.gameplayAudio.autoplayLooped = true
        self.addChild(gameplayAudio)
        self.gameplayAudio.run(SKAction.play())
        
        createObstacleBlock(xPos: size.width/2, yPos: (size.height*0.85)/2)
        self.addChild(obstacleBlock)
        let oscillate = SKAction.oscillation(amplitude: 95,
                                                timePeriod: 15,
                                                  midPoint: obstacleBlock.position)
        obstacleBlock.run(SKAction.repeatForever(oscillate))
        
    }
    
    override func willMove(from view: SKView) {
        self.gameplayAudio.run(SKAction.stop())
    }
  
    // MARK: Create Sprites Functions
    //function to create finish line at given point
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
    
    func createObstacleBlock(xPos:Double, yPos:Double) {
            obstacleBlock.size = CGSize(
                width: size.width*0.1,
                height: size.width*0.1
            )

            obstacleBlock.position = CGPoint(
                x: xPos,
                y: yPos
            )
        
        obstacleBlock.color = .black

            // Set a y-constraint to ensure block stays on the y-level it's created on
            let yConstraint = SKConstraint.positionY(SKRange(constantValue: yPos))
            obstacleBlock.constraints = [yConstraint]

            obstacleBlock.physicsBody = SKPhysicsBody(
                rectangleOf:obstacleBlock.size
            )
            obstacleBlock.physicsBody?.isDynamic = true
            obstacleBlock.physicsBody?.affectedByGravity = false
            obstacleBlock.physicsBody?.contactTestBitMask = 0x00000001
            obstacleBlock.physicsBody?.collisionBitMask = 0x00000001
            obstacleBlock.physicsBody?.categoryBitMask = 0x00000001
        }
    
    //spawns the player sprite in the bottom corner
    func spawnPlayer() {
        self.player.size = CGSize(width:size.width*0.1,height:size.width*0.1)
        self.player.position = CGPoint(x: size.width * 0.30, y: size.height * 0.15)
        self.player.physicsBody = SKPhysicsBody(rectangleOf:player.size)
        
        //Setting velocity to 0 on spawn and increased linear damping to make player slower
        player.physicsBody?.velocity = CGVector.zero
        player.physicsBody?.linearDamping = 20
        player.physicsBody?.isDynamic = true
        player.physicsBody?.contactTestBitMask = 0x00000001
        player.physicsBody?.collisionBitMask = 0x00000001
        player.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(player)
    }
    
    // Code to remove the player node from the parent
    func deletePlayer() {
        self.player.removeFromParent()
    }
    
    //function after player hits finish line
    func playWinSequence() {
        self.deletePlayer()
        self.deleteWallsAndFinish()
        self.gameplayAudio.run(SKAction.pause())
        self.gameplayAudio.removeFromParent()
        
        //grab winners audio file and play it
        let winAudio = SKAudioNode(fileNamed: "WinAudio")
        winAudio.autoplayLooped = false
        self.addChild(winAudio)
        winAudio.run(SKAction.play())
        
        //set background color to black
        self.backgroundColor = .black
        
        //functions to scale image
        let scaleUpAction = SKAction.scale(to: 4.0, duration: 0.05) // Scale up to 2x in 0.5 seconds
        let scaleDownAction = SKAction.scale(to: 2.0, duration: 0.5) // Scale back to original size in 0.1 seconds
        
        //winner's image
        let backgroundImage = SKSpriteNode(imageNamed: "winnerScreen")
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundImage.xScale = 2.0 // Increase the width by a factor of 2
        backgroundImage.yScale = 2.0 // Increase the height by a factor of 2
        self.addChild(backgroundImage)
        
        //animate the image and pause the win audio
        backgroundImage.run(scaleUpAction) {
            backgroundImage.run(scaleDownAction)
        }
        winAudio.run(SKAction.pause())
        winAudio.removeFromParent()
    }
    
    func addAllTheGameWalls() {
        // Dimensions for the maze walls
        let wallThickness = CGFloat(80)  // Wall thickness for most walls
        let horizontalWallThickness = CGFloat(60)  // The wall thickness for horizontal walls

        // Top wall
        topWall.color = .black
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
    
    @objc func resumeMotionUpdates() {
        self.startMotionUpdates()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == finishLine || contact.bodyB.node == finishLine {
            playWinSequence()
        }
        
        if (contact.bodyA.node == player && contact.bodyB.node != finishLine) 
            || (contact.bodyB.node == player && contact.bodyA.node != finishLine) {
            self.deletePlayer()
            
            // Reset the gravity
            self.physicsWorld.gravity = CGVector.zero
//            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.resumeMotionUpdates), userInfo: nil, repeats: false)

            self.spawnPlayer()
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

