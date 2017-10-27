//
//  TaskStatsViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 9/11/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Charts
import Chameleon

class TaskStatsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var taskTimeHistory: LineChartView!
    @IBOutlet weak var missedTimeHistory: BarChartView!
    @IBOutlet weak var completedTimeHistory: BarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var taskTimeHistoryLabel: UILabel!
    @IBOutlet weak var missedTimeHistoryLabel: UILabel!
    @IBOutlet weak var completedTimeHistoryLabel: UILabel!
    @IBOutlet weak var statisticsTitleLabel: UILabel!
    @IBOutlet var statsNameLabels: [UILabel]!
    @IBOutlet var statsValueLabels: [UILabel]!
        
    //var taskHistory
    var statCharts: [UIView: String] {
        return [taskTimeHistory: "Task Time Line Chart", missedTimeHistory: "Missed Time Bar Chart", completedTimeHistory: "Completed Time Bar Chart"]
    }
    
    let nameLabels = ["Task Time", "Completed Task Time", "Missed Task Time", "Total Days", "Total Days (Complete)", "Total Days (Partial Complete", "Total Days (Missed)", "Current Streak", "Best Streak"]

    var valueLabels = ["0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0"]
    
    var task = Task()
    //var task = ""
    var accessDates = [String]()
    
    //var taskData = TaskData()
    var appData = AppData()

    var testData = [300, 300, 150, 200, 450, 600, 300, 600, 450, 480]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let darkerThemeColor = appData.appColor.darken(byPercentage: 0.25)
        view.backgroundColor = darkerThemeColor
        scrollView.backgroundColor = darkerThemeColor
        bgView.backgroundColor = darkerThemeColor
        navigationController?.toolbar.isHidden = true
        
        setLabelColor(for: taskTimeHistoryLabel)
        setLabelColor(for: missedTimeHistoryLabel)
        setLabelColor(for: completedTimeHistoryLabel)
        setLabelColor(for: statisticsTitleLabel)
        
        scrollView.delegate = self
        scrollView.contentSize.width = view.bounds.width
        scrollView.contentSize.height = CGFloat(1000)
        
        getAccessDates()
        
        setStatNameLabels()
        setStatValues()
        
        chartInit()
        
    }
    
    func getAccessDates() {

        //if let taskAccess = taskData.taskAccess {
        
        let taskDates = task.previousDates
        var dates = [String]()
        
            for x in 0..<taskDates.count {
                let date = taskDates[x]
                let formattedDate = task.set(date: date, as: "MM/dd")
                dates.append(formattedDate)
            }
            
        //}

    }
    
    func setLabelColor(for label: UILabel) {
        
        let darkerThemeColor = appData.appColor.darken(byPercentage: 0.25)
        if appData.darknessCheck(for: darkerThemeColor) {
            label.textColor = UIColor.white
        } else {
            label.textColor = UIColor.black
        }
        
    }
    
    func setStatNameLabels() {
        
        for label in statsNameLabels {
            
            let index = statsNameLabels.index(of: label)
            label.text = nameLabels[index!]
            setLabelColor(for: label)

        }
        
    }
    
    func setStatValues() {
        
        valueLabels[0] = String(task.totalTime) + " Seconds"
        valueLabels[1] = String(task.completedTime) + " Seconds"
        valueLabels[2] = String(task.missedTime) + " Seconds"
        valueLabels[3] = String(task.totalDays) + " Days"
        valueLabels[4] = String(task.fullDays) + " Days"
        valueLabels[5] = String(task.partialDays) + " Days"
        valueLabels[6] = String(task.missedDays) + " Days"
        valueLabels[7] = String(task.currentStreak) + " Days"
        valueLabels[8] = String(task.bestStreak) + " Days"

        for label in statsValueLabels {
            setLabelColor(for: label)
            let index = statsValueLabels.index(of: label)
            label.text = String(valueLabels[index!])
        }
        
//        var taskStats = [String: Double]()
//
//        if let statsCheck = taskData.taskStatsDictionary[task] {
//            taskStats = statsCheck
//        }
//
//        for label in statsValueLabels {
//
//            setLabelColor(for: label)
//
//            for (key, value) in taskStats {
//
//                switch key {
//                case TaskData.totalTaskTimeKey:
//                    valueLabels[0] = String(value) + " Seconds"
//                case TaskData.completedTaskTimeKey:
//                    valueLabels[1] = String(value) + " Seconds"
//                case TaskData.missedTaskTimeKey:
//                    valueLabels[2] = String(value) + " Seconds"
//                case TaskData.totalTaskDaysKey:
//                    valueLabels[3] = String(Int(value)) + " Days"
//                case TaskData.fullTaskDaysKey:
//                    valueLabels[4] = String(Int(value)) + " Days"
//                case TaskData.partialTaskDaysKey:
//                    valueLabels[5] = String(Int(value)) + " Days"
//                case TaskData.missedTaskDaysKey:
//                    valueLabels[6] = String(Int(value)) + " Days"
//                case TaskData.currentStreakKey:
//                    valueLabels[7] = String(value) + " Days"
//                case TaskData.bestStreakKey:
//                    valueLabels[8] = String(value) + " Days"
//                default:
//                    print("Error")
//                }
//
//                let index = statsValueLabels.index(of: label)
//                label.text = String(valueLabels[index!])
//
//            }
//
//        }
        
    }
    
    func setMissedChart() {
    
        missedTimeHistory.scaleYEnabled = false
        missedTimeHistory.scaleXEnabled = true
        missedTimeHistory.dragEnabled = true
        missedTimeHistory.setVisibleXRangeMaximum(5.0)
        missedTimeHistory.moveViewToX(5.0)
        missedTimeHistory.rightAxis.enabled = true
        missedTimeHistory.leftAxis.enabled = false
        
        missedTimeHistory.chartDescription?.enabled = false
        missedTimeHistory.legend.enabled = false
        missedTimeHistory.xAxis.labelPosition = .bottom

        let xAxis = missedTimeHistory.xAxis
        xAxis.granularity = 1.0
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: accessDates)
    
        let leftAxis = missedTimeHistory.getAxis(.left)
        let rightAxis = missedTimeHistory.getAxis(.right)
        
        leftAxis.drawLabelsEnabled = false
        rightAxis.drawLabelsEnabled = true
        
        leftAxis.axisMinimum = 0.0
        rightAxis.axisMinimum = 0.0
    
        let darkerThemeColor = appData.appColor.darken(byPercentage: 0.25)
        if appData.darknessCheck(for: darkerThemeColor) {
            xAxis.labelTextColor = UIColor.white
            rightAxis.labelTextColor = UIColor.white
        } else {
            xAxis.labelTextColor = UIColor.black
            rightAxis.labelTextColor = UIColor.black
        }
    
    }
    
    func setCompletedChart() {
        
        completedTimeHistory.scaleYEnabled = false
        completedTimeHistory.scaleXEnabled = true
        completedTimeHistory.dragEnabled = true
        completedTimeHistory.setVisibleXRangeMaximum(5.0)
        completedTimeHistory.moveViewToX(5.0)
        completedTimeHistory.rightAxis.enabled = true
        completedTimeHistory.leftAxis.enabled = false
        
        completedTimeHistory.chartDescription?.enabled = false
        completedTimeHistory.legend.enabled = false
        completedTimeHistory.xAxis.labelPosition = .bottom

        let xAxis = completedTimeHistory.xAxis
        xAxis.granularity = 1.0
        xAxis.drawGridLinesEnabled = false
        xAxis.centerAxisLabelsEnabled = false
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: accessDates)
        
        let leftAxis = completedTimeHistory.getAxis(.left)
        let rightAxis = completedTimeHistory.getAxis(.right)
        
        leftAxis.drawLabelsEnabled = false
        rightAxis.drawLabelsEnabled = true
        
        leftAxis.axisMinimum = 0.0
        rightAxis.axisMinimum = 0.0

        let darkerThemeColor = appData.appColor.darken(byPercentage: 0.25)
        if appData.darknessCheck(for: darkerThemeColor) {
            xAxis.labelTextColor = UIColor.white
            rightAxis.labelTextColor = UIColor.white
        } else {
            xAxis.labelTextColor = UIColor.black
            rightAxis.labelTextColor = UIColor.black
            completedTimeHistory.tintColor = UIColor.black
        }

    }
    
