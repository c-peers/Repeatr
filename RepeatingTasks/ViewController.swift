//
//  ViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 6/13/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation
import UIKit
import Chameleon
import GoogleMobileAds
import Presentr

enum CellType {
    case circular
    case line
}

class TaskViewController: UIViewController, GADBannerViewDelegate {

    //MARK: - Outlets
    
    @IBOutlet weak var taskList: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    //MARK: - Properties
    
    var tasks = [String]()
    
    @objc dynamic var taskData = TaskData()
    var appData = AppData()
    var taskTimer = CountdownTimer()
    
    //var taskTimer = Timer() performSegue(withIdentifier: "taskDeletedUnwindSegue", sender: self)
    
    
    //var timerEnabled = false
    var timerFiringFromTaskVC = false
    
    var selectedTask = ""
    var selectedCell: TaskCollectionViewCell?
    var runningCompletionTime = 0.0
    
    var willResetTimer = false
    var currentDay = Date()
    var yesterday = Date()
    var lastUsed = Date()
    
    var nextResetTime = Date()
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-3446210370651273/5359231299"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    let addPresenter: Presentr = {
        let width = ModalSize.fluid(percentage: 0.8)
        let height = ModalSize.fluid(percentage: 0.8)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        //let customPresenter = Presentr(presentationType: .popup)
        
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.cornerRadius = 10.0
        customPresenter.backgroundColor = UIColor.lightGray
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = false
        customPresenter.blurBackground = true
        customPresenter.blurStyle = .regular
        customPresenter.keyboardTranslationType = .moveUp
        
        let opacity: Float = 0.5
        let offset = CGSize(width: 2.0, height: 2.0)
        let radius = CGFloat(3.0)
        let shadow = PresentrShadow(shadowColor: .black, shadowOpacity: opacity, shadowOffset: offset, shadowRadius: radius)
        customPresenter.dropShadow = shadow
        
