import UIKit
import CoreMotion

// NOTE: ChatGPT helped us comment this code.
class ActivityModel: NSObject {
    
    //MARK: =====CLASS VARIABLES=====
    
    // Lazy instantiation of the activity manager responsible for walking, cycling, etc.
    private lazy var activityManager: CMMotionActivityManager = {
        return CMMotionActivityManager()
    }()
    
    // Lazy instantiation of the pedometer for step data
    private lazy var pedometer: CMPedometer = {
        return CMPedometer()
    }()
    
    //MARK: =====STEP FETCHING=====
    
    var yesterdaySteps: Float = -1.0 // Saves steps taken yesterday, starts at -1 to set only once
    var todaySteps: Float = 0.0 // Saves the steps taken today
    
    // Fetches step data between two specified dates.
    //
    // - Parameters:
    //   - startDate: The start date for fetching step data.
    //   - endDate: The end date for fetching step data.
    //   - completion: A completion handler that provides step count or error.
    // - Note: This method queries the `pedometer` for step data between the 
    //   specified dates and passes the result or error to the completion handler.
    func fetchSteps(from startDate: Date, to endDate: Date, completion: @escaping (Float?, Error?) -> Void) {
        
        // Query the pedometer for step data
        self.pedometer.queryPedometerData(from: startDate, to: endDate) { data, error in
            
            // Check if data exists, if not, return the error through completion
            guard let steps = data?.numberOfSteps else {
                completion(nil, error)
                return
            }
            
            // Provide the step count through completion
            completion(steps.floatValue, nil)
        }
    }
    
    
    
    // Begins activity monitoring to determine the user's current motion (walking, cycling, etc.).
    //
    // - Parameter completion: A completion handler that provides motion activity data.
    // - Note: This method starts activity updates and provides motion data to the completion handler.
    func startActivityMonitoring(completion: @escaping (CMMotionActivity?) -> Void) {
        
        // Start activity updates with the activity manager
        self.activityManager.startActivityUpdates(to: OperationQueue()) { activity in
            
            // Provide the motion activity data to the completion handler
            completion(activity)
        }
    }
    
    // Determines if activity monitoring is available on the device.
    //
    // - Returns: Boolean indicating availability of motion activity monitoring.
    func isActivityMonitoringAvailable() -> Bool {
        return CMMotionActivityManager.isActivityAvailable()
    }
    
    // Determines if step counting is available on the device.
    //
    // - Returns: Boolean indicating availability of step counting.
    func isStepCountingAvailable() -> Bool {
        return CMPedometer.isStepCountingAvailable()
    }
    
    // Stops activity monitoring.
    //
    // - Note: This method should be called when activity monitoring is no longer needed to save resources.
    func stopActivityMonitoring() {
        self.activityManager.stopActivityUpdates()
    }
}
