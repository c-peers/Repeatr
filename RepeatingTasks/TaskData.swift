//
//  TaskDataStruct.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 7/28/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class TaskData: NSObject, NSCoding {

    //MARK: - Properties
    
    // Basic task information
    var taskName = String()
    var taskTime = 0.0
    dynamic var completedTime = 0.0
    var taskDays = [String]()
    var taskFrequency = 1.0
    var rolloverMultiplier = 1.0
    var rolloverTime = 0.0
    
    // Task statistics
    var totalTaskTime = 0.0
    var missedTaskTime = 0.0
    var completedTaskTime = 0.0
    var totalTaskDays = 0.0
    var fullTaskDays = 0.0
    var partialTaskDays = 0.0
    var missedTaskDays = 0.0
    var currentStreak = 0.0
    var bestStreak = 0.0
    
    // Task history
    var taskTimeHistory = 0.0
    var missedTimeHistory = 0.0
    var completedTimeHistory = 0.0
    
    // Access
    var taskAccess: [Date]?

    var timerEnabled = false
    
    // Vars that holds all task data
    // Used for saving
    var taskNameList = [String]()
    var taskDictionary = [String : [String : Double]]()
    var taskStatsDictionary = [String : [String : Double]]()
    var taskHistoryDictionary = [String : [Date : [String : Double]]]()
    //var taskAccessDictionary = [String : [Date]]()

    // Dictionary Keys
    static let taskTimeKey = "taskTime"
    static let completedTimeKey = "completedTime"
    static let daysKey = "taskDays"
    static let frequencyKey = "taskFrequency"
    static let rolloverMultKey = "rolloverMultiplier"
    static let rolloverTimeKey = "rolloverTime"

    static let totalTaskTimeKey = "totalTaskTime"
    static let missedTaskTimeKey = "missedTaskTime"
    static let completedTaskTimeKey = "completedTaskTime"
    static let totalTaskDaysKey = "totalTaskDays"
    static let fullTaskDaysKey = "fullTaskDays"
    static let partialTaskDaysKey = "partialTaskDays"
    static let missedTaskDaysKey = "missedTaskDays"
    static let currentStreakKey = "currentStreak"
    static let bestStreakKey = "bestStreak"

    static let taskTimeHistoryKey = "taskTimeHistory"
    static let missedHistoryKey = "missedTimeHistory"
    static let completedHistoryKey = "completedTimeHistory"
    
    var taskNameIndex = 0
    
    //MARK: - Archiving Paths
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveTasksURL = documentsDirectory.appendingPathComponent("taskList")
    static let archiveTaskSettingsURL = documentsDirectory.appendingPathComponent("taskSettings")
    static let archiveTaskStatsURL = documentsDirectory.appendingPathComponent("taskStatistics")
    static let archiveTaskHistoryURL = documentsDirectory.appendingPathComponent("taskHistory")
    //static let archiveTaskAccessURL = documentsDirectory.appendingPathComponent("taskAccess")

    //MARK: - Save/Load functions

    func save() {
        
        let tasksSaveSuccessful = NSKeyedArchiver.archiveRootObject(taskNameList, toFile: TaskData.archiveTasksURL.path)
        let taskSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(taskDictionary, toFile: TaskData.archiveTaskSettingsURL.path)
        let taskStatsSaveSuccessful = NSKeyedArchiver.archiveRootObject(taskStatsDictionary, toFile: TaskData.archiveTaskStatsURL.path)
        let taskHistorySaveSuccessful = NSKeyedArchiver.archiveRootObject(taskHistoryDictionary, toFile: TaskData.archiveTaskHistoryURL.path)
        //let taskAccessSaveSuccessful = NSKeyedArchiver.archiveRootObject(taskAccessDictionary, toFile: TaskData.archiveTaskAccessURL.path)
        
        print("Saved task names: \(tasksSaveSuccessful)")
        print("Saved task settings: \(taskSettingsSaveSuccessful)")
        print("Saved task stats: \(taskStatsSaveSuccessful)")
        print("Saved task history: \(taskHistorySaveSuccessful)")
        //print("Saved task history: \(taskAccessSaveSuccessful)")
        
        print("Printing saved data")
        print("Tasks: \(taskNameList)")
        print(taskDictionary)
        //print(taskStatsDictionary)
        print(taskHistoryDictionary)
        
    }
    
    func load() {
        
        if let loadTasks = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTasksURL.path) as? [String] {
            taskNameList = loadTasks
        }
        
        if let loadTaskSettings = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTaskSettingsURL.path) as? [String : [String : Double]] {
            taskDictionary = loadTaskSettings
        }
        
        if let loadTaskStatistics = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTaskStatsURL.path) as? [String : [String : Double]] {
            taskStatsDictionary = loadTaskStatistics
        }
        
        if let loadTaskHistory = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTaskHistoryURL.path) as? [String : [Date : [String : Double]]] {
            taskHistoryDictionary = loadTaskHistory
        }
        
        //if let loadTaskAccess = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTaskAccessURL.path) as? [String : [Date]] {
            //taskAccessDictionary = loadTaskAccess
        //}

    }
    
    //MARK: - Task Functions

    func setTask(as taskName: String) {
        
        self.taskName = taskName
        
        if let index = taskNameList.index(of: taskName) {
            taskNameIndex = index
        }
        
        print("Task index is \(taskNameIndex)")
        
        if let currentTask = taskDictionary[taskName] {
            taskTime = currentTask[TaskData.taskTimeKey] ?? 3600.0
            completedTime = currentTask[TaskData.completedTimeKey] ?? 0.0
            let taskDaysAsBinary = currentTask[TaskData.daysKey] ?? 1111111.0
            taskFrequency = currentTask[TaskData.frequencyKey] ?? 1.0
            rolloverMultiplier = currentTask[TaskData.rolloverMultKey] ?? 1.0
            rolloverTime = currentTask[TaskData.rolloverTimeKey] ?? 0.0
            
            taskDays = taskDaysAsArray(from: taskDaysAsBinary)
            
            taskDictionary[taskName] = currentTask
            
        }
        
    }
    
    func clearTask() {
        
        taskTime = 0.0
        completedTime = 0.0
        taskFrequency = 0.0
        taskDays = []
        rolloverMultiplier = 1.0
        rolloverTime = 0.0
        
    }
    
    func dblToIntArray(for double: Double) -> [Int] {
        
        var taskDaysBinaryString = String(Int(double))
        //let taskDaysBinaryStringArray = taskDaysBinaryString.characters.flatMap{String($0)}
        
        
        var taskDaysBinaryArray = [Int]()
        for i in taskDaysBinaryString.characters {
            taskDaysBinaryArray.append(Int(String(i))!)
        }
        
        //var taskDaysBinaryArray = taskDaysBinaryStringArray.flatMap{Int($0)}
        
        while taskDaysBinaryArray.count != 7 {
            taskDaysBinaryArray.insert(0, at: 0)
        }
        
        print("taskDaysBinaryArray is of length \(taskDaysBinaryArray.count)")
        print(taskDaysBinaryArray)
        
        return taskDaysBinaryArray
        
    }
    
    func taskDaysAsArray(from taskDaysAsBinary: Double) -> [String] {
        
        let taskDaysBinaryArray = dblToIntArray(for: taskDaysAsBinary)
        
        var days = [String]()
        
        if taskDaysBinaryArray[0] == 1 {
            days.append("Sunday")
        }
        
        if taskDaysBinaryArray[1] == 1 {
            days.append("Monday")
        }
        
        if taskDaysBinaryArray[2] == 1 {
            days.append("Tuesday")
        }
        
        if taskDaysBinaryArray[3] == 1 {
            days.append("Wednesday")
        }
        
        if taskDaysBinaryArray[4] == 1 {
            days.append("Thursday")
        }
        
        if taskDaysBinaryArray[5] == 1 {
            days.append("Friday")
        }
        
        if taskDaysBinaryArray[6] == 1 {
            days.append("Saturday")
        }
        
        return days
        
    }
    
    func taskDaysAsBinary(from taskDaysArray: [String]) -> Double {
        
        var taskDays: Int = 0
        
        for x in 0...taskDaysArray.count - 1 {
            
            switch taskDaysArray[x] {
            case "Sunday":
                taskDays += 1000000
            case "Monday":
                taskDays += 100000
            case "Tuesday":
                taskDays += 10000
            case "Wednesday":
                taskDays += 1000
            case "Thursday":
                taskDays += 100
            case "Friday":
                taskDays += 10
            case "Saturday":
                taskDays += 1
            default:
                break
            }
            
        }
        
        return Double(taskDays)
        
    }
    
    //    func digits (in number: Int) -> Int {
    //
    //        var num = number
    //        var digitCount = 0
    //        while num > 1 {
    //            digitCount += 1
    //            num = num / 10
    //        }
    //
    //        return digitCount
    //
    //    }
    
    
    func newTask(name taskName: String, time taskTime: Double,
                 days taskDays: [String], frequency taskFrequency: Double) {
        self.taskName = taskName
        self.taskTime = taskTime
        self.taskDays = taskDays
        self.completedTime = 0.0
        self.rolloverTime = 0.0
        self.rolloverMultiplier = 1.0
        
        taskNameList.append(taskName)
        
        // Saving this array as "binary" so I don't have to handle multiple datatypes
        
        let taskDays = taskDaysAsBinary(from: taskDays)
        
        taskDictionary[taskName] = [TaskData.taskTimeKey: taskTime,
                                    TaskData.completedTimeKey: 0.0,
                                    TaskData.daysKey: taskDays,
                                    TaskData.frequencyKey: taskFrequency,
                                    TaskData.rolloverMultKey: 1.0,
                                    TaskData.rolloverTimeKey: 0.0]

        newStatsDictionaryEntry(name: taskName)
        
    }
    
    func changeTaskName(from previousName: String, to newName: String) {
        
        let index = taskNameList.index(of: previousName)
        taskNameList[index!] = newName
        
        taskDictionary[newName] = taskDictionary[previousName]
        taskStatsDictionary[newName] = taskStatsDictionary[previousName]
        taskHistoryDictionary[newName] = taskHistoryDictionary[previousName]
        
        removeTask(name: previousName)
        
    }
    
    func saveTask(_ task: String) {
        
        // Saving this array as "binary" so I don't have to handle multiple datatypes
        
        setTask(as: task)
        
        let taskDaysBinary = taskDaysAsBinary(from: taskDays)
        
        taskDictionary[task] = [TaskData.taskTimeKey: self.taskTime,
                                TaskData.completedTimeKey: self.completedTime,
                                TaskData.daysKey: taskDaysBinary,
                                TaskData.frequencyKey: self.taskFrequency,
                                TaskData.rolloverMultKey: self.rolloverMultiplier,
                                TaskData.rolloverTimeKey: self.rolloverTime]
        
    }

    func removeTask(name taskName: String) {
        
        taskNameList = taskNameList.filter { $0 != taskName }
        
        taskDictionary.removeValue(forKey: taskName)
        taskStatsDictionary.removeValue(forKey: taskName)
        taskHistoryDictionary.removeValue(forKey: taskName)
        
    }
    
    //MARK: - Statistics Functions

    func setTaskStatistics(as taskName: String) {
        
        if let currentTaskStatistics = taskStatsDictionary[taskName] {
            totalTaskTime = currentTaskStatistics[TaskData.totalTaskTimeKey]!
            missedTaskTime = currentTaskStatistics[TaskData.missedTaskTimeKey]!
            completedTaskTime = currentTaskStatistics[TaskData.completedTaskTimeKey]!
            totalTaskDays = currentTaskStatistics[TaskData.totalTaskDaysKey]!
            fullTaskDays = currentTaskStatistics[TaskData.fullTaskDaysKey]!
            partialTaskDays = currentTaskStatistics[TaskData.partialTaskDaysKey]!
            missedTaskDays = currentTaskStatistics[TaskData.missedTaskDaysKey]!
            currentStreak = currentTaskStatistics[TaskData.currentStreakKey]!
            bestStreak = currentTaskStatistics[TaskData.bestStreakKey]!
            
        }
        
    }
    
    func newStatsDictionaryEntry(name taskName: String) {
        
        taskStatsDictionary[taskName] = [TaskData.totalTaskTimeKey: 0.0,
                                         TaskData.missedTaskTimeKey: 0.0,
                                         TaskData.completedTaskTimeKey: 0.0,
                                         TaskData.totalTaskDaysKey: 0.0,
                                         TaskData.fullTaskDaysKey: 0.0,
                                         TaskData.partialTaskDaysKey: 0.0,
                                         TaskData.missedTaskDaysKey: 0.0,
                                         TaskData.currentStreakKey: 0.0,
                                         TaskData.bestStreakKey: 0.0 ]
        
    }
    
    func saveToStatsDictionary(name taskName: String, stats taskStats: [String: [String:Double]]) {
        taskStatsDictionary[taskName] = taskStats[taskName]
    }

    //MARK: - History Functions
    
    func newTaskHistory(for task: String, for date: Date) {
        
        setTask(as: task)
        
        taskTimeHistory = taskTime
        missedTimeHistory = 0
        completedTimeHistory = 0
        
        saveTaskHistory(for: task, at: date)
    }

    func setTaskHistory(as taskName: String, for date: Date) {
        
        if let currentTaskHistory = taskHistoryDictionary[taskName] {

            setTaskAccess(for: taskName)
            
            if let accessHistory = currentTaskHistory[date] {
            
                taskTimeHistory = accessHistory[TaskData.taskTimeHistoryKey]!
                missedTimeHistory = accessHistory[TaskData.missedHistoryKey]!
                completedTimeHistory = accessHistory[TaskData.completedHistoryKey]!

            }
        
        }
        
    }
    
    func setTaskAccess(for task: String) {
        
        if let currentTaskHistory = taskHistoryDictionary[task] {
            
            taskAccess = Array(currentTaskHistory.keys)
            
            //taskAccess.sort(){$0 < $1}
            let sortedArray = taskAccess!.sorted(by: {$0.timeIntervalSince1970 < $1.timeIntervalSince1970})
            taskAccess = sortedArray

        } else {
            taskAccess = nil
        }
        
    }
    
    func set(date: Date, as format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)

    }
    
    func saveTaskHistory(for taskName: String, at date: Date) {
        
        //var history = taskHistoryDictionary[taskName]![date]!
        
        let historyForDate = [TaskData.taskTimeHistoryKey: taskTimeHistory,
                              TaskData.missedHistoryKey: missedTimeHistory,
                              TaskData.completedHistoryKey: completedTimeHistory]
        
        if let _ = taskHistoryDictionary[taskName] {
            
            taskHistoryDictionary[taskName]![date] = historyForDate
            
        } else {
            
            taskHistoryDictionary[taskName] = [date : historyForDate]

        }
        
    }
    
    //MARK: - Access Functions
    
