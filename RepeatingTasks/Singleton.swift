//
//  Singleton.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/10/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation
import UserNotifications

class CountdownTimer: NSObject {
    
    var isEnabled = false
    var firedFromMainVC = false

    @objc dynamic var remainingTime = 0
    var run = Timer()
    
    var cell: TaskCollectionViewCell? = nil
    
    var startTime = Date().timeIntervalSince1970
    var endTime = Date().timeIntervalSince1970
    var currentTime = Date().timeIntervalSince1970
    
    @objc dynamic var elapsedTime = 0.0
    
    //var taskData = TaskData()
    
    func startTimer(for view: Any?) {
        
        var test = [view]
        test.append("name")
        run = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                              selector: #selector(timerRunning), userInfo: view, repeats: true)
        
    }
    
    func stopTimer(for view: Any?) {
        run.invalidate()        
    }
    
    @objc func timerRunning() {
        
    }
    
    func formatTimer(for task: Task, from cell: TaskCollectionViewCell? = nil, ofType type: CellType? = nil) -> (String, Double) {
        // Used for initialization and when the task timer is updated

        currentTime = Date().timeIntervalSince1970
        print(task.completed)
        elapsedTime = task.completed

        if self.isEnabled && task.isRunning {
            elapsedTime += (currentTime - startTime)
        }
        
        let weightedTime = task.weightedTime
        let remainingTime = weightedTime - elapsedTime
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional

        if remainingTime < 60 {
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
        } else {
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .default
        }
        
        var remainingTimeAsString = formatter.string(from: TimeInterval(remainingTime.rounded()))!
        
        if remainingTime <= 0 {
            remainingTimeAsString = "Complete"
        }
        
        if (cell != nil) {
            
            let currentProgress = 1 - Float(remainingTime)/Float(weightedTime)
            
            if type == .line {
                //TaskViewController.calculateProgress()
                //cell!.progressView.setProgress(currentProgress, animated: true)
            
            } else if type == .circular {
                cell!.circleProgressView.progress = Double(currentProgress)
            }
            
            print("Current progress is \(currentProgress)")
            
            cell!.taskTimeRemaining.text = remainingTimeAsString
            
        }
        
        return (remainingTimeAsString, remainingTime)
        
    }

//    func getWeightedTime(for task: String) -> (Double, Double) {
//
//        let taskTime = taskData.taskTime
//        let rolloverMultiplier = taskData.rolloverMultiplier
//        let rolloverTime = taskData.rolloverTime
//
//        return (taskTime, taskTime + (rolloverTime * rolloverMultiplier))
//
//    }
    
    // MARK: - Notification Functions
    
    func setFinishedNotification(for task: String, atTime time: Double) {
        
        let notification = UNMutableNotificationContent()
        notification.title = "Task Complete"
        notification.body = "Great job! You've completed " + task + "."
        
        let id = task + "Complete"
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: notification, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func cancelFinishedNotification(for task: String) {
        
        let id = task + "Complete"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
        //        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
        //            var identifiers: [String] = []
        //            for notification:UNNotificationRequest in notificationRequests {
        //                if notification.identifier == id {
        //                    identifiers.append(notification.identifier)
        //                }
        //            }
        //            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        //        }
        
    }
    
    func setMissedTimeNotification(for task: String, at time: TimeInterval, withRemaining remainingTime: String) {
        
        let notification = UNMutableNotificationContent()
        notification.title = "Oh no"
        notification.body = "You didn't complete " + task + ". " + remainingTime + " will be added next time."
        
        let id = task + "Missed"
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: notification, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func cancelMissedTimeNotification(for task: String) {
        
        let id = task + "Missed"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
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
