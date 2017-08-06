//
//  ViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 6/13/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var taskList: UICollectionView!
        
    
    var tasks = [String]()
    //var taskSettings: [String : [String : Int]] = [:]
    //var taskStatistics: [String : [String : Int]] = [:]
    
    var taskData = TaskData()
    
    var taskTimer = Timer()
    var timerEnabled = false
    var cellIndexPath: IndexPath = []
    
    var willResetTimer = false
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = "taskCollectionCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! RepeatingTasksCollectionCell
        
        let task = tasks[indexPath.row]
        
        //cell.playStopButton.setTitle("U000025B6", for: .normal)
        cell.playStopButton.setTitle("Start", for: .normal)
        cell.progressView.progress = 0.0
        cell.progressView.setProgress(0.0, animated: false)
        cell.taskNameField.text = task
        
        _ = formatTimer(for: cell, decrement: false)
        
        let gradient = CAGradientLayer()
        
        gradient.frame = cell.layer.bounds
        
        let gradientColor2 = UIColor.clear
        let gradientColor1 = UIColor.white.cgColor
        
        gradient.colors = [gradientColor1,gradientColor2]
        
        gradient.locations = [0.0, 0.75]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        
        cell.layer.addSublayer(gradient)
        
        switch (indexPath.row % 4) {
        case 0:
            cell.bgView.backgroundColor = UIColor(hue: 200/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
            cell.backgroundColor = UIColor(hue: 200/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
            
        case 1:
            cell.bgView.backgroundColor = UIColor(hue: 60/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
            cell.backgroundColor = UIColor(hue: 60/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
        case 2:
            cell.bgView.backgroundColor = UIColor(hue: 280/360, saturation: 0.35, brightness: 1.0, alpha: 1.0)
            cell.backgroundColor = UIColor(hue: 280/360, saturation: 0.35, brightness: 1.0, alpha: 1.0)
        case 3:
            cell.bgView.backgroundColor = UIColor(hue: 359/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
            cell.backgroundColor = UIColor(hue: 359/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
        default:
            break
        }
        
        
        cell.layer.cornerRadius = 10.0
        cell.layer.borderWidth = 1.0
        cell.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 2.0
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.layer.bounds, cornerRadius: cell.layer.cornerRadius).cgPath

        cell.progressView.progressTintColor = UIColor.darkGray
        
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load any saved data
        loadData()
        
        if tasks.isEmpty {
            tasks = ["Test1", "Test2", "Test3", "Test4", "Test5"]
        }
        
        print("loaded Values")
        print(tasks)
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        navigationItem.rightBarButtonItems = [addBarButton]
        
        // Check current time
        // Determine the time interval between now and when the timers will reset
        // Set a timer to go off at that time
        
        let now = Date()
        let calendar = Calendar.current
        
        var today = DateComponents()
        today.year = calendar.component(.year, from: now)
        today.month = calendar.component(.month, from: now)
        today.day = calendar.component(.day, from: now)
        today.hour = calendar.component(.hour, from: now)
        today.minute = calendar.component(.minute, from: now)
        
        print(today.year)
        print(today.month)
        print(today.day)
        print(today.hour)
        print(today.minute)
        
        
        var tomorrow = DateComponents()
        tomorrow.year = today.year
        tomorrow.month = today.month
        if today.hour! < 2 { // check if it's actually late at night
            tomorrow.day = today.day!
            
        } else {
            tomorrow.day = today.day! + 1
            
        }
        tomorrow.hour = 2 // load hour and minutes here
        tomorrow.minute = 0

        print(tomorrow.year)
        print(tomorrow.month)
        print(tomorrow.day)
        print(tomorrow.hour)
        print(tomorrow.minute)
        
        let tomorrowDate = calendar.date(from: tomorrow)
        
        let differenceComponents = calendar.dateComponents([.hour, .minute, .second], from: Date(), to: tomorrowDate!)
        
        let timeDifference = TimeInterval((differenceComponents.hour! * 3600) + (differenceComponents.minute! * 60) + differenceComponents.second!)
        
        print("now is \(now)")
        print("tomorrow is \(String(describing: tomorrowDate))")
        print("Time difference between now and 2am tomorrow is \(timeDifference) seconds")        
        //let tomorrow = Date(timeIntervalSinceNow: 1)
        //let currentTime = date.timeIntervalSince1970

        // If the current time is later than the reset time then reset now
        // Otherwise set task to reset at presribed time
        if timeDifference < 0 {
            
            if !timerEnabled {
                resetTaskTimers()
            } else {
                willResetTimer = true
            }
            
        } else {
            let resetTime = Date().addingTimeInterval(timeDifference)
            let resetTimer = Timer(fireAt: resetTime, interval: 0, target: self, selector: #selector(resetTaskTimers), userInfo: nil, repeats: false)
            RunLoop.main.add(resetTimer, forMode: RunLoopMode.commonModes)
        }
    
    }
    
    func resetTaskTimers() {
        print("RESET!!!!!!!!")
        
        // Iterate through all tasks and do the following
        // 1. Reset completed time
        // 2. Calculate leftover time
        // 3. Refresh screen
        for x in 0...(tasks.count - 1) {
            let task = tasks[x]
            
            taskData.setTask(as: task)
            
            let (_, weightedTaskTime) = getWeightedTime(for: task)

            let completedTime = taskData.completedTime
            
            let leftoverFromYesterday = weightedTaskTime - completedTime
            
            taskData.taskDictionary[task]?["completedTime"] = 0
            
            taskData.taskDictionary[task]?["leftoverTime"] = leftoverFromYesterday
            
        }
        
        DispatchQueue.main.async {
            self.taskList.reloadData()
        }

        saveData()
        
    }

    @IBAction func taskStartStopButtonPressed(_ sender: UIButton) {
        
        print("test")
        
        guard let cell = sender.superview?.superview as? RepeatingTasksCollectionCell else {
            return // or fatalError() or whatever
        }
        
        cellIndexPath = taskList.indexPath(for: cell)!
        
        print("indexPath is \(cellIndexPath.row)")
        
        if cell.playStopButton.currentTitle == "Start" {
            timerEnabled = true
            cell.playStopButton.setTitle("Stop", for: .normal)

            taskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                             selector: #selector(timerRunning), userInfo: cell, repeats: true)
        
        } else {
            timerEnabled = false
            cell.playStopButton.setTitle("Start", for: .normal)

            taskTimer.invalidate()
            
            if willResetTimer {
                resetTaskTimers()
            }
            
            saveData()
        }
        
    }
    
    func timerRunning() {
        
        let cell = taskTimer.userInfo as! RepeatingTasksCollectionCell
        let taskName = cell.taskNameField.text!
        
        let timeRemaining = formatTimer(for: cell, decrement: true)
        
        print("Time remaining is \(timeRemaining)")
        
        // ?????????????????????????????????
        // Shoud I be doing this now ??????????
        // ?????????????????????????????????
        
        taskData.setTask(as: taskName)
        
        taskData.taskDictionary[taskName]?["completedTime"]! += 1

//        if (taskData.completedTime != nil) {
//            print("Incrementing task time")
//            taskSettings[taskName]!["completedTime"]! += 1
//        } else {
//            print("No task time set")
//            taskSettings[taskName]!["completedTime"] = 1
//        }
        
        //let taskTime = currentTask["taskTime"] ?? 0
        
        //var (hours, minutes, seconds) = secondsToHoursMinutesSeconds(from: remainingTaskTime)
        
        //let completionPercentage = Int(((Float(taskTime) - Float(timeRemaining))/Float(taskTime)) * 100)
        //progressLabel.text = "\(completionPercentage)% done"
        //manageTimerEnd(seconds: timeRemaining)
        
    }
    
    func formatTimer(for cell: RepeatingTasksCollectionCell, decrement: Bool) -> Int {
        // Used for initialization and when the task timer is updated
        
        let task = cell.taskNameField.text!
        taskData.setTask(as: task)
        
        let (taskTime, weightedTaskTime) = getWeightedTime(for: task)
        let completedTime = taskData.completedTime
        
        var remainingTaskTime = weightedTaskTime - completedTime
        
        print("Completed time is \(completedTime)")
        
        if decrement {
            remainingTaskTime -= 1
        }
        
        let currentProgress = 1 - Float(remainingTaskTime)/Float(taskTime)
        
        cell.progressView.setProgress(currentProgress, animated: true)
        
        print("Current progress is \(currentProgress)")
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        let remainingTimeAsString = formatter.string(from: TimeInterval(remainingTaskTime))!
        
        cell.taskTimeRemaining.text = remainingTimeAsString
        
        return remainingTaskTime

    }
    
    func getWeightedTime(for task: String) -> (Int, Int) {
        
        let taskTime = taskData.taskTime
        let leftoverMultiplier = taskData.leftoverMultiplier
        let leftoverTime = taskData.leftoverTime
        
        return (taskTime, taskTime + (leftoverTime * leftoverMultiplier))
        
    }
    
    func addTask() {
        print("Do stuff")
        performSegue(withIdentifier: "addTaskSegue", sender: nil)
    
    }
    
    @IBAction func newTaskCreatedUnwind(segue: UIStoryboardSegue) {
        
        print("Is this being run?")
        print(tasks)
        
        saveData()
        
        DispatchQueue.main.async {
            self.taskList.reloadData()
        }
        
    }

    func loadData() {
        
        taskData.load()
        
        tasks = taskData.taskNameList
        
    }
    
    func saveData() {
        
        taskData.save()
        
        tasks = taskData.taskNameList
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func secondsToHoursMinutesSeconds(from seconds: Int) -> (Int, Int, Int) {
        
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) & 60)
        
    }
    

}

//extension ViewController:JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
//    
//    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
//        
//        formatter.dateFormat = "yyyy MM dd"
//        formatter.locale = Calendar.current.locale
//        formatter.timeZone = Calendar.current.timeZone
//        
//        let startDate = formatter.date(from: "2017 07 01")
//        let endDate = formatter.date(from: "2017 08 31")
//        
//        
//        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
//        return parameters
//        
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
//        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCelReuse", for: indexPath) as! CalendarTEST
//        cell.calendarTestLabel.text = cellState.text
//        return cell
//        
//        
//    }
//    
//}

