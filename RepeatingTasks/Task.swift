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
    var previousDates: [Date] {
            let dates = Array(taskTimeHistory.keys)
            let sortedArray = dates.sorted(by: {$0.timeIntervalSince1970 < $1.timeIntervalSince1970})
            return sortedArray
    }
    
    //MARK: - Keys
    struct Key {
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
        //static let previousDatesKey = "previousDatesKey"

    }

    //MARK: - Archiving Paths
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let taskURL = documentsDirectory.appendingPathComponent("tasks")

    //MARK: - Helper Functions
    
    func set(date: Date, as format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
        
    }
    
    func getAccessDate(lengthFromEnd count: Int) -> Date? {
        
        let sortedDates = previousDates.sorted(){$0 < $1}
        
        let length = sortedDates.count
        
        if length < 1 {
            return sortedDates.last!
        } else if length >= count + 1 {
            return sortedDates[length - count - 1]
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
        aCoder.encode(name, forKey: Key.nameKey)
        aCoder.encode(time, forKey: Key.timeKey)
        aCoder.encode(days, forKey: Key.daysKey)
        aCoder.encode(multiplier, forKey: Key.multiplierKey)
        aCoder.encode(rollover, forKey: Key.rolloverKey)
        aCoder.encode(frequency, forKey: Key.frequencyKey)
        aCoder.encode(completed, forKey: Key.completedKey)
        aCoder.encode(currentWeek, forKey: Key.currentWeekKey)
        aCoder.encode(totalTime, forKey: Key.totalTimeKey)
        aCoder.encode(missedTime, forKey: Key.missedTimeKey)
        aCoder.encode(completedTime, forKey: Key.completedTimeKey)
        aCoder.encode(totalDays, forKey: Key.totalDaysKey)
        aCoder.encode(fullDays, forKey: Key.fullDaysKey)
        aCoder.encode(partialDays, forKey: Key.partialDaysKey)
        aCoder.encode(missedDays, forKey: Key.missedDaysKey)
        aCoder.encode(currentStreak, forKey: Key.currentStreakKey)
        aCoder.encode(bestStreak, forKey: Key.bestStreakKey)
        aCoder.encode(taskTimeHistory, forKey: Key.taskTimeHistoryKey)
        aCoder.encode(missedTimeHistory, forKey: Key.missedTimeHistoryKey)
        aCoder.encode(completedTimeHistory, forKey: Key.completedTimeHistoryKey)
        //aCoder.encode(previousDates, forKey: Key.previousDatesKey)

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: Key.nameKey) as? String else {
            return nil
        }

        guard let days = aDecoder.decodeObject(forKey: Key.daysKey) as? [String] else {
            return nil
        }
        
        let time = aDecoder.decodeDouble(forKey: Key.timeKey)
        let multiplier = aDecoder.decodeDouble(forKey: Key.multiplierKey)
        let rollover = aDecoder.decodeDouble(forKey: Key.rolloverKey)
        let frequency = aDecoder.decodeDouble(forKey: Key.frequencyKey)
        let completed = aDecoder.decodeDouble(forKey: Key.completedKey)
        let currentWeek = aDecoder.decodeInteger(forKey: Key.currentWeekKey)
        //guard let currentWeek = aDecoder.decodeObject(forKey: Key.currentWeekKey) as? Int else {
        //    return nil
        //}
        
        // Cumulative statistics
        let totalTime = aDecoder.decodeDouble(forKey: Key.totalTimeKey)
        let missedTime = aDecoder.decodeDouble(forKey: Key.missedTimeKey)
        let completedTime = aDecoder.decodeDouble(forKey: Key.completedTimeKey)
        let totalDays = aDecoder.decodeInteger(forKey: Key.totalDaysKey)
        let fullDays = aDecoder.decodeInteger(forKey: Key.fullDaysKey)
        let partialDays = aDecoder.decodeInteger(forKey: Key.partialDaysKey)
        let missedDays = aDecoder.decodeInteger(forKey: Key.missedDaysKey)
        let currentStreak = aDecoder.decodeInteger(forKey: Key.currentStreakKey)
        let bestStreak = aDecoder.decodeInteger(forKey: Key.bestStreakKey)

        // History
        let taskTimeHistory = aDecoder.decodeObject(forKey: Key.taskTimeHistoryKey) as? [Date: Double] ?? [Date: Double]()
        let missedTimeHistory = aDecoder.decodeObject(forKey: Key.missedTimeHistoryKey) as? [Date: Double] ?? [Date: Double]()
        let completedTimeHistory = aDecoder.decodeObject(forKey: Key.completedTimeHistoryKey) as? [Date: Double] ?? [Date: Double]()
        //let previousDates = aDecoder.decodeObject(forKey: Key.previousDatesKey) as? [Date] ?? [Date]()
        
        // Must call designated initializer.
        self.init(name: name, time: time, days: days, multiplier: multiplier, rollover: rollover, frequency: frequency, completed: completed, currentWeek: currentWeek, totalTime: totalTime, missedTime: missedTime, completedTime: completedTime, totalDays: totalDays, fullDays: fullDays, partialDays: partialDays, missedDays: missedDays, currentStreak: currentStreak, bestStreak: bestStreak, taskTimeHistory: taskTimeHistory, missedTimeHistory: missedTimeHistory, completedTimeHistory: completedTimeHistory)

        
    }
    
    //MARK: - Init
    
    convenience override init() {
        self.init(name: "", time: 0.0, days: [], multiplier: 0.0, rollover: 0.0, frequency: 0.0, completed: 0.0, currentWeek: 0, totalTime: 0.0, missedTime: 0.0, completedTime: 0.0, totalDays: 0, fullDays: 0, partialDays: 0, missedDays: 0, currentStreak: 0, bestStreak: 0, taskTimeHistory: [Date: Double](), missedTimeHistory: [Date: Double](), completedTimeHistory: [Date: Double]())
    }
    
    convenience init(name: String, time: Double, days: [String], multiplier: Double, rollover: Double, frequency: Double, completed: Double, currentWeek: Int) {
        
        self.init(name: name, time: time, days: days, multiplier: multiplier, rollover: rollover, frequency: frequency, completed: completed, currentWeek: currentWeek, totalTime: 0.0, missedTime: 0.0, completedTime: 0.0, totalDays: 0, fullDays: 0, partialDays: 0, missedDays: 0, currentStreak: 0, bestStreak: 0, taskTimeHistory: [Date: Double](), missedTimeHistory: [Date: Double](), completedTimeHistory: [Date: Double]())
        
    }
    
    init(name: String, time: Double, days: [String], multiplier: Double, rollover: Double, frequency: Double, completed: Double, currentWeek: Int, totalTime: Double, missedTime: Double, completedTime: Double, totalDays: Int, fullDays: Int, partialDays: Int, missedDays: Int, currentStreak: Int, bestStreak: Int, taskTimeHistory: [Date: Double], missedTimeHistory: [Date: Double], completedTimeHistory: [Date: Double]) {
        
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

