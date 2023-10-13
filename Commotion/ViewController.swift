//
//  ViewController.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    //MARK: =====class variables=====
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    //sets up your step goal
    var goalSteps: Float = 0.0 {
        didSet {
            updateStepsLeft()
        }
    }
    //sets up total steps you have taken
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
//                self.stepsSlider.setValue(newtotalSteps, animated: true)
                self.stepsLabel.text = "Steps: \(newtotalSteps)"
            }
        }
        didSet{
            updateStepsLeft()
        }
    }
    //updates the toGoSteps label with the current amount of steps
    //you need to hit your "step goal"
    func updateStepsLeft() {
        let stepsLeft = goalSteps - totalSteps
        print("left: ", stepsLeft)
        print("Goal: ", goalSteps)
        print("total: ", totalSteps)
        DispatchQueue.main.async {
            print("Updating steps left to: \(stepsLeft)") // Debug print statement
            self.toGoSteps.text = "Steps Left: \(Int(stepsLeft))"
            
        }
    }
    //MARK: =====UI Elements=====
    //labels and slider for your step goal and current steps
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var goalText: UILabel!
    //labels for current activity
    @IBOutlet weak var isStill: UILabel!
    @IBOutlet weak var isWalking: UILabel!
    @IBOutlet weak var isRunning: UILabel!
    @IBOutlet weak var isCycling: UILabel!
    @IBOutlet weak var isDriving: UILabel!
    //label for steps left until goal
    @IBOutlet weak var toGoSteps: UILabel!
    
    //adjusts your step goal with slider input
    @IBAction func onInput(_ sender: UISlider) {
        goalSteps = Float(Int(sender.value)) * 100.0
        goalText.text = "Goal: \(Int(goalSteps)) steps"
    }
    
    
    //MARK: =====View Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
    }
    
    // MARK: =====Activity Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
        
    }
    
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            DispatchQueue.main.async{
                //gets current activity and displays what user is doing
                self.isStill.text = "You are" + (unwrappedActivity.stationary ? " " : " not ") + "still"
                self.isWalking.text = "You are" + (unwrappedActivity.walking ? " " : " not ") + "walking"
                self.isRunning.text = "You are" + (unwrappedActivity.running ? " " : " not ") + "running"
                self.isCycling.text = "You are" + (unwrappedActivity.cycling ? " " : " not ") + "cycling"
                self.isDriving.text = "You are" + (unwrappedActivity.automotive ? " " : " not ") + "driving"
            }
        }
    }
    
    // MARK: =====Pedometer Methods=====
    func startPedometerMonitoring(){
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date(),
                                   withHandler: handlePedometer)
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?) {
        if let steps = pedData?.numberOfSteps {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.totalSteps = steps.floatValue
                self.stepsLabel.text = String(self.totalSteps)
            }
        }
    }
}
