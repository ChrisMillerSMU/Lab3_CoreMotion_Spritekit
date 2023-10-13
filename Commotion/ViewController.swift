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
    let defaults = UserDefaults.standard
    
    var goalSteps: Float = 100.0
    var dayBefore:Date = Date()
    var startDate:Date = Date()
    var endDate:Date = Date()
    
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
    func updateStepsLeft() {
        goalText.text = "Goal: \(Int(goalSteps)) steps"
        
        progress.setProgress(totalSteps / goalSteps, animated: true)
        let stepsLeft = goalSteps - totalSteps
        DispatchQueue.main.async {
            self.toGoSteps.text = "Steps left: \(Int(stepsLeft))"
        }
    }
    //MARK: =====UI Elements=====
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var goalSlider: UISlider!
    @IBOutlet weak var goalText: UILabel!
    @IBOutlet weak var toGoSteps: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var isStill: UILabel!
    @IBOutlet weak var isWalking: UILabel!
    @IBOutlet weak var isRunning: UILabel!
    @IBOutlet weak var isCycling: UILabel!
    @IBOutlet weak var isDriving: UILabel!
    
    @IBAction func onInput(_ sender: UISlider) {
        goalSteps = Float(Int(sender.value)) * 100.0
        defaults.set(goalSteps, forKey:"goal")
        updateStepsLeft()
    }
    
    
    //MARK: =====View Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            dayBefore = Calendar.current.startOfDay(for: date)
        }
        if let date = Calendar.current.date(byAdding: .day, value: 0, to: Date()) {
            startDate = Calendar.current.startOfDay(for: date)
        }
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            endDate = Calendar.current.startOfDay(for: date)
        }
        
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        goalSteps = max(defaults.float(forKey: "goal"), 100.0)
        goalSlider.setValue(goalSteps / 100.0, animated: false)
        updateStepsLeft()
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
            pedometer.queryPedometerData(from: dayBefore, to: startDate) {
                [weak self] (data, error) in self?.handlePedometer(data, error: error)
            }
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
