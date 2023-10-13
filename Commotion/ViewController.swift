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
<<<<<<< HEAD
    let defaults = UserDefaults.standard
    
    var goalSteps: Float = 1.0 {
=======
    //sets up your step goal
    var goalSteps: Float = 0.0 {
>>>>>>> 02f8188dcfe5df0791353397be782f0452f7418e
        didSet {
            updateStepsLeft()
        }
    }
    //sets up total steps you have taken
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
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
        DispatchQueue.main.async {
            self.toGoSteps.text = "Steps left: \(Int(stepsLeft))"
        }
    }
    //MARK: =====UI Elements=====
    //labels and slider for your step goal and current steps
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var goalSlider: UISlider!
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
        defaults.set(goalSteps, forKey:"goal")
        goalText.text = "Goal: \(Int(goalSteps)) steps"
    }
    
    
    //MARK: =====View Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        let goal = defaults.float(forKey: "goal")
        if(goal > 0.0){
            goalSteps = goal
            goalSlider.value = goal
        }
        else{
            defaults.set(1.0, forKey:"goal")
        }
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