//    func addAccess(for taskName: String) {
//        
//        if let previous = taskAccessDictionary[taskName] {
//            
//            var newAccess = previous
//            newAccess.append(Date())
//            taskAccessDictionary[taskName] = newAccess
//            
//        } else {
//            
//            taskAccessDictionary[taskName] = [Date()]
//            
//        }
//        
//        
//    }
//    
//    func setAccess(for taskName: String) {
//        
//        taskAccess = taskAccessDictionary[taskName] ?? []
//        
//    }
    
    //MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskNameList, forKey: "taskNameList")
        aCoder.encode(taskDictionary, forKey: "taskDictionary")
        aCoder.encode(taskStatsDictionary, forKey: "taskStatsDictionary")
        aCoder.encode(taskHistoryDictionary, forKey: "taskHistoryDictionary")
        //aCoder.encode(taskAccessDictionary, forKey: "taskAccessDictionary")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let taskNameList = aDecoder.decodeObject(forKey: "taskNameList") as? [String] else {
            return nil
        }
        
        guard let taskDictionary = aDecoder.decodeObject(forKey: "taskDictionary") as? [String:[String:Double]] else {
            return nil
        }

        guard let taskStatsDictionary = aDecoder.decodeObject(forKey: "taskStatsDictionary") as? [String:[String:Double]] else {
            return nil
        }

        guard let taskHistoryDictionary = aDecoder.decodeObject(forKey: "taskHistoryDictionary") as? [String : [Date : [String : Double]]] else {
            return nil
        }
        
        //guard let taskAccessDictionary = aDecoder.decodeObject(forKey: "taskAccessDictionary") as? [String:[Date]] else {
        //    return nil
        //}
        
        // Must call designated initializer.
        self.init(name: taskNameList, taskSettings: taskDictionary,
                  statistics: taskStatsDictionary, history: taskHistoryDictionary)
        
    }
    
    //MARK: - Init

    init(name: [String], taskSettings: [String:[String:Double]], statistics: [String:[String:Double]], history: [String : [Date : [String : Double]]]) {
        
        self.taskNameList = name
        self.taskDictionary = taskSettings
        self.taskStatsDictionary = statistics
        self.taskHistoryDictionary = history
        //self.taskAccessDictionary = access
        self.taskAccess = []
        
    }
    
    override init() {
        super.init()
    }
    
}

