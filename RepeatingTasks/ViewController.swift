//
//  ViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 6/13/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

class TaskViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //MARK: - View Controller

    //MARK: - Collection View Delegate

    //MARK: - Collection View Data Source

    @IBOutlet weak var taskList: UICollectionView!
    
    var tasks = [String]()
    
    dynamic var taskData = TaskData()
    var appData = AppData()
    var countdownTimer = CountdownTimer()
    
    var taskTimer = Timer()
    
    //var timerEnabled = false
    var timerFiringFromTaskVC = false
    
    var selectedTask = ""
    var selectedCell: RepeatingTasksCollectionCell?
    var runningCompletionTime = 0.0
    
    var willResetTimer = false
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = "taskCollectionCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! RepeatingTasksCollectionCell
        
        let task = tasks[indexPath.row]
        
        if taskData.timerEnabled && task == selectedTask {
            cell.playStopButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        } else {
            cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        }
        
        cell.playStopButton.backgroundColor = UIColor.clear
        
        
        cell.progressView.progress = 0.0
        cell.progressView.setProgress(0.0, animated: false)
        cell.taskNameField.text = task
        
        //_ = formatTimer(for: cell, decrement: false)
        //(_, _) = Task.instance.timer.formatTimer(for: task, from: cell, decrement: false)
        (_, _) = formatTimer(for: task, from: cell)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        //cell.taskTimeRemaining.text = formatter.string(from: TimeInterval(Task.instance.timer.remainingTime))!
        //cell.taskTimeRemaining.text = formatter.string(from: TimeInterval(countdownTimer.remainingTime))!
        
        if cell.taskTimeRemaining.text == "Complete" {
            cell.playStopButton.isEnabled = false
        } else {
            cell.playStopButton.isEnabled = true
        }
        
        let colorArray = ColorSchemeOf(.analogous, color: .flatSkyBlue, isFlatScheme: true)
        
        print(indexPath)
        
        //let gradientBackground = GradientColor(.leftToRight, frame: cell.frame, colors: [UIColor.flatSkyBlue, UIColor.flatSkyBlueDark])
        
        //cell.backgroundColor = gradientBackground
        
        cell.backgroundColor = colorArray[indexPath.row % 4]
        
//        let gradient = CAGradientLayer()
//        
//        gradient.frame = cell.layer.bounds
//        
//        let gradientColor2 = UIColor.clear
//        let gradientColor1 = UIColor.white.cgColor
//        
//        gradient.colors = [gradientColor1,gradientColor2]
//        
//        gradient.locations = [0.0, 0.75]
//        gradient.startPoint = CGPoint(x: 1, y: 0)
//        gradient.endPoint = CGPoint(x: 0, y: 1)
//        
//        cell.layer.addSublayer(gradient)
//        
//        switch (indexPath.row % 4) {
//        case 0:
//            cell.bgView.backgroundColor = UIColor(hue: 200/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
//            cell.backgroundColor = UIColor(hue: 200/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
//            
//        case 1:
//            cell.bgView.backgroundColor = UIColor(hue: 60/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
//            cell.backgroundColor = UIColor(hue: 60/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
//        case 2:
//            cell.bgView.backgroundColor = UIColor(hue: 280/360, saturation: 0.35, brightness: 1.0, alpha: 1.0)
//            cell.backgroundColor = UIColor(hue: 280/360, saturation: 0.35, brightness: 1.0, alpha: 1.0)
//        case 3:
//            cell.bgView.backgroundColor = UIColor(hue: 359/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
//            cell.backgroundColor = UIColor(hue: 359/360, saturation: 0.6, brightness: 1.0, alpha: 1.0)
//        default:
//            break
//        }
        
        
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
        
        let task = tasks[indexPath.row]
        
        taskData.setTask(as: task)
        
        selectedTask = taskData.taskName
        
        print("taskData taskName \(taskData.taskName)")
        
        performSegue(withIdentifier: "taskDetailSegue", sender: self)
        
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
        
        NotificationCenter.default.addObserver(forName: Notification.Name("StopTimerNotification"), object: nil, queue: nil, using: catchNotification)
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        navigationItem.rightBarButtonItems = [addBarButton]
        
        let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        toolbarItems = [settingsButton]
        navigationController?.isToolbarHidden = false
        
        // Check current time
        // Determine the time interval between now and when the timers will reset
        // Set a timer to go off at that time
        
        let now = Date()
        let calendar = Calendar.current
        
        var reset = DateComponents()
        reset.hour = calendar.component(.hour, from: appData.taskResetTime)
        reset.minute = calendar.component(.minute, from: appData.taskResetTime)
        
        var currentTime = DateComponents()
        currentTime.year = calendar.component(.year, from: now)
        currentTime.month = calendar.component(.month, from: now)
        currentTime.day = calendar.component(.day, from: now)
        currentTime.hour = calendar.component(.hour, from: now)
        currentTime.minute = calendar.component(.minute, from: now)
        
