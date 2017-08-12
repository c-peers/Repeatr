//
//  Singleton.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/10/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class CountdownTimer: NSObject {
    
    var isEnabled = false

    dynamic var remainingTime = 0
    private var countdownTimer = Timer()
    
    var startTime = Date()
    var endTime = Date()
    
    func startTimer(for view: Any?) {
        
        var test = [view]
        test.append("name")
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                              selector: #selector(timerRunning), userInfo: view, repeats: true)
        
    }
    
    func stopTimer(for view: Any?) {
        countdownTimer.invalidate()
        
        //Task.instance.data.save()
    }
    
    func timerRunning() {
        
//        //let userData = timer.userInfo as Array
//        //let cellz = userData[0] as! RepeatingTasksCollectionCell
//        
//        let cell = countdownTimer.userInfo as! RepeatingTasksCollectionCell
//        let taskName = cell.taskNameField.text!
//        
//        let (_, timeRemaining) = formatTimer(for: taskName, from: cell, decrement: true)
//        
//        print("Time remaining is \(timeRemaining)")
//        
//        Task.instance.data.setTask(as: taskName)
//        
//        Task.instance.data.taskDictionary[taskName]?["completedTime"]! += 1
//        
//        let competedTime = Task.instance.data.taskDictionary[taskName]?["completedTime"]!
//        let taskTime = Task.instance.data.taskDictionary[taskName]?["taskTime"]!
//        
//        if timeRemaining == 0 || (competedTime == taskTime) {
//            countdownTimer.invalidate()
//            
//            //timerEnabled = false
//            
//            cell.taskTimeRemaining.text = "Complete"
//            cell.playStopButton.setTitle("Start", for: .normal)
//            cell.playStopButton.isEnabled = false
//            
//            Task.instance.data.save()
//            //saveData()
//            
//        }
        
    }
    
    func formatTimer(for task: String, from cell: RepeatingTasksCollectionCell? = nil, decrement: Bool) -> (String, Int) {
        // Used for initialization and when the task timer is updated
        
//        Task.instance.data.setTask(as: task)
//        
//        let (taskTime, weightedTaskTime) = getWeightedTime(for: task)
//        let completedTime = Task.instance.data.completedTime
//        
//        remainingTime = weightedTaskTime - completedTime
//        
//        print("Completed time is \(completedTime)")
//        
//        if decrement {
//            remainingTime -= 1
//        }
//        
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .positional
//        
//        var remainingTimeAsString = formatter.string(from: TimeInterval(remainingTime))!
//        
//        if remainingTime == 0 {
//            remainingTimeAsString = "Complete"
//        }
//        
//        if (cell != nil) {
//            
//            let currentProgress = 1 - Float(remainingTime)/Float(taskTime)
//            
//            cell!.progressView.setProgress(currentProgress, animated: true)
//            
//            print("Current progress is \(currentProgress)")
//            
//            cell!.taskTimeRemaining.text = remainingTimeAsString
//            
//        }
//        
//        return (remainingTimeAsString, remainingTime)

        return ("", 0)
        
    }
    
    func getWeightedTime(for task: String) -> (Int, Int) {
        
//        let taskTime = Task.instance.data.taskTime
//        let leftoverMultiplier = Task.instance.data.leftoverMultiplier
//        let leftoverTime = Task.instance.data.leftoverTime
//        
//        return (taskTime, taskTime + (leftoverTime * leftoverMultiplier))
        
        return (0, 0)
        
    }

}

//class Task: NSObject {
//    
//    // These are the properties you can store in your singleton
//    var data: TaskData
//    var settings: AppData
//    var timer: CountdownTimer
//    
//    // Here is how you would get to it without there being a global collision of variables.
//    // , or in other words, it is a globally accessable parameter that is specific to the
//    // class.
//    static var instance = Task()
//    //static let data = TaskData()
//    private override init() {
//        data = TaskData()
//        settings = AppData()
//        timer = CountdownTimer()
//    }
//    
////    if willResetTimer {
////        resetTaskTimers()
////    }
////    
////    saveData()
//
//}
