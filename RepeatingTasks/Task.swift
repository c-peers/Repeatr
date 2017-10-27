//
//  Task.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 10/26/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class Task: NSObject, NSCoding {
    
    //MARK: - Properties
    
    // Basic task information
    var name = String()
    var time = 0.0
    var days = [String]()
    var multiplier = 1.0
    var rollover = 0.0
    var weightedTime = 0.0
    var frequency = 0.0
    
    // Completed is dynamic so that timers on the main and detail page are synched up
    @objc dynamic var completed = 0.0
    
    var currentWeek = 0
    var nextOccurringWeek = 0
    
    // Cumulative statistics
    var totalTime = 0.0
    var missedTime = 0.0
    var completedTime = 0.0
    var totalDays = 0
    var fullDays = 0
    var partialDays = 0
    var missedDays = 0
    var currentStreak = 0
    var bestStreak = 0
    
    // History
    var taskTimeHistory = [Date: Double]()
    var missedTimeHistory = [Date: Double]()
    var completedTimeHistory = [Date: Double]()
    
    // List of dates the task was/should've run
    //var previousDates: [Date]//?
    var previousDates: [Date] {
            let dates = Array(taskTimeHistory.keys)
            let sortedArray = dates.sorted(by: {$0.timeIntervalSince1970 < $1.timeIntervalSince1970})
            return sortedArray
    }
    
    //MARK: - Keys
    static let nameKey = "nameKey"
    static let timeKey = "timeKey"
    static let daysKey = "daysKey"
    static let multiplierKey = "multiplierKey"
    static let rolloverKey = "rolloverKey"
    static let frequencyKey = "frequencyKey"
    static let completedKey = "completedKey"
    static let currentWeekKey = "currentWeekKey"
    
    // Cumulative statistics
    static let totalTimeKey = "totalTimeKey"
    static let missedTimeKey = "missedTimeKey"
    static let completedTimeKey = "completedTimeKey"
    static let totalDaysKey = "totalDaysKey"
    static let fullDaysKey = "fullDaysKey"
    static let partialDaysKey = "partialDaysKey"
    static let missedDaysKey = "missedDaysKey"
    static let currentStreakKey = "currentStreakKey"
    static let bestStreakKey = "bestStreakKey"

    // History
    static let taskTimeHistoryKey = "taskTimeHistoryKey"
    static let missedTimeHistoryKey = "missedTimeHistoryKey"
    static let completedTimeHistoryKey = "completedTimeHistoryKey"
    static let previousDatesKey = "previousDatesKey"

    
    //MARK: - Archiving Paths
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let taskURL = documentsDirectory.appendingPathComponent("tasks")
//    static let nameURL = documentsDirectory.appendingPathComponent("name")
//    static let timeURL = documentsDirectory.appendingPathComponent("time")
//    static let daysURL = documentsDirectory.appendingPathComponent("days")
//    static let multiplierURL = documentsDirectory.appendingPathComponent("multiplier")
//    static let rolloverURL = documentsDirectory.appendingPathComponent("rollover")
//    static let frequencyURL = documentsDirectory.appendingPathComponent("frequency")
//    static let completedURL = documentsDirectory.appendingPathComponent("completed")
//    static let currentWeekURL = documentsDirectory.appendingPathComponent("currentWeek")
//
//    // Cumulative statistics
//    static let totalTimeURL = documentsDirectory.appendingPathComponent("totalTime")
//    static let missedTimeURL = documentsDirectory.appendingPathComponent("missedTime")
//    static let completedTimeURL = documentsDirectory.appendingPathComponent("completedTime")
//    static let totalDaysURL = documentsDirectory.appendingPathComponent("totalDays")
//    static let fullDaysURL = documentsDirectory.appendingPathComponent("fullDays")
//    static let partialDaysURL = documentsDirectory.appendingPathComponent("partialDays")
//    static let missedDaysURL = documentsDirectory.appendingPathComponent("missedDays")
//    static let currentStreakURL = documentsDirectory.appendingPathComponent("currentStreak")
//    static let bestStreakURL = documentsDirectory.appendingPathComponent("bestStreak")
//
//    // History
//    static let taskTimeHistoryURL = documentsDirectory.appendingPathComponent("taskTimeHistory")
//    static let missedTimeHistoryURL = documentsDirectory.appendingPathComponent("missedTimeHistory")
//    static let completedTimeHistoryURL = documentsDirectory.appendingPathComponent("completedTimeHistory")
//    static let previousDatesURL = documentsDirectory.appendingPathComponent("previousDates")

    //MARK: - Save/Load functions
    
    func save() {
        
//        let nameSaveSuccessful = NSKeyedArchiver.archiveRootObject(name, toFile: Task.nameURL.path)
//        let timeSaveSuccessful = NSKeyedArchiver.archiveRootObject(time, toFile: Task.timeURL.path)
//        let daysSaveSuccessful = NSKeyedArchiver.archiveRootObject(days, toFile: Task.daysURL.path)
//        let multiplierSaveSuccessful = NSKeyedArchiver.archiveRootObject(multiplier, toFile: Task.multiplierURL.path)
//        let rolloverSaveSuccessful = NSKeyedArchiver.archiveRootObject(rollover, toFile: Task.rolloverURL.path)
//        let frequencySaveSuccessful = NSKeyedArchiver.archiveRootObject(frequency, toFile: Task.frequencyURL.path)
//        let completedSaveSuccessful = NSKeyedArchiver.archiveRootObject(completed, toFile: Task.completedURL.path)
//        let currentWeekSaveSuccessful = NSKeyedArchiver.archiveRootObject(currentWeek, toFile: Task.currentWeekURL.path)
//
//        // Cumulative statistics
//        let totalTimeSaveSuccessful = NSKeyedArchiver.archiveRootObject(totalTime, toFile: Task.totalTimeURL.path)
//        let missedTimeSaveSuccessful = NSKeyedArchiver.archiveRootObject(missedTime, toFile: Task.missedTimeURL.path)
//        let completedTimeSaveSuccessful = NSKeyedArchiver.archiveRootObject(completedTime, toFile: Task.completedTimeURL.path)
//        let totalDaysSaveSuccessful = NSKeyedArchiver.archiveRootObject(totalDays, toFile: Task.totalDaysURL.path)
//        let fullDaysSaveSuccessful = NSKeyedArchiver.archiveRootObject(fullDays, toFile: Task.fullDaysURL.path)
//        let partialDaysSaveSuccessful = NSKeyedArchiver.archiveRootObject(partialDays, toFile: Task.partialDaysURL.path)
//        let missedDaysSaveSuccessful = NSKeyedArchiver.archiveRootObject(missedDays, toFile: Task.missedDaysURL.path)
//        let currentStreakSaveSuccessful = NSKeyedArchiver.archiveRootObject(currentStreak, toFile: Task.currentStreakURL.path)
//        let bestStreakSaveSuccessful = NSKeyedArchiver.archiveRootObject(bestStreak, toFile: Task.bestStreakURL.path)
//
//        // History
//        let taskTimeHistorySaveSuccessful = NSKeyedArchiver.archiveRootObject(taskTimeHistory, toFile: Task.taskTimeHistoryURL.path)
//        let missedTimeHistorySaveSuccessful = NSKeyedArchiver.archiveRootObject(missedTimeHistory, toFile: Task.missedTimeHistoryURL.path)
//        let completedTimeHistorySaveSuccessful = NSKeyedArchiver.archiveRootObject(completedTimeHistory, toFile: Task.completedTimeHistoryURL.path)
//        let previousDatesSaveSuccessful = NSKeyedArchiver.archiveRootObject(previousDates, toFile: Task.previousDatesURL.path)
//
//        print(nameSaveSuccessful)
//        print(timeSaveSuccessful)
//        print(daysSaveSuccessful)
//        print(multiplierSaveSuccessful)
//        print(rolloverSaveSuccessful)
//        print(frequencySaveSuccessful)
//        print(completedSaveSuccessful)
//        print(currentWeekSaveSuccessful)
//
//        print(totalTimeSaveSuccessful)
//        print(missedTimeSaveSuccessful)
//        print(completedTimeSaveSuccessful)
//        print(totalDaysSaveSuccessful)
//        print(fullDaysSaveSuccessful)
//        print(partialDaysSaveSuccessful)
//        print(missedDaysSaveSuccessful)
//        print(currentStreakSaveSuccessful)
//        print(bestStreakSaveSuccessful)
//
//        print(taskTimeHistorySaveSuccessful)
//        print(missedTimeHistorySaveSuccessful)
//        print(completedTimeHistorySaveSuccessful)
//        print(previousDatesSaveSuccessful)

        
        //print("Saved task names: \(tasksSaveSuccessful)")
        //print("Saved task settings: \(taskSettingsSaveSuccessful)")
        //print("Saved task stats: \(taskStatsSaveSuccessful)")
        //print("Saved task history: \(taskHistorySaveSuccessful)")
        
        //print("Printing saved data")
        //print("Tasks: \(taskNameList)")
        
    }
    
    func load() {
        
//        if let loadName = NSKeyedUnarchiver.unarchiveObject(withFile: Task.nameURL.path) as? String {
//            name = loadName
//        }
//
//        if let loadTime = NSKeyedUnarchiver.unarchiveObject(withFile: Task.timeURL.path) as? Double {
//            time = loadTime
//        }
//
//        if let loadDays = NSKeyedUnarchiver.unarchiveObject(withFile: Task.daysURL.path) as? [String] {
//            days = loadDays
//        }
//
//        if let loadMultiplier = NSKeyedUnarchiver.unarchiveObject(withFile: Task.multiplierURL.path) as? Double {
//            multiplier = loadMultiplier
//        }
//
//        if let loadRollover = NSKeyedUnarchiver.unarchiveObject(withFile: Task.rolloverURL.path) as? Double {
//            rollover = loadRollover
//        }
//
//        if let loadFrequency = NSKeyedUnarchiver.unarchiveObject(withFile: Task.frequencyURL.path) as? Double {
//            frequency = loadFrequency
//        }
//
//        if let loadCompleted = NSKeyedUnarchiver.unarchiveObject(withFile: Task.completedURL.path) as? Double {
//            completed = loadCompleted
//        }
//
//        if let loadCurrentWeek = NSKeyedUnarchiver.unarchiveObject(withFile: Task.currentWeekURL.path) as? Int {
//            currentWeek = loadCurrentWeek
//        }
//
//        // Cumulative statistics
//        if let loadTotalTime = NSKeyedUnarchiver.unarchiveObject(withFile: Task.totalTimeURL.path) as? Double {
//            totalTime = loadTotalTime
//        }
//
//        if let loadMissedTime = NSKeyedUnarchiver.unarchiveObject(withFile: Task.missedTimeURL.path) as? Double {
//            missedTime = loadMissedTime
//        }
//
//        if let loadCompletedTime = NSKeyedUnarchiver.unarchiveObject(withFile: Task.completedTimeURL.path) as? Double {
//            completedTime = loadCompletedTime
//        }
//
//        if let loadTotalDays = NSKeyedUnarchiver.unarchiveObject(withFile: Task.totalDaysURL.path) as? Double {
//            totalDays = loadTotalDays
//        }
//
//        if let loadFullDays = NSKeyedUnarchiver.unarchiveObject(withFile: Task.fullDaysURL.path) as? Double {
//            fullDays = loadFullDays
//        }
//
//        if let loadPartialDays = NSKeyedUnarchiver.unarchiveObject(withFile: Task.partialDaysURL.path) as? Double {
//            partialDays = loadPartialDays
//        }
//
//        if let loadMissedDays = NSKeyedUnarchiver.unarchiveObject(withFile: Task.missedDaysURL.path) as? Double {
//            missedDays = loadMissedDays
//        }
//
//        if let loadCurrentStreak = NSKeyedUnarchiver.unarchiveObject(withFile: Task.currentStreakURL.path) as? Int {
//            currentStreak = loadCurrentStreak
//        }
//
//        if let loadBestStreak = NSKeyedUnarchiver.unarchiveObject(withFile: Task.bestStreakURL.path) as? Int {
//            bestStreak = loadBestStreak
//        }
//
//        // History
//        if let loadTaskTimeHistory = NSKeyedUnarchiver.unarchiveObject(withFile: Task.taskTimeHistoryURL.path) as? [Date: Double] {
//            taskTimeHistory = loadTaskTimeHistory
//        }
//
//        if let loadMissedTimeHistory = NSKeyedUnarchiver.unarchiveObject(withFile: Task.missedTimeHistoryURL.path) as? [Date: Double] {
//            missedTimeHistory = loadMissedTimeHistory
//        }
//
//        if let loadCompletedTimeHistory = NSKeyedUnarchiver.unarchiveObject(withFile: Task.completedTimeHistoryURL.path) as? [Date: Double] {
//            completedTimeHistory = loadCompletedTimeHistory
//        }
//
//        if let loadPreviousDates = NSKeyedUnarchiver.unarchiveObject(withFile: Task.previousDatesURL.path) as? [Date] {
//            previousDates = loadPreviousDates
//        }

    }
    
    //MARK: - Helper Functions
    
    func set(date: Date, as format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
        
    }
    
    func getAccessDate(lengthFromEnd count: Int) -> Date? {
        
        previousDates.sorted(){$0 < $1}
        //let sortedArray = taskAccess!.sorted(by: {$0.timeIntervalSince1970 < $1.timeIntervalSince1970})

        let length = previousDates.count
        
        if length < 1 {
            
            return previousDates.last!
            
        } else if length >= count + 1 {
            
            return previousDates[length - count - 1]
            
        }
            
        return nil
        
    }
    
    func addHistory(date: Date) {
        taskTimeHistory[date] = 0.0
        missedTimeHistory[date] = 0.0
        completedTimeHistory[date] = 0.0
    }
    
    //MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Task.nameKey)
        aCoder.encode(time, forKey: Task.timeKey)
        aCoder.encode(days, forKey: Task.daysKey)
        aCoder.encode(multiplier, forKey: Task.multiplierKey)
        aCoder.encode(rollover, forKey: Task.rolloverKey)
        aCoder.encode(frequency, forKey: Task.frequencyKey)
        aCoder.encode(completed, forKey: Task.completedKey)
        aCoder.encode(currentWeek, forKey: Task.currentWeekKey)
        aCoder.encode(totalTime, forKey: Task.totalTimeKey)
        aCoder.encode(missedTime, forKey: Task.missedTimeKey)
        aCoder.encode(completedTime, forKey: Task.completedTimeKey)
        aCoder.encode(totalDays, forKey: Task.totalDaysKey)
        aCoder.encode(fullDays, forKey: Task.fullDaysKey)
        aCoder.encode(partialDays, forKey: Task.partialDaysKey)
        aCoder.encode(missedDays, forKey: Task.missedDaysKey)
        aCoder.encode(currentStreak, forKey: Task.currentStreakKey)
        aCoder.encode(bestStreak, forKey: Task.bestStreakKey)
        aCoder.encode(taskTimeHistory, forKey: Task.taskTimeHistoryKey)
        aCoder.encode(missedTimeHistory, forKey: Task.missedTimeHistoryKey)
        aCoder.encode(completedTimeHistory, forKey: Task.completedTimeHistoryKey)
        aCoder.encode(previousDates, forKey: Task.previousDatesKey)

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: Task.nameKey) as? String else {
            return nil
        }

        guard let days = aDecoder.decodeObject(forKey: Task.daysKey) as? [String] else {
            return nil
        }
        
        let time = aDecoder.decodeDouble(forKey: Task.timeKey)
        let multiplier = aDecoder.decodeDouble(forKey: Task.multiplierKey)
        let rollover = aDecoder.decodeDouble(forKey: Task.rolloverKey)
        let frequency = aDecoder.decodeDouble(forKey: Task.frequencyKey)
        let completed = aDecoder.decodeDouble(forKey: Task.completedKey)
        let currentWeek = aDecoder.decodeInteger(forKey: Task.currentWeekKey)
        //guard let currentWeek = aDecoder.decodeObject(forKey: Task.currentWeekKey) as? Int else {
        //    return nil
        //}
        
        // Cumulative statistics
        let totalTime = aDecoder.decodeDouble(forKey: Task.totalTimeKey)
        let missedTime = aDecoder.decodeDouble(forKey: Task.missedTimeKey)
        let completedTime = aDecoder.decodeDouble(forKey: Task.completedTimeKey)
        let totalDays = aDecoder.decodeInteger(forKey: Task.totalDaysKey)
        let fullDays = aDecoder.decodeInteger(forKey: Task.fullDaysKey)
        let partialDays = aDecoder.decodeInteger(forKey: Task.partialDaysKey)
        let missedDays = aDecoder.decodeInteger(forKey: Task.missedDaysKey)
        let currentStreak = aDecoder.decodeInteger(forKey: Task.currentStreakKey)
        let bestStreak = aDecoder.decodeInteger(forKey: Task.bestStreakKey)

        // History
        let taskTimeHistory = aDecoder.decodeObject(forKey: Task.taskTimeHistoryKey) as? [Date: Double] ?? [Date: Double]()
        let missedTimeHistory = aDecoder.decodeObject(forKey: Task.missedTimeHistoryKey) as? [Date: Double] ?? [Date: Double]()
        let completedTimeHistory = aDecoder.decodeObject(forKey: Task.completedTimeHistoryKey) as? [Date: Double] ?? [Date: Double]()
        let previousDates = aDecoder.decodeObject(forKey: Task.previousDatesKey) as? [Date] ?? [Date]()
        
        // Must call designated initializer.
        //self.init(name: name, time: time, days: days, multiplier: multiplier, rollover: rollover, frequency: frequency, completed: completed, currentWeek: currentWeek)
        //self.init(totalTime: totalTime, missedTime: missedTime, completedTime: completedTime, totalDays: totalDays, fullDays: fullDays, partialDays: partialDays, missedDays: missedDays, currentStreak: currentStreak, bestStreak: bestStreak)
        //self.init(taskTimeHistory: taskTimeHistory, missedTimeHistory: missedTimeHistory, completedTimeHistory: completedTimeHistory, previousDates: previousDates)
        
        self.init(name: name, time: time, days: days, multiplier: multiplier, rollover: rollover, frequency: frequency, completed: completed, currentWeek: currentWeek, totalTime: totalTime, missedTime: missedTime, completedTime: completedTime, totalDays: totalDays, fullDays: fullDays, partialDays: partialDays, missedDays: missedDays, currentStreak: currentStreak, bestStreak: bestStreak, taskTimeHistory: taskTimeHistory, missedTimeHistory: missedTimeHistory, completedTimeHistory: completedTimeHistory, previousDates: previousDates)

        
    }
    
    //MARK: - Init
    
    convenience override init() {
        self.init(name: "", time: 0.0, days: [], multiplier: 0.0, rollover: 0.0, frequency: 0.0, completed: 0.0, currentWeek: 0, totalTime: 0.0, missedTime: 0.0, completedTime: 0.0, totalDays: 0, fullDays: 0, partialDays: 0, missedDays: 0, currentStreak: 0, bestStreak: 0, taskTimeHistory: [Date: Double](), missedTimeHistory: [Date: Double](), completedTimeHistory: [Date: Double](), previousDates: [Date]())
    }
    
    convenience init(name: String, time: Double, days: [String], multiplier: Double, rollover: Double, frequency: Double, completed: Double, currentWeek: Int) {
        
        self.init(name: name, time: time, days: days, multiplier: multiplier, rollover: rollover, frequency: frequency, completed: completed, currentWeek: currentWeek, totalTime: 0.0, missedTime: 0.0, completedTime: 0.0, totalDays: 0, fullDays: 0, partialDays: 0, missedDays: 0, currentStreak: 0, bestStreak: 0, taskTimeHistory: [Date: Double](), missedTimeHistory: [Date: Double](), completedTimeHistory: [Date: Double](), previousDates: [Date]())
        
    }
    
    init(name: String, time: Double, days: [String], multiplier: Double, rollover: Double, frequency: Double, completed: Double, currentWeek: Int, totalTime: Double, missedTime: Double, completedTime: Double, totalDays: Int, fullDays: Int, partialDays: Int, missedDays: Int, currentStreak: Int, bestStreak: Int, taskTimeHistory: [Date: Double], missedTimeHistory: [Date: Double], completedTimeHistory: [Date: Double], previousDates: [Date]) {
        
        self.name = name
        self.time = time
        self.days = days
        self.multiplier = multiplier
        self.rollover = rollover
        self.frequency = frequency
        self.completed = completed
        self.currentWeek = currentWeek
        
        self.weightedTime = time + (rollover * multiplier)
        
        //var nextOccurringWeek: Int = 0
        
        self.totalTime = totalTime
        self.missedTime = missedTime
        self.completedTime = completedTime
        self.totalDays = totalDays
        self.fullDays = fullDays
        self.partialDays = partialDays
        self.missedDays = missedDays
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak

        self.taskTimeHistory = taskTimeHistory
        self.missedTimeHistory = missedTimeHistory
        self.completedTimeHistory = completedTimeHistory
        //self.previousDates = previousDates

    }
    
}