        return customPresenter
    }()

    //MARK: - View and Basic Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load any saved data
        loadData()
        
        print("loaded Values")
        print(tasks)
        
        appData.taskCurrentTime = Date()
        
        NotificationCenter.default.addObserver(forName: Notification.Name("StopTimerNotification"), object: nil, queue: nil, using: catchNotification)
        
        prepareNavBar()
        
        bannerView.adUnitID = "ca-app-pub-3446210370651273/5359231299"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
        
        // Check current time
        // Determine the time interval between now and when the timers will reset
        // Set a timer to go off at that time
        
        timeCheck()
        
    }
    
    func setCellSize(forType type: CellType) {
        
        let cellSize: CGSize
        
        if type == .line {
            cellSize = CGSize(width:333 , height:106)
        } else {
            cellSize = CGSize(width:170 , height:220)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        taskList.setCollectionViewLayout(layout, animated: true)
        
        //taskList.reloadData()

    }
    
    func prepareNavBar() {
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        navigationItem.rightBarButtonItems = [addBarButton]
        
        let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        toolbarItems = [settingsButton]
        navigationController?.isToolbarHidden = false
        
        setTheme()
        
    }
    
    func setTheme() {
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = appData.appColor
        //navigationBar?.mixedBarStyle = MixedBarStyle(normal: .default, night: .blackTranslucent)
        
        let toolbar = navigationController?.toolbar
        toolbar?.barTintColor = appData.appColor
        
        let darkerThemeColor = appData.appColor.darken(byPercentage: 0.25)
        
        view.backgroundColor = darkerThemeColor
        taskList.backgroundView?.backgroundColor = darkerThemeColor
        
        if appData.isNightMode {
            //NightNight.theme = .night
        } else {
            //NightNight.theme = .normal
        }
        
        let bgColor = navigationController?.navigationBar.barTintColor
        
        if appData.darknessCheck(for: bgColor) {
            
            navigationBar?.tintColor = UIColor.white
            toolbar?.tintColor = UIColor.white
            setStatusBarStyle(.lightContent)
           
        } else {
            
            navigationBar?.tintColor = UIColor.black
            toolbar?.tintColor = UIColor.black
            setStatusBarStyle(.default)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        appData.setColorScheme()
        
        setTheme()
        
        // Circular progress cells were using the incorrect cell size, reason unknown.
        // This forces the cells to use the correct size
//        if appData.usesCircularProgress {
//            setCellSize(forType: .circular)
//        } else {
//            setCellSize(forType: .line)
//        }
        
        if selectedTask != "" && runningCompletionTime > 0 {
            
            taskData.taskDictionary[selectedTask]![TaskData.completedTimeKey] = runningCompletionTime
            
        }
        
        DispatchQueue.main.async {
            self.taskList.collectionViewLayout.invalidateLayout()
            self.taskList.reloadData()
        }
        
        taskList.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if taskTimer.isEnabled && !taskTimer.firedFromMainVC {
            
            let currentTime = Date().timeIntervalSince1970
            let timeElapsed = currentTime - taskTimer.startTime
            print("time elapsed \(timeElapsed)")
            
            let wholeNumbers = floor(timeElapsed)
            let milliseconds = Int((timeElapsed - wholeNumbers) * 1000)
            
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds)) {
                
                print("Wait until next second begins")
                
            }
            
            let indexPathRow = tasks.index(of: selectedTask)
            let indexPath = IndexPath(row: indexPathRow!, section: 0)
            selectedCell = taskList.cellForItem(at: indexPath) as? TaskCollectionViewCell
            
            //_ = formatTimer(for: selectedTask, from: selectedCell)
            _ = taskTimer.formatTimer(name: selectedTask, from: selectedCell, dataset: taskData)
            
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(timerRunning), userInfo: nil,
                                     repeats: true)
            
        }
        
    }
    
    /*
     Checks if last time accessed is the same day or not.
     If it is the same day then do nothing. 
     Otherwise create history dicionary with today's date.
    */
    
    func accessCheck(for task: String) {
        
        taskData.setTask(as: task)
        taskData.setTaskAccess(for: task)
        
        let offsetString = appData.resetOffset

        if let previousAccess = taskData.taskAccess?.last {
            
            // Both give day of week as an int. Check if values match
            let previousAccessDay = getDay(for: previousAccess, with: offsetString)
            let currentAccessDay = getDay(for:currentDay, with: offsetString)
            
            if previousAccessDay != currentAccessDay {
                taskData.newTaskHistory(for: task, for: currentDay)
            }
            
        } else {
            taskData.newTaskHistory(for: task, for: currentDay)
        }
        
        
        saveData()
    
    }

    func getDay(for date: Date, with offset: String) -> Int {
        
        var resetOffset = DateComponents()
        resetOffset.hour = -offsetAsInt(for: offset)
        
        let date = Calendar.current.date(byAdding: resetOffset, to: date)
        let offsetDay = Calendar.current.component(.weekday, from: date!)

        return offsetDay
        
    }

    func offsetAsInt(for offset: String) -> Int {
        
        let offsetTime = offset.components(separatedBy: ":")[0]
        var offset = Int(offsetTime)
        if offset == 12 {
            offset = 0
        }
        return offset!
        
    }
    
    func offsetDates() {
        
        let offsetString = appData.resetOffset

        let lastUsed = appData.taskLastTime

        appData.taskLastTime = offsetDate(lastUsed, by: offsetString)
        
        
        
    }
    
    func offsetDate(_ date: Date, by offset: String) -> Date {
        
        let offsetInt = offsetAsInt(for: offset)
        let offsetDate = Calendar.current.date(byAdding: .hour, value: -offsetInt, to: date)
        
        return offsetDate!
        
    }
    
    @objc func settingsButtonTapped() {
        performSegue(withIdentifier: "appSettingsSegue", sender: self)
        
        //let appSettingsVC = AppSettingsViewController()
        //present(appSettingsVC, animated: true, completion: nil)
        //appSettingsVC.appData = appData
        //self.navigationController!.pushViewController(appSettingsVC, animated: true)
        
    }
    
    //MARK: - Timer Related Functions
    
    func taskDayCheck(for task: String, at date: Date) -> Bool {
        
        taskData.setTask(as: task)
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        let dayOfWeekString = dateFormatter.string(from: date)
        print("Today is \(dayOfWeekString)")
        
        return taskData.taskDays.contains(dayOfWeekString)
        
    }
    