//        print(currentTime.year)
//        print(currentTime.month)
//        print(currentTime.day)
//        print(currentTime.hour)
//        print(currentTime.minute)
        
        let then = appData.taskLastTime
        var lastAppTime = DateComponents()
        lastAppTime.year = calendar.component(.year, from: then)
        lastAppTime.month = calendar.component(.month, from: then)
        lastAppTime.day = calendar.component(.day, from: then)
        lastAppTime.hour = calendar.component(.hour, from: then)
        lastAppTime.minute = calendar.component(.minute, from: then)

        reset.year = currentTime.year
        reset.month = currentTime.month
        
        if (lastAppTime.year != currentTime.year) || (lastAppTime.month != currentTime.month) {
            reset.day = currentTime.day
        } else if lastAppTime.day != currentTime.day {
            reset.day = currentTime.day
        } else {
            reset.day = currentTime.day! + 1
        }
        
        let resetTime = calendar.date(from: reset)
        
        if now < resetTime! {
            
            let differenceComponents = calendar.dateComponents([.hour, .minute, .second], from: Date(), to: resetTime!)
            let timeDifference = TimeInterval((differenceComponents.hour! * 3600) + (differenceComponents.minute! * 60) + differenceComponents.second!)
            
            let timeToResetTime = Date().addingTimeInterval(timeDifference)
            let resetTimer = Timer(fireAt: timeToResetTime, interval: 0, target: self, selector: #selector(resetTaskTimers), userInfo: nil, repeats: false)
            RunLoop.main.add(resetTimer, forMode: RunLoopMode.commonModes)

        } else {

            //if !Task.instance.timer.isEnabled {
            if !taskData.timerEnabled {
                resetTaskTimers()
            } else {
                willResetTimer = true
            }

        }
        

        
//        var tomorrow = DateComponents()
//        tomorrow.year = currentTime.year
//        tomorrow.month = currentTime.month
//        if today.hour! < 2 { // check if it's actually late at night
//            tomorrow.day = currentTime.day!
//            
//        } else {
//            tomorrow.day = currentTime.day! + 1
//            
//        }
//        tomorrow.hour = 2 // load hour and minutes here
//        tomorrow.minute = 0
//
//        print(tomorrow.year)
//        print(tomorrow.month)
//        print(tomorrow.day)
//        print(tomorrow.hour)
//        print(tomorrow.minute)
//        
//        let tomorrowDate = calendar.date(from: tomorrow)
        
//        let differenceComponents = calendar.dateComponents([.hour, .minute, .second], from: Date(), to: tomorrowDate!)
//        
//        let timeDifference = TimeInterval((differenceComponents.hour! * 3600) + (differenceComponents.minute! * 60) + differenceComponents.second!)
//        
//        print("now is \(now)")
//        print("tomorrow is \(String(describing: tomorrowDate))")
//        print("Time difference between now and 2am tomorrow is \(timeDifference) seconds")        
        //let tomorrow = Date(timeIntervalSinceNow: 1)
        //let currentTime = date.timeIntervalSince1970

        // If the current time is later than the reset time then reset now
        // Otherwise set task to reset at presribed time
//        if timeDifference < 0 {
//            
//            if !timerEnabled {
//                resetTaskTimers()
//            } else {
//                willResetTimer = true
//            }
//            
//        } else {
//            let resetTime = Date().addingTimeInterval(timeDifference)
//            let resetTimer = Timer(fireAt: resetTime, interval: 0, target: self, selector: #selector(resetTaskTimers), userInfo: nil, repeats: false)
//            RunLoop.main.add(resetTimer, forMode: RunLoopMode.commonModes)
//        }
    
    }
    
    func settingsButtonTapped() {
        performSegue(withIdentifier: "appSettingsSegue", sender: self)
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
        
        guard let cell = sender.superview?.superview as? RepeatingTasksCollectionCell else {
            return // or fatalError() or whatever
        }
        
        if !taskData.timerEnabled {
            taskData.timerEnabled = true
            timerFiringFromTaskVC = true
            
            let stencil = #imageLiteral(resourceName: "Pause").withRenderingMode(.alwaysTemplate)
            cell.playStopButton.setImage(stencil, for: .normal)
            //cell.playStopButton.setTitle("Stop", for: .normal)
            
            //cell.playStopButton.tintColor = UIColor.white
            
            countdownTimer.startTime = Date().timeIntervalSince1970
            
            //countdownTimer.startTimer(for: cell)
            
            selectedCell = cell
            
            taskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                             selector: #selector(timerRunning), userInfo: nil,
                                             repeats: true)

            
        } else {
            taskData.timerEnabled = false
            timerFiringFromTaskVC = false
            
            cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //cell.playStopButton.setTitle("Start", for: .normal)
            
            //countdownTimer.stopTimer(for: cell)
            
                        taskTimer.invalidate()
            
                        if willResetTimer {
                            resetTaskTimers()
                        }
            
        }
        