//    func setXAxis(for chartView: Any, as type: String) {
//        
//        var chart: AnyObject
//        
//        switch type {
//        case "Line":
//            chart = chartView as! LineChartView
//        case "Bar":
//            chart = chartView as! BarChartView
//        default:
//            return
//        }
//        
//        var xAxis = chart.xAxis
//        xAxis!.granularity = 1.0
//        xAxis!.drawGridLinesEnabled = false
//        xAxis!.centerAxisLabelsEnabled = false
//        
//        xAxis!.valueFormatter = IndexAxisValueFormatter(values: accessDates)
//        //xAxis?.valueFormatter = IndexAxisValueFormatter(values: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
//        
//    }
//    
//    func setYAxis(for chartView: Any, as type: String) {
//     
//        var chart: AnyObject
//
//        switch type {
//        case "Line":
//            chart = chartView as! LineChartView
//        case "Bar":
//            chart = chartView as! BarChartView
//        default:
//            return
//        }
//
//        let leftAxis = chart.getAxis(.left)
//        let rightAxis = chart.getAxis(.right)
//        
//        leftAxis.drawLabelsEnabled = false
//        rightAxis.drawLabelsEnabled = false
//        
//        leftAxis.axisMinimum = 0.0
//        rightAxis.axisMinimum = 0.0
//        
//    }