//    func taskWeekCheck(for task: String, at date: Date) -> Bool {
//
//        taskData.setTask(as: task)
//
//        let dateFormatter = DateFormatter()
//        let calendar = Calendar.current
//        let currentWeekOfYear = calendar.component(.weekOfYear, from: currentDay)
//        let
//
//
//    }
    
    func getHistory(for task: String, at date: Date) -> Date? {
        
        taskData.setTaskAccess(for: task)
        
        let accessDateCandidate = taskData.set(date: date, as: "yyyy-MM-dd")
        
        if let accessDates = taskData.taskAccess {

            for date in accessDates {
                
                let formattedDate = taskData.set(date: date, as: "yyyy-MM-dd")
                if accessDateCandidate == formattedDate {
                    return date
                }

            }
            
        }
        
        return nil
        
    }
    
    func checkForMissedDays(in task: String) {
        
        taskData.setTaskAccess(for: task)
        
        var date = getHistory(for: task, at: lastUsed)
        
        let daysBetween = calculateDaysBetweenTwoDates(start: lastUsed, end: currentDay)
        
        if daysBetween < 1 {
            return
        }
        
        // Run through all the days in between
        // the previous run and today
        for day in 0..<daysBetween {
        
            // day 0 is the last time the app was ran
            // so we need to use the correct time in the dictionary
            if day == 0 && date != nil {
                let taskTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.taskTimeHistoryKey]
                let completedTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.completedHistoryKey]
                let unfinishedTime = taskTime! - completedTime!

                if unfinishedTime >= 0 {
                    taskData.taskHistoryDictionary[task]![date!]![TaskData.missedHistoryKey]! = unfinishedTime
                } else {
                    taskData.taskHistoryDictionary[task]![date!]![TaskData.missedHistoryKey]! = 0.0
                }

            } else {
                
                date = Calendar.current.date(byAdding: .day, value: day, to: lastUsed)
                
                let dateExistsInDict = taskData.taskHistoryDictionary[task]?[date!]
                
                if taskDayCheck(for: task, at: date!) && dateExistsInDict == nil {
                    
                    taskData.newTaskHistory(for: task, for: date!)
                    
                }
                
                let taskTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.taskTimeHistoryKey]
                let completedTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.completedHistoryKey]
                
                if (taskTime != nil) && (completedTime != nil) {
                    taskData.taskHistoryDictionary[task]![date!]![TaskData.missedHistoryKey] = taskTime! - completedTime!
                }
            }
            
            
        }
        
    }
    
    func calculateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    func timeCheck() {
        
        let now = offsetDate(appData.taskCurrentTime, by: appData.resetOffset)
        let then = offsetDate(appData.taskLastTime, by: appData.resetOffset)

        currentDay = now
        lastUsed = then
        
        let calendar = Calendar.current
        
        var currentTime = getDateComponents(for: now)
        var lastAppTime = getDateComponents(for: then)
        
        
        var reset = DateComponents()
        reset.year = currentTime.year
        reset.month = currentTime.month
        reset.hour = offsetAsInt(for: appData.resetOffset)
        reset.minute = 0
        //reset.minute = calendar.component(.minute, from: appData.taskResetTime)
        
        if (lastAppTime.year != currentTime.year) || (lastAppTime.month != currentTime.month) {
            reset.day = currentTime.day
        } else if lastAppTime.day != currentTime.day {
            reset.day = currentTime.day
        } else {
            reset.day = currentTime.day! + 1
        }
        
        nextResetTime = calendar.date(from: reset)!
        let lastResetTime = calendar.date(byAdding: .day, value: -1, to: nextResetTime)
        
        let resetOccurred = resetTimePassed(between: then, and: now, with: lastResetTime!)
        
        if resetOccurred {
            
            if !taskTimer.isEnabled {
                resetTaskTimers()
            } else {
                willResetTimer = true
            }
            
        } else {
            
            let timeToReset = calculateTimeToReset(at: nextResetTime)
            
            let resetDate = Date().addingTimeInterval(timeToReset)
            let resetTimer = Timer(fireAt: resetDate, interval: 0, target: self, selector: #selector(resetTaskTimers), userInfo: nil, repeats: false)
            RunLoop.main.add(resetTimer, forMode: RunLoopMode.commonModes)
            
            for task in tasks {
                taskData.setTask(as: task)
                let (remainingTimeString,_) = taskTimer.formatTimer(name: task, dataset: taskData)
                taskTimer.setMissedTimeNotification(for: task, at: timeToReset, withRemaining: remainingTimeString)
            }
            
        }
        
        appData.taskLastTime = appData.taskCurrentTime
        appData.save()
        
    }
    
    func calculateTimeToReset(at resetTime: Date) -> TimeInterval {
        let calendar = Calendar.current
        let differenceComponents = calendar.dateComponents([.hour, .minute, .second], from: Date(), to: resetTime)
        let timeDifference = TimeInterval((differenceComponents.hour! * 3600) + (differenceComponents.minute! * 60) + differenceComponents.second!)
        return timeDifference
    }
    
    func resetTimePassed(between then: Date, and now: Date, with reset: Date) -> Bool {
        
        if reset > then && reset < now {
            return true
        } else {
            return false
        }
        
    }
    
    func getDateComponents(for date: Date) -> DateComponents {
        
        let calendar = Calendar.current
        var time = DateComponents()
        time.year = calendar.component(.year, from: date)
        time.month = calendar.component(.month, from: date)
        time.day = calendar.component(.day, from: date)
        time.hour = calendar.component(.hour, from: date)
        time.minute = calendar.component(.minute, from: date)
        time.second = calendar.component(.second, from: date)
        
        return time

    }
    
    func calculateStats(for task: String) {
        
        taskData.setTask(as: task)
        
        var taskStats = [String: Double]()
        
        if let statsCheck = taskData.taskStatsDictionary[task] {
            taskStats = statsCheck
        }
        
        taskStats[TaskData.totalTaskDaysKey]! += 1.0
        taskStats[TaskData.totalTaskTimeKey]! += taskData.taskTime
        taskStats[TaskData.completedTaskTimeKey]! += taskData.completedTime
        
        if taskData.completedTime == taskData.weightedTime { // Full
            
            taskStats[TaskData.fullTaskDaysKey]! += 1
            taskStats[TaskData.currentStreakKey]! += 1
            
            if taskStats[TaskData.currentStreakKey]! > taskStats[TaskData.bestStreakKey]! {
                taskStats[TaskData.bestStreakKey]! = taskStats[TaskData.currentStreakKey]!
            }
            
            
        } else if taskData.completedTime > 0 { // Partial
        
            taskStats[TaskData.partialTaskDaysKey]! += 1
            
            if taskStats[TaskData.currentStreakKey]! > 0 {
                taskStats[TaskData.currentStreakKey] = 0
            }
            
        } else { // Missed
            
            taskStats[TaskData.missedTaskDaysKey]! += 1.0
            taskStats[TaskData.missedTaskTimeKey]! += taskData.taskTime
            
            if taskStats[TaskData.currentStreakKey]! > 0 {
                taskStats[TaskData.currentStreakKey] = 0
            }

        }
        
        taskData.saveToStatsDictionary(name: task, stats: taskStats)
        
    }
    
    @objc func resetTaskTimers() {
        print("RESET!!!!!!!!")
        
        // Iterate through all tasks and do the following
        // 1. Reset completed time
        // 2. Calculate rollover time
        // 3. Refresh screen
        
        if tasks.count < 1 {
            return
        }
        
        //for x in 0...(tasks.count - 1) {
        for task in tasks {
            //let task = tasks[x]
            
            taskData.setTask(as: task)
            
            let daysBetween = calculateDaysBetweenTwoDates(start: self.lastUsed, end: self.currentDay)

            for _ in 0..<daysBetween {
                self.calculateStats(for: task)
            }
            
            let (_, weightedTaskTime) = taskTimer.getWeightedTime(for: task)

            let completedTime = taskData.completedTime
            taskData.taskDictionary[task]?[TaskData.completedTimeKey] = 0

            if let date = Calendar.current.date(byAdding: .day, value: -1, to: yesterday) {
                yesterday = date
            }
            
            if taskDayCheck(for: task, at: yesterday) {
                
                var rolloverTime = weightedTaskTime - completedTime
                
                if rolloverTime < 0 {
                    rolloverTime = 0
                }
                
                //taskData.taskDictionary[task]![TaskData.rolloverTimeKey] = rolloverTime
            
            }
            
            checkForMissedDays(in: task)
            
            //=====================================
            
            taskData.setTaskAccess(for: task)
            
            let lastUsedDate = getHistory(for: task, at: lastUsed)
            
            if taskDayCheck(for: task, at: currentDay), let lastIndex = taskData.taskAccess?.index(of: lastUsedDate!) {

                let accessArrayLength = (taskData.taskAccess?.count)! - 1
                var rollover = 0.0
                
                for index in lastIndex...accessArrayLength {
                    
                    let date = taskData.taskAccess![index]
                    rollover += taskData.taskHistoryDictionary[task]![date]![TaskData.missedHistoryKey]!
                    
                }
                
                taskData.taskDictionary[task]![TaskData.rolloverTimeKey]! += rollover
                
//                if let previousAccess = getAccessDate(for: task, lengthFromEnd: 1) {
//                    
//                    let time = taskData.taskDictionary[task]!["completedTaskTimeHistory"]
//                    let completion = taskData.taskHistoryDictionary[task]![previousAccess]!["completedTaskTimeHistory"]
//                    
//                    taskData.taskHistoryDictionary[task]![date]!["totalTaskTimeHistory"] = time
//                    taskData.taskHistoryDictionary[task]![date]!["missedTaskTimeHistory"] = time! - completion!
//                    taskData.taskHistoryDictionary[task]![date]!["completedTaskTimeHistory"] = completionf
//                    
//                }
                

            }
            
        }
        
        DispatchQueue.main.async {
            self.taskList.reloadData()
        }

        saveData()
        
    }

    //@IBAction func taskStartStopButtonPressed(_ sender: UIButton) {
    @objc func taskStartStopButtonPressed(sender: UIButton) {
        guard let cell = sender.superview?.superview as? TaskCollectionViewCell else {
            return // or fatalError() or whatever
        }
        
        let id = cell.reuseIdentifier
        
        if !taskTimer.isEnabled {
            
            taskTimer.isEnabled = true
            taskTimer.firedFromMainVC = true

            //taskData.timerEnabled = true
            //timerFiringFromTaskVC = true
            
            //if id == "taskCollectionCell_Line" {
                //let stencil = #imageLiteral(resourceName: "Pause").withRenderingMode(.alwaysTemplate)
                cell.playStopButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                //cell.playStopButton.tintColor = UIColor.white
            //} else {
            //    cell.circleProgressPlayStopButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            //
            //}
            
            let taskName = cell.taskNameField.text!
            let (_, weightedTime) = taskTimer.getWeightedTime(for: taskName)
            let elapsedTime = taskData.completedTime
            let remainingTime = weightedTime - elapsedTime

            if id == "taskCollectionCell_Circle" {
                
                let currentProgress = 1 - remainingTime/weightedTime
                let currentAngle = currentProgress * 360
                
                cell.circleProgressView.animate(fromAngle: currentAngle, toAngle: 359.9, duration: remainingTime as TimeInterval, relativeDuration: true, completion: nil)
            }
            
            taskTimer.startTime = Date().timeIntervalSince1970
            
            selectedCell = cell
            
            taskTimer.setFinishedNotification(for: cell.taskNameField.text!, atTime: remainingTime)
            taskTimer.run = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                             selector: #selector(timerRunning), userInfo: nil,
                                             repeats: true)

            
        } else {
            
            //if id == "taskCollectionCell_Line" {
                cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //} else {
            //    cell.circleProgressPlayStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //}
            
            if id == "taskCollectionCell_Circle" {
                timerStopped(for: cell.taskNameField.text!, ofType: .circular)
            } else {
                timerStopped(for: cell.taskNameField.text!, ofType: .line)
            }
            
            let task = cell.taskNameField.text!
            taskTimer.cancelFinishedNotification(for: task)
            
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
    
    func calculateProgress(for cell: TaskCollectionViewCell, ofType type: CellType) {
        
        let taskName = cell.taskNameField.text!

        // Why do I have to do this here???
        // Doesn't work from other classes when using .xib
        let (_, weightedTaskTime) = taskTimer.getWeightedTime(for: taskName)
        var elapsedTime = taskData.completedTime
        if taskTimer.isEnabled {
            elapsedTime += (taskTimer.currentTime - taskTimer.startTime)
        }
        let remainingTaskTime = weightedTaskTime - elapsedTime
        
        if type == .line {
            let currentProgress = 1 - Float(remainingTaskTime)/Float(weightedTaskTime)
            cell.progressView.setProgress(currentProgress, animated: true)
        } else {
            let currentProgress = 1 - remainingTaskTime/weightedTaskTime
            cell.circleProgressView.progress = currentProgress
        }
        
    }
    
    @objc func timerRunning() {
        
        //let cell = taskTimer.userInfo as! RepeatingTasksCollectionCell
        let cell = selectedCell!
        let taskName = cell.taskNameField.text!
        let id = cell.reuseIdentifier
        
        let (_, timeRemaining) = taskTimer.formatTimer(name: taskName, from: cell, dataset: taskData)
        print("Time remaining is \(timeRemaining)")

        if id == "taskCollectionCell_Line" {
            calculateProgress(for: cell, ofType: .line)
        }
        
        if timeRemaining <= 0 {
            
            if id == "taskCollectionCell_Line" {
                timerStopped(for: taskName, ofType: .line)
            } else {
                timerStopped(for: taskName, ofType: .circular)
            }
            
            cell.taskTimeRemaining.text = "Complete"
            
            //if id == "taskCollectionCell_Line" {
                cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
                cell.playStopButton.isEnabled = false
            //} else {
            //    cell.circleProgressPlayStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //    cell.circleProgressPlayStopButton.isEnabled = false
            //}
            
            taskTimer.cancelMissedTimeNotification(for: taskName)

        }
        
        //let taskTime = currentTask["taskTime"] ?? 0
        
        //var (hours, minutes, seconds) = secondsToHoursMinutesSeconds(from: remainingTaskTime)
        
        //let completionPercentage = Int(((Float(taskTime) - Float(timeRemaining))/Float(taskTime)) * 100)
        //progressLabel.text = "\(completionPercentage)% done"
        //manageTimerEnd(seconds: timeRemaining)
        
    }
    
//    func setMissedTime(for task: String, at date: Date) {
//        
//        var elapsedTime = taskTimer.endTime - taskTimer.startTime
//        //let previousCompletedTime = taskData.taskDictionary[task]?["completedTime"]!
//        
//        if elapsedTime > taskData.weightedTime {
//            elapsedTime = taskData.weightedTime
//        }
//
//        let unfinishedTime = taskData.taskTime - elapsedTime
//        
//        if unfinishedTime >= 0 {
//            taskData.taskHistoryDictionary[task]![date]![TaskData.missedHistoryKey]! = unfinishedTime
//        } else {
//            taskData.taskHistoryDictionary[task]![date]![TaskData.missedHistoryKey]! = 0.0
//        }
//
//    }
    
    func timerStopped(for task: String, ofType type: CellType) {
        
        taskTimer.run.invalidate()
        
        taskData.setTask(as: task)
        
        taskTimer.endTime = Date().timeIntervalSince1970
        
        var elapsedTime = taskTimer.endTime - taskTimer.startTime
        //let previousCompletedTime = taskData.taskDictionary[task]?["completedTime"]!
        
        if elapsedTime > taskData.weightedTime {
            elapsedTime = taskData.weightedTime
        }
        
        if type == .circular {
            selectedCell?.circleProgressView.pauseAnimation()
        }
        
        taskData.taskDictionary[task]![TaskData.completedTimeKey]! += elapsedTime

        if let date = taskData.getAccessDate(for: task, lengthFromEnd: 0) {
            taskData.taskHistoryDictionary[task]![date]![TaskData.completedHistoryKey]! += elapsedTime
            
            let unfinishedTime = taskData.taskTime - elapsedTime
            
            if unfinishedTime >= 0 {
                taskData.taskHistoryDictionary[task]![date]![TaskData.missedHistoryKey]! = unfinishedTime
            } else {
                taskData.taskHistoryDictionary[task]![date]![TaskData.missedHistoryKey]! = 0.0
            }
            //setMissedTime(for: task, at: date)

        }
        
        let resetTime = calculateTimeToReset(at: nextResetTime)
        let (remainingTimeString,_) = taskTimer.formatTimer(name: task, dataset: taskData)
        taskTimer.setMissedTimeNotification(for: task, at: resetTime, withRemaining: remainingTimeString)

        //Task.instance.timer.isEnabled = false
        //taskData.timerEnabled = false
        //timerFiringFromTaskVC = false
        taskTimer.isEnabled = false
        taskTimer.firedFromMainVC = false

        saveData()
        
    }
    
//    func formatTimer(for task: String, from cell: RepeatingTasksCollectionCell? = nil) -> (String, Double) {
//        // Used for initialization and when the task timer is updated
//        
//        taskData.setTask(as: task)
//        
//        let (taskTime, weightedTaskTime) = getWeightedTime(for: task)
//        
//        var completedTime = 0.0
//        
//        if runningCompletionTime == 0.0 {
//            completedTime = taskData.completedTime
//        } else if task == selectedTask {
//            completedTime = runningCompletionTime
//        }
//        
//        var remainingTaskTime = weightedTaskTime - completedTime
//        
//        if taskTimer.run.isValid {
//            remainingTaskTime -= 1
//        }
//        
//        print("Completed time is \(completedTime)")
//        
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .positional
//        
//        var remainingTimeAsString = formatter.string(from: TimeInterval(remainingTaskTime))!
//        
//        if remainingTaskTime <= 0 {
//            remainingTimeAsString = "Complete"
//        }
//        
//        if (cell != nil) {
//            
//            let currentProgress = 1 - Float(remainingTaskTime)/Float(taskTime)
//            
//            cell!.progressView.setProgress(currentProgress, animated: true)
//            
//            print("Current progress is \(currentProgress)")
//            
//            cell!.taskTimeRemaining.text = remainingTimeAsString
//            
//        }
//        
//        return (remainingTimeAsString, remainingTaskTime)
//
//    }
//    
//    func getWeightedTime(for task: String) -> (Double, Double) {
//        
//        let taskTime = taskData.taskTime
//        let rolloverMultiplier = taskData.rolloverMultiplier
//        let rolloverTime = taskData.rolloverTime
//        
//        return (taskTime, taskTime + (rolloverTime * rolloverMultiplier))
//        
//    }
    
    func secondsToHoursMinutesSeconds(from seconds: Int) -> (Int, Int, Int) {
        
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) & 60)
        
    }

    func catchNotification(notification:Notification) -> Void {
        print("Catch notification")
        
        taskTimer.run.invalidate()
        
    }

    //MARK: - Button Functions
    
    @objc func addTask() {
        print("Do stuff")
        //performSegue(withIdentifier: "addTaskSegue", sender: nil)
        
        presentNewTaskVC()
        //test()
    }
    
    func test() {
        
        let newTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "test")
        
        customPresentViewController(addPresenter, viewController: newTaskViewController!, animated: true, completion: nil)
    }
    
   //MARK: - Data Handling
    
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
            taskVC.rolloverTime = taskData.rolloverTime
            taskVC.rolloverMultiplier = taskData.rolloverMultiplier
            taskVC.weightedTime = taskData.weightedTime
            
            taskVC.taskTimer = taskTimer
            
        } else if segue.identifier == "addTaskSegue" {
            let newTaskVC = segue.destination as! NewTasksViewController
            
            newTaskVC.appData = appData
            
        } else if segue.identifier == "appSettingsSegue" {
            let appSettingsVC = segue.destination as! AppSettingsViewController
            
            appSettingsVC.appData = appData
            taskTimer.run.invalidate()
            
        }
        
    }
    
    func loadData() {
        
        //appData.load()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appData = appDelegate.appData
        
        print("Appdata color is \(appData.appColor)")
        
        taskData.load()
        
        tasks = taskData.taskNameList
        
    }
    
    func saveData() {
        
        appData.save()
        taskData.save()
        
        tasks = taskData.taskNameList
        
    }
    
    //MARK: - Ads
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {

        print("Banner loaded successfully")
        
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
    //func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("Fail to receive ads")
    }
    
    //MARK: - Navigation
    
    @IBAction func newTaskCreatedUnwind(segue: UIStoryboardSegue) {
        
        print(tasks)
        
        print(taskData.taskNameList)
        print(taskData.taskDictionary)
        print(taskData.taskStatsDictionary)
        print(taskData.taskHistoryDictionary)
        
        saveData()
        
        DispatchQueue.main.async {
            self.taskList.reloadData()
        }
        
    }
    
    @IBAction func taskDeletedUnwind(segue: UIStoryboardSegue) {
        
        print("Baleted")
        print(tasks)
        
        taskData.clearTask()
        
        //loadData()
        saveData()
        
        DispatchQueue.main.async {
            self.taskList.reloadData()
        }
        
    }
    
    func preparePresenter(ofHeight height: Float, ofWidth width: Float) {
        let width = ModalSize.fluid(percentage: width)
        let height = ModalSize.fluid(percentage: height)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        addPresenter.presentationType = customType
        
    }
    
    func presentNewTaskVC() {
        let newTaskViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewTaskVC") as! NewTasksViewController
        newTaskViewController.appData = appData
        newTaskViewController.tasks = tasks

        switch appData.deviceType {
        case .legacy:
            preparePresenter(ofHeight: 0.8, ofWidth: 0.9)
        case .normal:
            preparePresenter(ofHeight: 0.8, ofWidth: 0.8)
        case .large:
            preparePresenter(ofHeight: 0.7, ofWidth: 0.8)
        case .X:
            preparePresenter(ofHeight: 0.7, ofWidth: 0.8)
        }

        customPresentViewController(addPresenter, viewController: newTaskViewController, animated: true, completion: nil)
    }
    
}

