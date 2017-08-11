//
//  TaskDataStruct.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 7/28/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class TaskData: NSObject, NSCoding {

    //MARK: - Object

    //MARK: - Coding
    
    // Basic task information
    var taskName = String()
    var taskTime = 0
    var completedTime = 0
    var taskDays = [String]()
    var taskFrequency = 1
    var leftoverMultiplier = 100
    var leftoverTime = 0
    
    var startTime = Date()
    var endTime = Date()
    
    // Task statistics
    var totalTaskTime = 0
    var missedTaskTime = 0
    var completedTaskTime = 0
    var totalTaskDays = 0
    var fullTaskDays = 0
    var partialTaskDays = 0
    var missedTaskDays = 0
    var currentStreak = 0
    var bestStreak = 0
    
    // Vars that holds all task data
    // Used for saving
    var taskNameList = [String]()
    var taskDictionary = [String : [String : Int]]()
    var taskStatsDictionary = [String : [String : Int]]()
    
    var taskNameIndex = 0
    
    //MARK: Archiving Paths
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveTasksURL = documentsDirectory.appendingPathComponent("taskList")
    static let archiveTaskSettingsURL = documentsDirectory.appendingPathComponent("taskSettings")
    static let archiveTaskStatsURL = documentsDirectory.appendingPathComponent("taskStatistics")

    func save() {
        let tasksSaveSuccessful = NSKeyedArchiver.archiveRootObject(taskNameList, toFile: TaskData.archiveTasksURL.path)
        let taskSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(taskDictionary, toFile: TaskData.archiveTaskSettingsURL.path)
        let taskStatsSaveSuccessful = NSKeyedArchiver.archiveRootObject(taskStatsDictionary, toFile: TaskData.archiveTaskStatsURL.path)
        
        print("Saved task names: \(tasksSaveSuccessful)")
        print("Saved task settings: \(taskSettingsSaveSuccessful)")
        print("Saved task stats: \(taskStatsSaveSuccessful)")
        
        print("Printing saved data")
        print("Tasks: \(taskNameList)")
        print(taskDictionary)
        print(taskStatsDictionary)
        
    }
    
    func load() {
        
        if let loadTasks = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTasksURL.path) as? [String] {
            taskNameList = loadTasks
        }
        
        if let loadTaskSettings = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTaskSettingsURL.path) as? [String : [String : Int]] {
            taskDictionary = loadTaskSettings
        }
        
        if let loadTaskStatistics = NSKeyedUnarchiver.unarchiveObject(withFile: TaskData.archiveTaskStatsURL.path) as? [String : [String : Int]] {
            taskStatsDictionary = loadTaskStatistics
        }
        
    }
    
    func setTask(as taskName: String) {
        
        self.taskName = taskName
        
        if let index = taskNameList.index(of: taskName) {
            taskNameIndex = index
        }
        
        print("Task index is \(taskNameIndex)")
        
        if let currentTask = taskDictionary[taskName] {
            taskTime = currentTask["taskTime"] ?? 3600
            completedTime = currentTask["completedTime"] ?? 0
            let taskDaysAsBinary = currentTask["taskDays"] ?? 1111111
            taskFrequency = currentTask["taskFrequency"] ?? 1
            leftoverMultiplier = currentTask["leftoverMultiplier"] ?? 1
            leftoverTime = currentTask["leftoverTime"] ?? 0
            
            taskDays = taskDaysAsArray(from: taskDaysAsBinary)
            
            taskDictionary[taskName] = currentTask
            
        }
        
    }
    
    func setTaskStatistics(as taskName: String) {
        
        if let currentTaskStatistics = taskStatsDictionary[taskName] {
            totalTaskTime = currentTaskStatistics["totalTaskTime"]!
            missedTaskTime = currentTaskStatistics["missedTaskTime"]!
            completedTaskTime = currentTaskStatistics["completedTaskTime"]!
            totalTaskDays = currentTaskStatistics["totalTaskDays"]!
            fullTaskDays = currentTaskStatistics["fullTaskDays"]!
            partialTaskDays = currentTaskStatistics["partialTaskDays"]!
            missedTaskDays = currentTaskStatistics["missedTaskDays"]!
            currentStreak = currentTaskStatistics["currentStreak"]!
            bestStreak = currentTaskStatistics["bestStreak"]!
            
        }
        
    }
    
    func taskDaysAsArray(from taskDaysAsBinary: Int) -> [String] {
        
        var taskDaysBinaryString = String(taskDaysAsBinary)
        var taskDaysBinaryArray = taskDaysBinaryString.characters.flatMap{Int(String($0))}
        
        while taskDaysBinaryArray.count != 7 {
            taskDaysBinaryArray.insert(0, at: 0)
        }
        
        print("taskDaysBinaryArray is of length \(taskDaysBinaryArray.count)")
        print(taskDaysBinaryArray)
        
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
    
    func taskDaysAsBinary(from taskDaysArray: [String]) -> Int {
        
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

        return taskDays
        
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

    
    func newTask(name taskName: String, time taskTime: Int,
                          days taskDays: [String], frequency taskFrequency: Int) {
        self.taskName = taskName
        self.taskTime = taskTime
        
        taskNameList.append(taskName)
        
        saveToDictionary(name: taskName, time: taskTime, days: taskDays, frequency: taskFrequency)
        newStatsDictionaryEntry(name: taskName)
        
    }
    
    func saveToDictionary(name taskName: String, time taskTime: Int,
                                       completed completedTime: Int = 0,
                                       days taskDaysArray: [String], frequency taskFrequency: Int) {
        
        // Saving this array as "binary" so I don't have to handle multiple datatypes
        
        let taskDays = taskDaysAsBinary(from: taskDaysArray)
        
        taskDictionary[taskName] = ["taskTime": taskTime,
                                        "completedTime": completedTime,
                                        "taskDays": taskDays,
                                        "taskFrequency": taskFrequency,
                                        "leftoverMultiplier": leftoverMultiplier,
                                        "leftoverTime": leftoverTime]
        
    }
    
    func newStatsDictionaryEntry(name taskName: String) {
        
        taskStatsDictionary[taskName] = ["totalTaskTime": 0,
                                    "missedTaskTime": 0,
                                    "completedTaskTime": 0,
                                    "totalTaskDays": 0,
                                    "fullTaskDays": 0,
                                    "partialTaskDays": 0,
                                    "missedTaskDays": 0,
                                    "currentStreak": 0,
                                    "bestStreak": 0 ]
        
    }
    
    func saveToStatsDictionary(name taskName: String, stats taskStats: [String: [String:Int]]) {
        taskStatsDictionary[taskName] = taskStats[taskName]
    }

    func removeTask(name taskName: String) {
        
        taskNameList = taskNameList.filter { $0 != taskName }
        
        taskDictionary.removeValue(forKey: taskName)
        taskStatsDictionary.removeValue(forKey: taskName)
        
    }
 
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskNameList, forKey: "taskNameList")
        aCoder.encode(taskDictionary, forKey: "taskDictionary")
        aCoder.encode(taskStatsDictionary, forKey: "taskStatsDictionary")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let taskNameList = aDecoder.decodeObject(forKey: "taskNameList") as? [String] else {
            return nil
        }
        
        guard let taskDictionary = aDecoder.decodeObject(forKey: "taskDictionary") as? [String:[String:Int]] else {
            return nil
        }

        guard let taskStatsDictionary = aDecoder.decodeObject(forKey: "taskStatsDictionary") as? [String:[String:Int]] else {
            return nil
        }

        // Must call designated initializer.
        self.init(name: taskNameList, taskSettings: taskDictionary, statistics: taskStatsDictionary)
        
    }
    
    init(name: [String], taskSettings: [String:[String:Int]], statistics: [String:[String:Int]]) {
        
        self.taskNameList = name
        self.taskDictionary = taskSettings
        self.taskStatsDictionary = statistics
        
    }
    
    override init() {
        super.init()
    }
    
}