//        if cell.playStopButton.currentTitle == "Start" {
//            timerEnabled = true
//            cell.playStopButton.setTitle("Stop", for: .normal)
//
//            taskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
//                                             selector: #selector(timerRunning), userInfo: cell, repeats: true)
//        
//        } else {
//            timerEnabled = false
//            cell.playStopButton.setTitle("Start", for: .normal)
//
//            taskTimer.invalidate()
//            
//            if willResetTimer {
//                resetTaskTimers()
//            }
//            
//            saveData()
//        }
        
    }
    
    func timerRunning() {
        
        //let cell = taskTimer.userInfo as! RepeatingTasksCollectionCell
        let cell = selectedCell!
        let taskName = cell.taskNameField.text!
        
        let (_, timeRemaining) = formatTimer(for: taskName, from: cell)
        
        print("Time remaining is \(timeRemaining)")
        
        taskData.setTask(as: taskName)
        
        taskData.taskDictionary[taskName]?["completedTime"]! += 1
        
        if timeRemaining == 0 || (taskData.completedTime == taskData.taskTime) {
            taskTimer.invalidate()
            
            //Task.instance.timer.isEnabled = false
            taskData.timerEnabled = false
            timerFiringFromTaskVC = false

            cell.taskTimeRemaining.text = "Complete"
            cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //cell.playStopButton.setTitle("Start", for: .normal)
            cell.playStopButton.isEnabled = false
            
            saveData()
            
        }
        
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
    
    func formatTimer(for task: String, from cell: RepeatingTasksCollectionCell? = nil) -> (String, Double) {
        // Used for initialization and when the task timer is updated
        
        taskData.setTask(as: task)
        
        let (taskTime, weightedTaskTime) = getWeightedTime(for: task)
        
        var completedTime = 0.0
        
        if runningCompletionTime == 0.0 {
            completedTime = taskData.completedTime
        } else if task == selectedTask {
            completedTime = runningCompletionTime
        }
        
        var remainingTaskTime = weightedTaskTime - completedTime
        
        if taskTimer.isValid {
            remainingTaskTime -= 1
        }
        
        print("Completed time is \(completedTime)")
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        var remainingTimeAsString = formatter.string(from: TimeInterval(remainingTaskTime))!
        
        if remainingTaskTime <= 0 {
            remainingTimeAsString = "Complete"
        }
        
        if (cell != nil) {
            
            let currentProgress = 1 - Float(remainingTaskTime)/Float(taskTime)
            
            cell!.progressView.setProgress(currentProgress, animated: true)
            
            print("Current progress is \(currentProgress)")
            
            cell!.taskTimeRemaining.text = remainingTimeAsString
            
        }
        
        return (remainingTimeAsString, remainingTaskTime)

    }
    
    func getWeightedTime(for task: String) -> (Double, Double) {
        
        let taskTime = taskData.taskTime
        let leftoverMultiplier = taskData.leftoverMultiplier
        let leftoverTime = taskData.leftoverTime
        
        return (taskTime, taskTime + (leftoverTime * leftoverMultiplier))
        
    }
    
    func catchNotification(notification:Notification) -> Void {
        print("Catch notification")
        
        taskTimer.invalidate()
        
    }
    func addTask() {
        print("Do stuff")
        performSegue(withIdentifier: "addTaskSegue", sender: nil)
    
    }
    
    @IBAction func newTaskCreatedUnwind(segue: UIStoryboardSegue) {
        
        print("Is this being run?")
        print(tasks)
        
        print(taskData.taskNameList)
        print(taskData.taskDictionary)
        print(taskData.taskStatsDictionary)
        
        saveData()
        
        DispatchQueue.main.async {
            self.taskList.reloadData()
        }
        
    }
    
    @IBAction func taskDeletedUnwind(segue: UIStoryboardSegue) {
        
        print("Baleted")
        print(tasks)
        
        //loadData()
        saveData()
        
        DispatchQueue.main.async {
            self.taskList.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "taskDetailSegue" {
            let taskVC = segue.destination as! TaskDetailViewController
            
            taskVC.appData = appData

            taskVC.taskData = taskData
            
            taskVC.task = taskData.taskName
            taskVC.taskTime = taskData.taskTime
            taskVC.completedTime = taskData.completedTime
            taskVC.taskDays = taskData.taskDays
            taskVC.taskFrequency = taskData.taskFrequency
            taskVC.leftoverTime = taskData.leftoverTime
            taskVC.leftoverMultiplier = taskData.leftoverMultiplier
            
            taskVC.countdownTimer = countdownTimer
            
        }
        
    }

    func loadData() {
        
        appData.load()
        taskData.load()
        
        tasks = taskData.taskNameList
        
    }
    
    func saveData() {
        
        appData.save()
        taskData.save()
        
        tasks = taskData.taskNameList
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if selectedTask != "" && runningCompletionTime > 0 {
            
            taskData.taskDictionary[selectedTask]!["competedTime"] = runningCompletionTime
            
        }

        DispatchQueue.main.async {
            self.taskList.reloadData()
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if taskData.timerEnabled && !timerFiringFromTaskVC {
            
            let currentTime = Date().timeIntervalSince1970
            let timeElapsed = currentTime - countdownTimer.startTime
            print("time elapsed \(timeElapsed)")
            
            let wholeNumbers = floor(timeElapsed)
            let milliseconds = Int((timeElapsed - wholeNumbers) * 1000)
            
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds)) {

                print("Wait until next second begins")
            
            }
            
            let indexPathRow = tasks.index(of: selectedTask)
            let indexPath = IndexPath(row: indexPathRow!, section: 0)
            selectedCell = taskList.cellForItem(at: indexPath) as? RepeatingTasksCollectionCell
            
            _ = formatTimer(for: selectedTask, from: selectedCell)

            let runningTaskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                                  selector: #selector(timerRunning), userInfo: nil,
                                                  repeats: true)
            
            
            
            
            
        }
        

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func secondsToHoursMinutesSeconds(from seconds: Int) -> (Int, Int, Int) {
        
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) & 60)
        
    }
    

}

