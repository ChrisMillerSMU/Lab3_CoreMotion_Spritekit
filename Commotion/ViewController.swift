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
    
    var yesterdaySteps:Float = -1.0
    var todaySteps:Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.stepsLabel.text = "Steps: \(Int(newtotalSteps))"
            }
        }
        didSet{
            updateStepsLeft()
        }
    }
    func updateStepsLeft() {
        goalText.text = "Goal: \(Int(goalSteps)) steps"
        
        progress.setProgress(todaySteps / goalSteps, animated: true)
        let stepsLeft = goalSteps - todaySteps
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
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var yesterdayLabel: UILabel!
    
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
        
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        if CMPedometer.isStepCountingAvailable(){
            pedometer.queryPedometerData(from: startDate, to: endDate) {
                [weak self] (data, error) in self?.handlePedometer(data, error: error)
            }
        }
        
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
                if(unwrappedActivity.automotive){
                    self.activityLabel.text = "You are driving"
                }
                else if(unwrappedActivity.cycling){
                    self.activityLabel.text = "You are cycling"
                }
                else if(unwrappedActivity.running){
                    self.activityLabel.text = "You are running"
                }
                else if(unwrappedActivity.walking){
                    self.activityLabel.text = "You are walking"
                }
                else if(unwrappedActivity.stationary){
                    self.activityLabel.text = "You are still"
                }
                else  if(unwrappedActivity.unknown){
                    self.activityLabel.text = "Activity is unknown"
                }
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
    
    //pedometer handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?) {
        if let steps = pedData?.numberOfSteps {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if(yesterdaySteps == -1.0){
                    self.yesterdaySteps = steps.floatValue
                    self.yesterdayLabel.text = "Steps taken yesterday: " + String(Int(yesterdaySteps))
                    gameButton.isHidden = yesterdaySteps <= goalSteps
                }
                else{
                    self.todaySteps = steps.floatValue
                    self.stepsLabel.text = "Steps taken today: " + String(Int(todaySteps))
                }
            }
        }
    }
}
