import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    //MARK: =====class variables=====
    let activityManager = CMMotionActivityManager() // for walking, cycling, etc.
    let pedometer = CMPedometer() // gets the step data
    let defaults = UserDefaults.standard
    
    var goalSteps: Float = 100.0 // goal for game, default to minimum
    var dayBefore:Date = Date() // Saves the begining of the day before current day
    var startDate:Date = Date() // Saves the begining of the current day
    var endDate:Date = Date() // Saves the end of the current day
    
    var yesterdaySteps:Float = -1.0 // Saves steps taken yesterday, starts at -1 to set only once
    var todaySteps:Float = 0.0 // Saves the steps taken today
    
    // Updates the goal # text, the progress bar, and the progress bar text
    func updateStepsLeft() {
        goalText.text = "Goal: \(Int(goalSteps)) steps" // Goal # text
        progress.setProgress(todaySteps / goalSteps, animated: true) //  Updates progress bar
        let stepsLeft = goalSteps - todaySteps // Calculate remaining
        OperationQueue.main.addOperation {
            self.toGoSteps.text = "Steps left: \(max(0, Int(stepsLeft)))" // Updates progress bar text
        }
    }
    //MARK: =====UI Elements=====
    @IBOutlet weak var stepsLabel: UILabel! // Label for today's steps
    @IBOutlet weak var goalSlider: UISlider! // Slider to change the goal
    @IBOutlet weak var goalText: UILabel! // Text to display goal from slider
    @IBOutlet weak var toGoSteps: UILabel! // Label to display steps remaining in day to reach goal
    @IBOutlet weak var progress: UIProgressView! // Progress bar. Fills with blue as steps today reach goal
    @IBOutlet weak var gameButton: UIButton! // Button to start game. Hidden when the goal was not reached the previous day
    @IBOutlet weak var activityLabel: UILabel! // Label for activity (Walking, running, cycling, etc.)
    @IBOutlet weak var yesterdayLabel: UILabel! // Label to display steps from previous day
    
    // Runs when the slider is set to a value
    @IBAction func onInput(_ sender: UISlider) {
        goalSteps = Float(Int(sender.value)) * 100.0 // Update goal variable with input
        gameButton.isHidden = yesterdaySteps <= goalSteps // Show/hide button if testerday's steps are above/below new goal
        defaults.set(goalSteps, forKey:"goal") // Saves the new goal into default for persistance
        updateStepsLeft() // Run update steps left function
    }
    
    
    //MARK: =====View Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets the begining of the day before current
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            dayBefore = Calendar.current.startOfDay(for: date)
        }
        // Gets begining of today
        if let date = Calendar.current.date(byAdding: .day, value: 0, to: Date()) {
            startDate = Calendar.current.startOfDay(for: date)
        }
        // Gets the end of today
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            endDate = Calendar.current.startOfDay(for: date)
        }
        
        // Due to being the first call to the pedometer, this will get and set the steps from yesterday
        if CMPedometer.isStepCountingAvailable(){
            pedometer.queryPedometerData(from: dayBefore, to: startDate) {
                [weak self] (data, error) in self?.handlePedometer(data, error: error)
            }
        }
        // Begins activity monitoring, only getting/setting the steps from today from this point on
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.startPedometerMonitoring()
        }
        
        // Begin updating the activity type
        self.startActivityMonitoring()
        
        // Sets the goal steps to the default value with a minimum of 100 for persistance
        goalSteps = max(defaults.float(forKey: "goal"), 100.0)
        goalSlider.setValue(goalSteps / 100.0, animated: false) // Sets slider value to new goal value
        gameButton.isHidden = yesterdaySteps <= goalSteps // Hides or shows the game button based on new goal
        
        // Run update remaining with saved goal
        updateStepsLeft()
    }
    
    // MARK: =====Activity Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (NOT THE MAIN QUEUE)
            self.activityManager.startActivityUpdates(
                to: OperationQueue.init(),
                withHandler: self.handleActivity
            )
        }
        
    }
    
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            OperationQueue.main.addOperation{
                
                // Run in hierarchy of priority. If driving is detected, it is displayed. Followed by cycling, running, etc.
                
                if(unwrappedActivity.automotive){ // Display if driving is detected as acrivity
                    self.activityLabel.text = "You are driving"
                }
                else if(unwrappedActivity.cycling){ // Display if cycling is detected as acrivity
                    self.activityLabel.text = "You are cycling"
                }
                else if(unwrappedActivity.running){ // Display if running is detected as acrivity
                    self.activityLabel.text = "You are running"
                }
                else if(unwrappedActivity.walking){ // Display if walking is detected as acrivity
                    self.activityLabel.text = "You are walking"
                }
                else if(unwrappedActivity.stationary){ // Display user is detected to be still
                    self.activityLabel.text = "You are still"
                }
                else  if(unwrappedActivity.unknown){ // Display if an unknown activity is detected
                    self.activityLabel.text = "Activity is unknown"
                }
            }
        }
    }
    
    // MARK: =====Pedometer Methods=====
    func startPedometerMonitoring(){
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.queryPedometerData(from: startDate, to: endDate) { // Gets data from start of today to end of today
                [weak self] (data, error) in self?.handlePedometer(data, error: error)
            }
        }
    }
    
    //pedometer handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?) {
        if let steps = pedData?.numberOfSteps { // Number of steps found in time range
            OperationQueue.main.addOperation { [weak self] in
                guard let self = self else { return }
                // If this is the first time this has run, yesterdaySteps will still be at default, -1
                if(yesterdaySteps == -1.0){ // If this is the first iteration, we need to set yesterday steps
                    self.yesterdaySteps = steps.floatValue // Update yesterday steps
                    self.yesterdayLabel.text = "Steps taken yesterday: " + String(Int(yesterdaySteps)) // And the label
                    gameButton.isHidden = yesterdaySteps <= goalSteps // And show/hide the game button based on new steps
                }
                else{ // Otherwise, we need to update the steps from today
                    self.todaySteps = steps.floatValue // Get new steps
                    self.stepsLabel.text = "Steps taken today: " + String(Int(todaySteps)) // Update label
                    updateStepsLeft() // Run update function
                }
            }
        }
    }
}
