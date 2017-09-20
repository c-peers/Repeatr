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
    @IBOutlet weak var taskTimeHistoryLabel: UILabel!
    @IBOutlet weak var missedTimeHistoryLabel: UILabel!
    @IBOutlet weak var completedTimeHistoryLabel: UILabel!
    @IBOutlet var statsNameLabels: [UILabel]!
    @IBOutlet var statsValueLabels: [UILabel]!
    
    
    //var taskHistory
    var statCharts: [UIView: String] {
        return [taskTimeHistory: "Line", missedTimeHistory: "Bar", completedTimeHistory: "Bar"]
    }
    
    let nameLabels = ["Task Time", "Completed Task Time", "Missed Task Time", "Total Days", "Total Days (Complete)", "Total Days (Partial Complete", "Total Days (Missed)", "Current Streak", "Best Streak"]

    var valueLabels = ["0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0", "0.0"]
    
    var task = ""
    
    var taskData = TaskData()
    var appData = AppData()

    var testData = [300, 300, 150, 200, 450, 600, 300, 600, 450, 480]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.contentSize.width = view.bounds.width
        scrollView.contentSize.height = CGFloat(1000)
        
        setStatNameLabels()
        setStatValues()
        
        chartInit()
        
    }
    
    func setStatNameLabels() {
        
        for label in statsNameLabels {
            
            let index = statsNameLabels.index(of: label)
            label.text = nameLabels[index!]
            
        }
        
    }
    
    func setStatValues() {
        
        var taskStats = [String: Double]()
        
        if let statsCheck = taskData.taskStatsDictionary[task] {
            taskStats = statsCheck
        }
        
        for label in statsValueLabels {

            for (key, value) in taskStats {
            
                switch key {
                case TaskData.totalTaskTimeKey:
                    valueLabels[0] = String(value) + " Seconds"
                case TaskData.completedTaskTimeKey:
                    valueLabels[1] = String(value) + " Seconds"
                case TaskData.missedTaskTimeKey:
                    valueLabels[2] = String(value) + " Seconds"
                case TaskData.totalTaskDaysKey:
                    valueLabels[3] = String(Int(value)) + " Days"
                case TaskData.fullTaskDaysKey:
                    valueLabels[4] = String(Int(value)) + " Days"
                case TaskData.partialTaskDaysKey:
                    valueLabels[5] = String(Int(value)) + " Days"
                case TaskData.missedTaskDaysKey:
                    valueLabels[6] = String(Int(value)) + " Days"
                case TaskData.currentStreakKey:
                    valueLabels[7] = String(Int(value)) + " Days"
                case TaskData.bestStreakKey:
                    valueLabels[8] = String(Int(value)) + " Days"
                default:
                    print("Error")
                }
            
                let index = statsValueLabels.index(of: label)
                label.text = String(valueLabels[index!])
                
            }
            
        }
        
    }
    
    func setXAxis(for chartView: Any, as type: String) {
        
        var chart: AnyObject
        
        switch type {
        case "Line":
            chart = chartView as! LineChartView
        case "Bar":
            chart = chartView as! BarChartView
        default:
            return
        }
        
        var xAxis = chart.xAxis
        xAxis!.granularity = 1.0
        xAxis!.drawGridLinesEnabled = false
        xAxis!.centerAxisLabelsEnabled = false
        
        //taskData.setTaskAccess(for: task)
        
        //var recentAccess: [Date]?
        
//        if let taskAccess = taskData.taskAccess {
//            
//            if taskAccess.count > 3 {
//                recentAccess = Array(taskAccess.suffix(3))
//            } else {
//                recentAccess = taskAccess
//            }
//            
//            var recentAccessStringArray: [String] = []
//            
//            for x in 0..<recentAccess!.count {
//                
//                let date = recentAccess![x]
//                let formattedDate = taskData.set(date: date, as: "yyyy-MM-dd")
//                recentAccessStringArray.append(formattedDate)
//                
//            }
//            
//            xAxis!.valueFormatter = IndexAxisValueFormatter(values: recentAccessStringArray)
//            
//        }

        xAxis?.valueFormatter = IndexAxisValueFormatter(values: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
        
    }
    
    func setYAxis(for chartView: Any, as type: String) {
     
        var chart: AnyObject

        switch type {
        case "Line":
            chart = chartView as! LineChartView
        case "Bar":
            chart = chartView as! BarChartView
        default:
            return
        }

        let leftAxis = chart.getAxis(.left)
        let rightAxis = chart.getAxis(.right)
        
        leftAxis.drawLabelsEnabled = false
        rightAxis.drawLabelsEnabled = false
        
        leftAxis.axisMinimum = 0.0
        rightAxis.axisMinimum = 0.0
        
        
        
    }

    func setChartView(for chartView: Any, as type: String) {
        
        var chart: AnyObject
        
        switch type {
        case "Line":
            chart = chartView as! LineChartView
        case "Bar":
            chart = chartView as! BarChartView
        default:
            return
        }

        chart.chartDescription??.enabled = false
        chart.legend.enabled = false
        chart.xAxis.labelPosition = .bottom
        //recentTaskHistory.drawValueAboveBarEnabled = false
        //recentTaskHistory.borderLineWidth = 1.5
        //recentTaskHistory.borderColor = UIColor.flatBlackDark
        
        missedTimeHistory.scaleYEnabled = false
        missedTimeHistory.scaleXEnabled = true
        missedTimeHistory.dragEnabled = true
        missedTimeHistory.setVisibleXRangeMaximum(5.0)
        missedTimeHistory.moveViewToX(5.0)

        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        //chart.drawGridBackgroundEnabled = false

    }
    
    func chartInit() {
        
        for (chart, type) in statCharts {
            
            setXAxis(for: chart, as: type)
            setYAxis(for: chart, as: type)
            setChartView(for: chart, as: type)
            
            if type == "Line" {
                //loadLineChartData(chart: chart as! LineChartView)
            } else if type == "Bar" {
                loadBarChartData(chart: chart as! BarChartView)
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
    
    func loadLineChartData() {
        
        var lineChartEntry = [LineChartDataSet]()
        
        
        
    }
    
    func loadBarChartData(chart: BarChartView) {
        
        var barChartEntry  = [BarChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
                
//        var taskAccess: [Date]?
//        
//        if let access = taskData.taskAccess {
//            
//            if access.count > 3 {
//                taskAccess = Array(access.suffix(3))
//            } else {
//                taskAccess = access
//            }
//            
//            var taskTimeHistory = [Double]()
//            
//            for date in taskAccess! {
//                
//                let completedTime = taskData.taskHistoryDictionary[task]![date]![TaskData.completedHistoryKey]
//                taskTimeHistory.append(completedTime!)
//                
//            }
//            
//            for i in 0..<taskTimeHistory.count {
        for i in 0..<testData.count {
                var value: BarChartDataEntry
                //if i != taskTimeHistory.count - 1 {
                //    value = BarChartDataEntry(x: Double(i), y: taskTimeHistory[i]) // here we set the X and Y status in a data chart entry
                //} else {
                //    value = BarChartDataEntry(x: Double(i), y: elapsedTime)
                //}
                value = BarChartDataEntry(x: Double(i), y: Double(testData[i]))
                barChartEntry.append(value) // here we add it to the data set
            
            }
            
            let bar = BarChartDataSet(values: barChartEntry, label: "") //Here we convert lineChartEntry to a LineChartDataSet
            
            bar.colors = ChartColorTemplates.pastel()
            
            let data = BarChartData() //This is the object that will be added to the chart
            
            data.addDataSet(bar) //Adds the line to the dataSet
            
            //if !willUpdate {
                chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            //}
            
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