//    func setChartView(for chartView: Any, as type: String) {
//        
//        var chart: AnyObject
//        
//        switch type {
//        case "Line":
//            chart = chartView as! LineChartView
//        case "Bar":
//            chart = chartView as! BarChartView
//        default:
//            return
//        }
//
//        chart.chartDescription??.enabled = false
//        chart.legend.enabled = false
//        chart.xAxis.labelPosition = .bottom
//        //recentTaskHistory.drawValueAboveBarEnabled = false
//        //recentTaskHistory.borderLineWidth = 1.5
//        //recentTaskHistory.borderColor = UIColor.flatBlackDark
//        
//        chart.rightAxis.enabled = false
//        chart.leftAxis.enabled = false
//        //chart.drawGridBackgroundEnabled = false
//
//    }
    
    func chartInit() {
        
        setMissedChart()
        setCompletedChart()

        for (chart, type) in statCharts {
            
            //setXAxis(for: chart, as: type)
            //setYAxis(for: chart, as: type)
            //setChartView(for: chart, as: type)
            
            if type.contains("Line") {
                //loadLineChartData(chart: chart as! LineChartView, as: type)
            } else if type.contains("Bar") {
                loadBarChartData(chart: chart as! BarChartView, as: type)
            }
            
        }
 
        //xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Monday", "Wednesday", "Friday"])
        
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
        
    }
    
    func loadLineChartData(chart: LineChartView, as type: String) {
        
        var lineChartEntry = [LineChartDataSet]()
        
        
        
    }
    
    func loadBarChartData(chart: BarChartView, as type: String) {
        
        var barChartEntry  = [BarChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        var taskAccess = task.previousDates
        //var taskAccess: [Date]?
//        if let access = taskData.taskAccess {
//            taskAccess = access
//        }
        
        var dataSet = [Double]()
        
        for date in taskAccess {

            var entry = 0.0
            
            if type.contains("Missed") {
                entry = task.missedTimeHistory[date]!
                //entry = taskData.taskHistoryDictionary[task]![date]![TaskData.missedHistoryKey]!
            } else if type.contains("Complete") {
                entry = task.completedTimeHistory[date]!
                //entry = taskData.taskHistoryDictionary[task]![date]![TaskData.completedHistoryKey]!
            }
         
            dataSet.append(entry)
            
        }

        for i in 0..<dataSet.count {
        //for i in 0..<testData.count {
            var value: BarChartDataEntry
            
            value = BarChartDataEntry(x: Double(i), y: dataSet[i])
            //value = BarChartDataEntry(x: Double(i), y: Double(testData[i]))
            
            barChartEntry.append(value) // here we add it to the data set
            
        }
        
        let bar = BarChartDataSet(values: barChartEntry, label: "") //Here we convert lineChartEntry to a LineChartDataSet
        
        bar.colors = ChartColorTemplates.pastel()
        
        let darkerThemeColor = appData.appColor.darken(byPercentage: 0.25)
        if appData.darknessCheck(for: darkerThemeColor) {
            bar.valueColors = [UIColor.white]
        } else {
            bar.valueColors = [UIColor.black]
        }
        
        let data = BarChartData() //This is the object that will be added to the chart
        
        data.addDataSet(bar) //Adds the line to the dataSet
        
        if taskAccess.count == 1 {
            data.barWidth = 0.4
        }

        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        chart.data = data //finally - it adds the chart data to the chart and causes an update
        
        //        } else {
        //            recentTaskHistory.data = nil
        //        }
        
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
