//
//  MazeGameViewController.swift
//  Commotion
//

import UIKit
import SpriteKit

// ChatGPT helped us add comments to be more explicit throughout this code.

// The `MazeGameViewController` manages the main game view.
// This view controller contains the SpriteKit game scene where the maze gameplay occurs.
class MazeGameViewController: UIViewController {

    // The main game scene where all the gameplay elements and logic reside.
    var scene: MazeGameScene?
    
    // This function is called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the game scene with the appropriate size.
        scene = MazeGameScene(size: view.bounds.size)
        
        // Initialize the SpriteKit view and set its properties.
        let skView = view as! SKView // Ensure the view in the storyboard is of type SKView.
        skView.showsFPS = true // Display frames per second.
        skView.showsNodeCount = true // Display the number of nodes in the scene.
        skView.ignoresSiblingOrder = true // Optimize rendering performance.
        
        // Set the scaling mode and present the game scene.
        self.scene!.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    // This function is called just before the view controller's view disappears.
    //
    // It ensures that any playing audio from the game scene is stopped when leaving this view controller.
    override func viewWillDisappear(_ animated: Bool) {
        self.scene?.stopTheAudio()
    }
    
}