//MARK: - Collection View Delegate

extension TaskViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /* UICollectionViewDelegateFlowLayout functions added because the collection cells
       were not automatically resizing. Since the values in IB are ignored they are hardcoded
       the code below.
     */
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = view.bounds.width
        
        let cellSize: CGSize
        
        if appData.usesCircularProgress {
            cellSize = CGSize(width:170 , height:220) // w:170 h:220
        } else {
            cellSize = CGSize(width:screenWidth - 32 , height:106) // w:333 h:106
        }

        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func setupCollectionCell(for cell: TaskCollectionViewCell, ofType type: CellType, at indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        
        cell.taskNameField.text = task
        
        //(_, _) = taskTimer.formatTimer(name: task, from: cell, dataset: taskData)
        (_, _) = taskTimer.formatTimer(name: task, from: cell, ofType: type, dataset: taskData)

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        //cell.taskTimeRemaining.text = formatter.string(from: TimeInterval(Task.instance.timer.remainingTime))!
        //cell.taskTimeRemaining.text = formatter.string(from: TimeInterval(countdownTimer.remainingTime))!
        
        //if type == .line {
            cell.playStopButton.backgroundColor = UIColor.clear
            cell.playStopButton.addTarget(self, action: #selector(taskStartStopButtonPressed(sender:)), for: .touchUpInside)
            if cell.taskTimeRemaining.text == "Complete" {
                cell.playStopButton.isEnabled = false
            } else {
                cell.playStopButton.isEnabled = true
            }
//        } else {
//            cell.circleProgressPlayStopButton.backgroundColor = UIColor.clear
//            cell.circleProgressPlayStopButton.addTarget(self, action: #selector(taskStartStopButtonPressed(sender:)), for: .touchUpInside)
//            if cell.taskTimeRemaining.text == "Complete" {
//                cell.circleProgressPlayStopButton.isEnabled = false
//            } else {
//                cell.circleProgressPlayStopButton.isEnabled = true
//            }
//        }
        
        if taskTimer.isEnabled && task == selectedTask {
            //if type == .line {
                cell.playStopButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            //} else {
            //    cell.circleProgressPlayStopButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            //}
        } else {
            //if type == .line {
                cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //} else {
            //    cell.circleProgressPlayStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            //}
        }
        
        //let gradientBackground = GradientColor(.leftToRight, frame: cell.frame, colors: [UIColor.flatSkyBlue, UIColor.flatSkyBlueDark])
        
        //cell.backgroundColor = gradientBackground
        
        let cellBGColor = appData.colorScheme[indexPath.row % 4]
        cell.backgroundColor = cellBGColor
        
        if appData.darknessCheck(for: cellBGColor) {
            cell.taskNameField.textColor = .white
            cell.taskTimeRemaining.textColor = .white
        } else {
            cell.taskNameField.textColor = .black
            cell.taskTimeRemaining.textColor = .black
        }
        
        let borderColor = cellBGColor.darken(byPercentage: 0.3)?.cgColor
        
        //        cell.layer.borderColor = borderColor
        //        cell.layer.cornerRadius = 10.0
        //        cell.layer.borderWidth = 2.5
        cell.layer.masksToBounds = false
        setBorder(for: cell.layer, borderWidth: 2.5, borderColor: borderColor!, radius: 10.0)
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)// CGSize.zero
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.layer.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
        
        if type == .line {
            
            cell.progressView.barHeight = 6.0
            //cell.progressView.transform = cell.progressView.transform.scaledBy(x: 1.0, y: 2.0)
            //        cell.progressView.layer.borderWidth = 0.2
            //        cell.progressView.layer.borderColor = borderColor
            //        cell.progressView.layer.cornerRadius = 5.0
            setBorder(for: cell.progressView.layer, borderWidth: 0.2, borderColor: borderColor!, radius: 5.0)
            calculateProgress(for: cell, ofType: .line)
            //cell.progressView.progress = 0.0
            //cell.progressView.setProgress(0.0, animated: false)
            //cell.progressView.progressTintColor = UIColor.darkGray
            cell.progressView.clipsToBounds = true
            
            cell.progressView.isHidden = false
            //cell.circleProgressView.isHidden = true

        } else if type == .circular {
            
            //setBorder(for: cell.circleProgressView.layer, borderWidth: 0.2, borderColor: borderColor!, radius: 5.0)
            let iOSDefaultBlue = UIButton(type: UIButtonType.system).titleColor(for: .normal)!
            cell.circleProgressView.trackColor = .darkGray
            cell.circleProgressView.progressColors = [iOSDefaultBlue]
            cell.circleProgressView.progress = 0.0
            calculateProgress(for: cell, ofType: .circular)
            
            //cell.progressView.isHidden = true
            cell.circleProgressView.isHidden = false

        }
        
        if taskDayCheck(for: task, at: currentDay) {
            //cell.progressView.isHidden = false
            cell.playStopButton.isHidden = false
            accessCheck(for: task)
        } else {
            cell.playStopButton.isHidden = true
            cell.taskTimeRemaining.text = "No task today"
            //cell.progressView.isHidden = true
        }

    }
    
    func setupCollectionCellWithCircularProgress(for cell: RepeatingTasksCircleProgressCollectionCell, at indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        
        if taskTimer.isEnabled && task == selectedTask {
            cell.playStopButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        } else {
            cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        }
        
        cell.playStopButton.backgroundColor = UIColor.clear
        
        cell.taskNameField.text = task
        
        //(_, _) = taskTimer.formatTimer(name: task, from: cell, ofType: .circle, dataset: taskData)
        
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
        
        //let colorArray = ColorSchemeOf(.analogous, color: .flatSkyBlue, isFlatScheme: true)
        
        print(indexPath)
        
        //let gradientBackground = GradientColor(.leftToRight, frame: cell.frame, colors: [UIColor.flatSkyBlue, UIColor.flatSkyBlueDark])
        
        //cell.backgroundColor = gradientBackground
        
        let cellBGColor = appData.colorScheme[indexPath.row % 4]
        cell.backgroundColor = cellBGColor
        
        if appData.darknessCheck(for: cellBGColor) {
            cell.taskNameField.textColor = .white
            cell.taskTimeRemaining.textColor = .white
        } else {
            cell.taskNameField.textColor = .black
            cell.taskTimeRemaining.textColor = .black
        }
        
        let borderColor = cellBGColor.darken(byPercentage: 0.3)?.cgColor
        
        //        cell.layer.borderColor = borderColor
        //        cell.layer.cornerRadius = 10.0
        //        cell.layer.borderWidth = 2.5
        cell.layer.masksToBounds = false
        setBorder(for: cell.layer, borderWidth: 2.5, borderColor: borderColor!, radius: 10.0)
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)// CGSize.zero
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.layer.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
        
        setBorder(for: cell.circularProgressView.layer, borderWidth: 0.2, borderColor: borderColor!, radius: 5.0)

        cell.circularProgressView.trackColor = .gray
        cell.circularProgressView.progressColors = [.blue]
        cell.circularProgressView.progress = 0.0
        
        if taskDayCheck(for: task, at: currentDay) {
            cell.playStopButton.isHidden = false
            cell.circularProgressView.isHidden = false
            accessCheck(for: task)
        } else {
            cell.playStopButton.isHidden = true
            cell.taskTimeRemaining.text = "No task today"
            cell.circularProgressView.isHidden = true
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var reuseIdentifier: String?
        let usesCircularProgress = appData.usesCircularProgress
        
        
        if usesCircularProgress {
            reuseIdentifier = "taskCollectionCell_Circle"

            let nib: UINib = UINib(nibName: "TaskCircleProgressCollectionViewCell", bundle: nil)
            
            taskList.register(nib, forCellWithReuseIdentifier: reuseIdentifier!)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath) as! TaskCollectionViewCell
            //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath as IndexPath) as! RepeatingTasksCircleProgressCollectionCell

            //setupCollectionCellWithCircularProgress(for: cell, at: indexPath)
            setupCollectionCell(for: cell, ofType: .circular, at: indexPath)

            collectionView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)

            return cell
            
        } else {
            reuseIdentifier = "taskCollectionCell_Line"

            let nib: UINib = UINib(nibName: "TaskCollectionViewCell", bundle: nil)
            
            taskList.register(nib, forCellWithReuseIdentifier: reuseIdentifier!)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath as IndexPath) as! TaskCollectionViewCell
            
            setupCollectionCell(for: cell, ofType: .line, at: indexPath)
            
            return cell
            
        }
        
    }
    
    func setBorder(for layer: CALayer, borderWidth: CGFloat, borderColor: CGColor, radius: CGFloat ) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor
        layer.cornerRadius = radius
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        
        taskData.setTask(as: task)
        
        selectedTask = taskData.taskName
        
        print("taskData taskName \(taskData.taskName)")
        
        performSegue(withIdentifier: "taskDetailSegue", sender: self)
        
    }
    
}

extension UIProgressView {
    
    @IBInspectable var barHeight : CGFloat {
        get {
            return transform.d * 2.0
        }
        set {
            // 2.0 Refers to the default height of 2
            let heightScale = newValue / 2.0
            let c = center
            transform = CGAffineTransform(scaleX: 1, y: heightScale)
            center = c
        }
    }
}

