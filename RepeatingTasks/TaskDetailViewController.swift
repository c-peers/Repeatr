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
import KVOController

class TaskDetailViewController: UIViewController {

    @IBOutlet weak var taskTimeLabel: UILabel!
    @IBOutlet weak var taskStartButton: UIButton!
    @IBOutlet weak var recentTaskHistory: BarChartView!
    
    var taskTimer = Timer()
    var timerEnabled = false
    
    var task = "*"
    var taskTime = 0.0
    var completedTime = 0.0
    var taskDays = [String]()
    var taskFrequency = 1.0
    var leftoverMultiplier = 100.0
    var leftoverTime = 0.0
    
    let taskHistory = [600, 0, 1200]
    
    var timeString: String = ""
    
    var taskData = TaskData()
    var appData = AppData()
    var countdownTimer = CountdownTimer()
    
    var startTime = Date()
    var endTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = task
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: #selector(trashTaskTapped))
        
        toolbarItems = [space, trashButton]
        
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

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        _ = formatTimer()
        
        self.addObserver(self, forKeyPath: #keyPath(taskData.completedTime), options: .new, context: nil)
        

        //(_, _) = countdownTimer.formatTimer(for: task, decrement: false)
        
        //let x = countdownTimer.remainingTime
        
        //taskTimeLabel.text = formatter.string(from: TimeInterval(countdownTimer.remainingTime))!

        if taskData.timerEnabled {

            taskStartButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            let stencil = #imageLiteral(resourceName: "Pause").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white


            //taskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
            //                                 selector: #selector(timerRunning), userInfo: nil,
            //                                 repeats: true)
            
        }

        
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
        rightAxis.drawLabelsEnabled = false
        
        leftAxis.axisMinimum = 0.0
        rightAxis.axisMinimum = 0.0
        
        xAxis.granularity = 1.0
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Monday", "Wednesday", "Friday"])
        
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

        
        updateCompletionChart()
        
    
    }
    
    func completedTimeCheck() {
        
        print("Completed time is \(taskData.completedTime)")
        
    }
    

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        //if keyPath == #keyPath(taskData.completedTime) {
            // Update Time Label
        _ = synchedTimer(for: change![NSKeyValueChangeKey.newKey] as! Double)
        //}
    }
    
    func synchedTimer(for completedTime: Double) -> String {
        
        let weightedTaskTime = taskTime + (leftoverTime * leftoverMultiplier)

        let remainingTaskTime = weightedTaskTime - completedTime
        
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
        
        let weightedTaskTime = taskTime + (leftoverTime * leftoverMultiplier)

        let remainingTaskTime = weightedTaskTime - taskData.completedTime
        
        print("Completed time is \(taskData.completedTime)")
        
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
        
        return (remainingTimeAsString, remainingTaskTime)
        
    }

    @IBAction func taskButtonTapped(_ sender: UIButton) {
        
        if taskData.timerEnabled != true {
            taskData.timerEnabled = true
            
            let stencil = #imageLiteral(resourceName: "Pause").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white
            
            //taskStartButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            
            countdownTimer.startTime = Date().timeIntervalSince1970
            
            taskTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                             selector: #selector(timerRunning), userInfo: nil, repeats: true)
            
        } else {
            taskData.timerEnabled = false
            
            let stencil = #imageLiteral(resourceName: "Play").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white
            //taskStartButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            
            NotificationCenter.default.post(name: Notification.Name("StopTimerNotification"), object: nil)
            
            taskTimer.invalidate()
            
//            if willResetTimer {
//                resetTaskTimers()
//            }
            
            saveData()
        }
        
    }
    
    func timerRunning() {
        
        let (_, timeRemaining) = formatTimer()
        
        print("Time remaining is \(timeRemaining)")
        
        taskData.completedTime += 1
        
        if timeRemaining == 0 || (completedTime == taskTime) {
            taskTimer.invalidate()
            
            let stencil = #imageLiteral(resourceName: "Play").withRenderingMode(.alwaysTemplate)
            taskStartButton.setImage(stencil, for: .normal)
            taskStartButton.tintColor = UIColor.white

            //taskStartButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            
        }
    }
    
    func updateCompletionChart() {
    
        var barChartEntry  = [BarChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
       
        //let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        //let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        //barChartView.data = chartData
        
        //here is the for loop
        for i in 0..<taskHistory.count {
            
            let value = BarChartDataEntry(x: Double(i), y: Double(taskHistory[i])) // here we set the X and Y status in a data chart entry
            
            barChartEntry.append(value) // here we add it to the data set
        }
        
        let bar = BarChartDataSet(values: barChartEntry, label: "") //Here we convert lineChartEntry to a LineChartDataSet
        
        bar.colors = ChartColorTemplates.pastel()
        
        let data = BarChartData() //This is the object that will be added to the chart
        
        data.addDataSet(bar) //Adds the line to the dataSet
        
        recentTaskHistory.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        recentTaskHistory.data = data //finally - it adds the chart data to the chart and causes an update
    
    }
    
    func trashTaskTapped() {
        
        performSegue(withIdentifier: "taskDeletedUnwindSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "taskDeletedUnwindSegue" {
            
            print(task)
            
            let vc = segue.destination as! TaskViewController
            vc.tasks = vc.tasks.filter { $0 != task }
            print(vc.tasks)
            
            vc.taskData.removeTask(name: task)
            
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
    
    deinit {
        self.removeObserver(self, forKeyPath: #keyPath(taskData.completedTime))
        taskTimer.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        taskTimer.invalidate()
        
        let vc = self.navigationController?.viewControllers.first as! TaskViewController
        
        //vc.taskData.taskDictionary[task]?["completedTime"] = completedTime
        vc.runningCompletionTime = taskData.completedTime
    }

    override func viewDidDisappear(_ animated: Bool) {
        
        taskTimer.invalidate()
        
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
