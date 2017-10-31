    //
//  TaskChecker.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 10/27/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class Check {
    
    var appData = AppData()
    
    var currentWeek: Int = {
        let today = Date()
        var calendar = Calendar.current
        let timeZoneID = TimeZone.current.identifier
        let timeZone = TimeZone.abbreviationDictionary.first { $0.value == timeZoneID }
        calendar.timeZone = TimeZone(abbreviation: timeZone!.key)!
        let currentWeekOfYear = calendar.component(.weekOfYear, from: today)
        return currentWeekOfYear
    }()
    
    func ifTaskWillRun(_ task: Task) {
        
        let currentDay = offsetDate(appData.taskCurrentTime, by: appData.resetOffset)
        let isThisWeek = taskWeek(for: task, at: currentDay)
        let isThisDayofWeek = taskDays(for: task, at: currentDay)
        
        task.isToday = (isThisWeek && isThisDayofWeek) ? true : false
    }
    
    func taskDays(for task: Task, at date: Date) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        let dayOfWeekString = dateFormatter.string(from: date)
        print("Today is \(dayOfWeekString)")
        
        return task.days.contains(dayOfWeekString)
        
    }
    
    func taskWeek(for task: Task, at date: Date) -> Bool {
        //let weekOfYear = calendar.component(.weekOfYear, from: date)
        return task.runWeek == currentWeek
    }
    
    func changeOfWeek(between start: Date, and end: Date) -> Bool {
        
        var calendar = Calendar.current
        let timeZoneID = TimeZone.current.identifier
        let timeZone = TimeZone.abbreviationDictionary.first { $0.value == timeZoneID }
        calendar.timeZone = TimeZone(abbreviation: timeZone!.key)!
        let startWeek = calendar.component(.weekOfYear, from: start)
        let endWeek = calendar.component(.weekOfYear, from: end)

        return startWeek != endWeek
        
    }
    
    func daysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    func timeToReset(at resetTime: Date) -> TimeInterval {
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
    
    func missedDays(in task: Task, between start: Date, and end: Date) {
        
        var date = task.getHistory(at: start)
        
        let daysBetween = daysBetweenTwoDates(start: start, end: end)
        
        if daysBetween < 1 {
            return
        }
        
        // Run through all the days in between
        // the previous run and today
        for day in 0..<daysBetween {
            
            // day 0 is the last time the app was ran
            // so we need to use the correct time in the dictionary
            if day == 0, let previousDate = date { //}!= nil {
                let taskTime = task.taskTimeHistory[previousDate]
                let completedTime = task.completedTimeHistory[previousDate]
                //let taskTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.taskTimeHistoryKey]
                //let completedTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.completedHistoryKey]
                let unfinishedTime = taskTime! - completedTime!
                
                if unfinishedTime >= 0 {
                    task.missedTimeHistory[previousDate] = unfinishedTime
                    //taskData.taskHistoryDictionary[task]![date!]![TaskData.missedHistoryKey]! = unfinishedTime
                } else {
                    task.missedTimeHistory[previousDate] = 0
                    //taskData.taskHistoryDictionary[task]![date!]![TaskData.missedHistoryKey]! = 0.0
                }
                
            } else {
                
                date = Calendar.current.date(byAdding: .day, value: day, to: start)
                
                let dateExistsInDict = task.isHistoryPresent(for: date!)//taskData.taskHistoryDictionary[task]?[date!]
                
                if taskDays(for: task, at: date!) && dateExistsInDict == true {
                    
                    task.addHistory(date: date!)
                    //taskData.newTaskHistory(for: task, for: date!)
                    
                }
                
                let taskTime = task.taskTimeHistory[date!]
                let completedTime = task.completedTimeHistory[date!]
                //let taskTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.taskTimeHistoryKey]
                //let completedTime = taskData.taskHistoryDictionary[task]?[date!]?[TaskData.completedHistoryKey]
                
                if (taskTime != nil) && (completedTime != nil) {
                    task.missedTimeHistory[date!] = taskTime! - completedTime!
                    //taskData.taskHistoryDictionary[task]![date!]![TaskData.missedHistoryKey] = taskTime! - completedTime!
                }
            }
            
        }
        
    }
    
    /*
     Checks if last time accessed is the same day or not.
     If it is the same day then do nothing.
     Otherwise create history dicionary with today's date.
     */
    
    func access(for task: Task, upTo currentDay: Date) -> Bool {
        
        let offsetString = appData.resetOffset
        
        if let previousAccess = task.previousDates.last { //taskData.taskAccess?.last {
            
            // Both give day of week as an int. Check if values match
            let previousAccessDay = getDay(for: previousAccess, with: offsetString)
            let currentAccessDay = getDay(for: currentDay, with: offsetString)
            
            if previousAccessDay != currentAccessDay {
                task.addHistory(date: currentDay)
                return false
            }
            
            return true
            
        } else {
            task.addHistory(date: currentDay)
            return false
        }
        
    }
    
    func getDay(for date: Date, with offset: String) -> Int {
        
        var resetOffset = DateComponents()
        resetOffset.hour = -offsetAsInt(for: offset)
        
        let date = Calendar.current.date(byAdding: resetOffset, to: date)
        let offsetDay = Calendar.current.component(.weekday, from: date!)
        
        return offsetDay
        
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
    
    func offsetAsInt(for offset: String) -> Int {
        
        let offsetTime = offset.components(separatedBy: ":")[0]
        var offset = Int(offsetTime)
        if offset == 12 {
            offset = 0
        }
        return offset!
        
    }
    
    func secondsToHoursMinutesSeconds(from seconds: Int) -> (Int, Int, Int) {
        
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) & 60)
        
    }
    
}
