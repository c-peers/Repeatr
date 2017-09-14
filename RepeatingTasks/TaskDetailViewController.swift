//
//  TaskDetailViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/7/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon
import Charts

class TaskDetailViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var taskStartButton: UIButton!
    @IBOutlet weak var recentTaskHistory: BarChartView!
    
    //MARK: - Properties
    
    var timer = Timer()
    var timerEnabled = false
    
    var task = "*"
    var taskTime = 0.0
    var completedTime = 0.0
    var taskDays = [String]()
    var taskFrequency = 1.0
    var rolloverMultiplier = 1.0
    var rolloverTime = 0.0
    var weightedTime = 0.0
    
    var elapsedTime = 0.0
    
    //let taskHistory = [600, 0, 1200]
    
    var timeString: String = ""
    
    var dayOfWeekString = ""
    
    var taskData = TaskData()
    var appData = AppData()
    var taskTimer = CountdownTimer()
    
    var startTime = Date()
    var endTime = Date()
    
    //MARK: - View and Basic Functions
    
    override func viewWillAppear(_ animated: Bool) {
 
        self.title = task
        
        prepareNavBar()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButtonSetup()

        elapsedTime = completedTime
        
        taskChartSetup()
        
        if taskDayCheck(for: task) {
            _ = formatTimer()
            taskStartButton.isEnabled = true
        } else {
            taskTimeLabel.text = "No task today"
            taskStartButton.isEnabled = false
        }
        
        self.addObserver(self, forKeyPath: #keyPath(taskTimer.elapsedTime), options: .new, context: nil)
        

        //(_, _) = countdownTimer.formatTimer(for: task, decrement: false)
        
        //let x = countdownTimer.remainingTime
        
        //taskTimeLabel.text = formatter.string(from: TimeInterval(countdownTimer.remainingTime))!

        if taskTimer.isEnabled {

            taskStartButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            let stencil = #imageLiteral(resourceName: "Pause").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white

            //taskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
            //                                 selector: #selector(timerRunning), userInfo: nil,
            //                                 repeats: true)
            
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        timer.invalidate()
        
        let vc = self.navigationController?.viewControllers.first as! TaskViewController
        
        if taskTimer.isEnabled {
            
            //vc.taskData.taskDictionary[task]?["completedTime"] = completedTime
            vc.runningCompletionTime = taskData.completedTime
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        timer.invalidate()
        
    }

    deinit {
        self.removeObserver(self, forKeyPath: #keyPath(taskTimer.elapsedTime))
        timer.invalidate()
    }
    
    func prepareNavBar() {
        
        let settings = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(settingsTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let statsButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(statsTapped))
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
        
        toolbarItems = [settings, space, statsButton, space, trashButton]
        
        setTheme()
        
    }
    
    //MARK: - Timer Related Functions
    
    func taskDayCheck(for task: String) -> Bool {
        
        taskData.setTask(as: task)
        
        let now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        dayOfWeekString = dateFormatter.string(from: now)
        print("Today is \(dayOfWeekString)")
        
        return taskData.taskDays.contains(dayOfWeekString)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        //if keyPath == #keyPath(taskData.completedTime) {
            // Update Time Label
        //_ = synchedTimer(for: change![NSKeyValueChangeKey.newKey] as! Double)
        _ = formatTimer()
        
        //}
    }
    
    func synchedTimer(for completedTime: Double) -> String {
        
        let remainingTaskTime = weightedTime - completedTime
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        let remainingTimeAsString = formatter.string(from: TimeInterval(remainingTaskTime))!
        
        if remainingTaskTime != 0 {
            taskTimeLabel.text = remainingTimeAsString
            taskStartButton.isEnabled = true
        } else {
            taskTimeLabel.text = "Complete"
            taskStartButton.isEnabled = false
        }
        
        return remainingTimeAsString

    }
    
    func formatTimer() -> (String, Double) {
        // Used for initialization and when the task timer is updated
        
        //let (remainingTimeAsString, remainingTaskTime) = taskTimer.formatTimer(name: task, dataset: taskData)
        
        taskData.setTask(as: task)
        
        let currentTime = Date().timeIntervalSince1970

        elapsedTime = completedTime
        
        if taskTimer.isEnabled {
            elapsedTime += (currentTime - taskTimer.startTime)
        }
        
        let remainingTaskTime = weightedTime - elapsedTime
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        let remainingTimeAsString = formatter.string(from: TimeInterval(remainingTaskTime.rounded()))!
        
        if remainingTaskTime > 0 {
            taskTimeLabel.text = remainingTimeAsString
            taskStartButton.isEnabled = true

            // observeValue is called after view disappears.
            // If you don't check if view is visible then chart will cause a crash
            if self.isViewLoaded && self.view.isTopViewInWindow() {
                loadChartData(willUpdate: true)
            }

        } else {
            taskTimeLabel.text = "Complete"
            taskStartButton.isEnabled = false
        }
        
        return (remainingTimeAsString, remainingTaskTime)
        
    }
    
    func completedTimeCheck() {
        
        print("Completed time is \(taskData.completedTime)")
        
    }
    
    func timerRunning() {
        
        let (_, timeRemaining) = formatTimer()
        
        print("Time remaining is \(timeRemaining)")
        
        if timeRemaining <= 0 || (completedTime == weightedTime) {
            
            timerStopped(for: task)
            
            let stencil = #imageLiteral(resourceName: "Play").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white
            
            //taskStartButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            
        }
    }
    
    func timerStopped(for task: String) {
        
        taskTimer.run.invalidate()
        
        taskData.setTask(as: task)
        
        taskTimer.endTime = Date().timeIntervalSince1970
        
        var elapsedTime = taskTimer.endTime - taskTimer.startTime
        
        if elapsedTime > taskData.weightedTime {
            elapsedTime = taskData.weightedTime
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
        
        taskTimer.isEnabled = false
        taskTimer.firedFromMainVC = false
        
        saveData()
        
    }
    
    func setTheme() {
        
        if appData.isNightMode {
            //NightNight.theme = .night
        } else {
            //NightNight.theme = .normal
        }
        
        let navigationBar = navigationController?.navigationBar
        let bgColor = navigationBar?.barTintColor
        
        if appData.darknessCheck(for: bgColor) {
            
            navigationBar?.tintColor = UIColor.white
            navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            setStatusBarStyle(.lightContent)
            
        } else {
            
            navigationBar?.tintColor = UIColor.black
            navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
            setStatusBarStyle(.default)
        }
        
    }

    //MARK: - Button Related Functions
    
    func startButtonSetup() {
        
        taskStartButton.layer.cornerRadius = 10.0
        taskStartButton.layer.masksToBounds = true
        
        taskStartButton.layer.shadowColor = UIColor.lightGray.cgColor
        taskStartButton.layer.shadowOffset = CGSize.zero
        taskStartButton.layer.shadowRadius = 2.0
        taskStartButton.layer.shadowOpacity = 2.0
        taskStartButton.layer.shadowPath = UIBezierPath(roundedRect: taskStartButton.layer.bounds, cornerRadius: taskStartButton.layer.cornerRadius).cgPath
        
        //taskStartButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        let stencil = #imageLiteral(resourceName: "Play").withRenderingMode(.alwaysTemplate)
        taskStartButton.setImage(stencil, for: .normal)
        taskStartButton.tintColor = UIColor.white
        taskStartButton.backgroundColor = appData.appColor
        
    }
    
    @IBAction func taskButtonTapped(_ sender: UIButton) {
        
        if taskTimer.isEnabled != true {
            taskTimer.isEnabled = true
            
            let stencil = #imageLiteral(resourceName: "Pause").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white
            
            //taskStartButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            
            taskTimer.startTime = Date().timeIntervalSince1970
            
            taskTimer.run = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                             selector: #selector(timerRunning), userInfo: nil, repeats: true)
            
        } else {
            
            timerStopped(for: task)
            
            let stencil = #imageLiteral(resourceName: "Play").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white
            //taskStartButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            
            NotificationCenter.default.post(name: Notification.Name("StopTimerNotification"), object: nil)
            
            
            
//            if willResetTimer {
//                resetTaskTimers()
//            }
            
        }
        
    }
    
    func settingsTapped() {
        
        print("Go to Settings")
        performSegue(withIdentifier: "taskSettingsSegue", sender: self)
        
    }

    func statsTapped() {
        
        print("Go to Stats")
        performSegue(withIdentifier: "taskStatsSegue", sender: self)
        
    }

    func trashTapped() {
        
        print("Erase Task")
        popAlert()
    }
    
    func popAlert() {
        
        let alertController = UIAlertController(title: "Delete Task",
                                                message: "Are you sure you want to delete this?",
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            print("Hello")
            self.performSegue(withIdentifier: "taskDeletedUnwindSegue", sender: self)
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController,animated: true,completion: nil)
        
    }
    
    //MARK: - Chart Functions
    
    func findNewIndex(compare today: [Int], to dayArray: [Int]) -> Int {
        
        var arrayNewIndex: Int = 0
        let todayIndex = today.index(of: 1)
        
        for x in 0...today.count - 1 {
            
            if today[x] == dayArray[x] {
                arrayNewIndex = x
            }
        }
        
        if arrayNewIndex == 0 {
            
            for x in (0...todayIndex!).reversed() {
                
                if dayArray[x] == 1 {
                    arrayNewIndex = x
                    break
                }
                
            }
            
            for x in (todayIndex!...today.count - 1).reversed() {
                
                if dayArray[x] == 1 {
                    arrayNewIndex = x
                    break
                }
                
            }
            
        }
        

        return arrayNewIndex
        
    }
    
    func taskChartSetup() {
        
        recentTaskHistory.chartDescription?.enabled = false
        recentTaskHistory.legend.enabled = false
        recentTaskHistory.xAxis.labelPosition = .bottom
        //recentTaskHistory.drawValueAboveBarEnabled = false
        //recentTaskHistory.borderLineWidth = 1.5
        //recentTaskHistory.borderColor = UIColor.flatBlackDark
        
        recentTaskHistory.rightAxis.enabled = false
        recentTaskHistory.leftAxis.enabled = false
        recentTaskHistory.drawGridBackgroundEnabled = false
        
        
        
        let leftAxis = recentTaskHistory.getAxis(.left)
        let rightAxis = recentTaskHistory.getAxis(.right)
        let xAxis = recentTaskHistory.xAxis
        
        leftAxis.drawLabelsEnabled = false
        rightAxis.drawLabelsEnabled = true
        
        leftAxis.axisMinimum = 0.0
        rightAxis.axisMinimum = 0.0
        
        //rightAxis.axisMaximum = taskData.taskTime
        //leftAxis.axisMaximum = taskData.taskTime
        
        xAxis.granularity = 1.0
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        
        taskData.setTaskAccess(for: task)
        
        var recentAccess: [Date]?
        
        if let taskAccess = taskData.taskAccess {
            
            if taskAccess.count > 3 {
                recentAccess = Array(taskAccess.suffix(3))
            } else {
                recentAccess = taskAccess
            }

            var recentAccessStringArray: [String] = []
            
            for x in 0..<recentAccess!.count {
                
                let date = recentAccess![x]
                let formattedDate = taskData.set(date: date, as: "yyyy-MM-dd")
                recentAccessStringArray.append(formattedDate)
                
            }

            xAxis.valueFormatter = IndexAxisValueFormatter(values: recentAccessStringArray)
            
        }
        
        //xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Monday", "Wednesday", "Friday"])

        var axisMaximum = 0.0
        
        for date in recentAccess! {
            
            let nextValue = taskData.taskHistoryDictionary[task]![date]![TaskData.completedHistoryKey]
            
            if nextValue! > axisMaximum {
                axisMaximum = nextValue!
            }
            
        }
        
        leftAxis.axisMaximum = axisMaximum + 100.0
        rightAxis.axisMaximum = leftAxis.axisMaximum

        //        xAxis.
        //
        //        _chartView.delegate = self;
        //
        //        _chartView.extraTopOffset = -30.f;
        //        _chartView.extraBottomOffset = 10.f;
        //        _chartView.extraLeftOffset = 70.f;
        //        _chartView.extraRightOffset = 70.f;
        //
        //        _chartView.drawBarShadowEnabled = NO;
        //        _chartView.drawValueAboveBarEnabled = YES;
        //
        //        // scaling can now only be done on x- and y-axis separately
        //        _chartView.pinchZoomEnabled = NO;
        //
        //        xAxis.labelPosition = XAxisLabelPositionBottom;
        //        xAxis.labelFont = [UIFont systemFontOfSize:13.f];
        //        xAxis.labelTextColor = [UIColor lightGrayColor];
        //        xAxis.labelCount = 5;
        //        xAxis.valueFormatter = self;
        //
        //        ChartYAxis *leftAxis = _chartView.leftAxis;
        //        leftAxis.spaceTop = 0.25;
        //        leftAxis.spaceBottom = 0.25;
        //        leftAxis.drawAxisLineEnabled = NO;
        //        leftAxis.drawGridLinesEnabled = NO;
        //        leftAxis.drawZeroLineEnabled = YES;
        //        leftAxis.zeroLineColor = UIColor.grayColor;
        //        leftAxis.zeroLineWidth = 0.7f;
        
        
        loadChartData()
        
    }
    
    func loadChartData(willUpdate: Bool = false) {
        
        var barChartEntry  = [BarChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        //let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        //let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        //barChartView.data = chartData
        
        var taskAccess: [Date]?
        
        if let access = taskData.taskAccess {
            
            if access.count > 3 {
                taskAccess = Array(access.suffix(3))
            } else {
                taskAccess = access
            }

            var taskTimeHistory = [Double]()
            
            for date in taskAccess! {
                
                let completedTime = taskData.taskHistoryDictionary[task]![date]![TaskData.completedHistoryKey]
                taskTimeHistory.append(completedTime!)
                
            }
            
            for i in 0..<taskTimeHistory.count {
                
                var value: BarChartDataEntry
                if i != taskTimeHistory.count - 1 {
                    value = BarChartDataEntry(x: Double(i), y: taskTimeHistory[i]) // here we set the X and Y status in a data chart entry
                } else {
                    value = BarChartDataEntry(x: Double(i), y: elapsedTime)
                }
                barChartEntry.append(value) // here we add it to the data set
            }
            
            let bar = BarChartDataSet(values: barChartEntry, label: "") //Here we convert lineChartEntry to a LineChartDataSet
            
            bar.colors = ChartColorTemplates.pastel()
            
            let data = BarChartData() //This is the object that will be added to the chart
            
            data.addDataSet(bar) //Adds the line to the dataSet
            
            if !willUpdate {
                recentTaskHistory.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            }
            
            recentTaskHistory.data = data //finally - it adds the chart data to the chart and causes an update

        } else {
            recentTaskHistory.data = nil
        }
        
    }
    
    //MARK: - Data Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "taskDeletedUnwindSegue" {
            
            let vc = segue.destination as! TaskViewController
            vc.tasks = vc.tasks.filter { $0 != task }
            print(" Deleting \(vc.tasks)")
            
            vc.taskData.removeTask(name: task)
            
        } else if segue.identifier == "taskSettingsSegue" {
            
            let vc = segue.destination as! TaskSettingsViewController
            
            vc.task = task
            vc.taskTime = taskTime
            vc.taskDays = taskDays
            vc.occurranceRate = taskFrequency
            vc.rolloverMultiplier = rolloverMultiplier
            
            vc.taskData = taskData
            vc.appData = appData
            
        } else if segue.identifier == "taskStatsSegue" {
            
            let vc = segue.destination as! TaskStatsViewController
            
            vc.task = task
            
            vc.taskData = taskData
            vc.appData = appData
            
        }
        
    }
    
    func loadData() {
        
        appData.load()
        taskData.load()
        
    }
    
    func saveData() {
        
        appData.save()
        taskData.save()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
