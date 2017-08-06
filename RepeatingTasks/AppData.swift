//
//  AppData.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/4/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class AppData: NSObject, NSCoding {
    
    // Basic task information
    var taskResetTime: Date?
    var colorScheme: [String : Bool]?
    
    var isNightMode = false
    var usesCircularProgress = false
    
    // Vars that holds all task data
    // Used for saving
    var appSettings = [String : Bool]()
    
    //MARK: Archiving Paths
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveAppSettings = documentsDirectory.appendingPathComponent("appSettings")
    
    func save() {
        let appSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(appSettings, toFile: AppData.archiveAppSettings.path)
        
        print("Saved app settings: \(appSettingsSaveSuccessful)")
        
    }
    
    func load() {
        
        if let loadTasks = NSKeyedUnarchiver.unarchiveObject(withFile: AppData.archiveAppSettings.path) as? [String : Bool] {
            appSettings = loadTasks
        }
        
    }
    
    func saveToDictionary(name taskName: String, time taskTime: Int,
                          completed completedTime: Int = 0,
                          days taskDaysArray: [String], frequency taskFrequency: Int) {
        
        taskDictionary[taskName] = ["taskTime": taskTime,
                                    "completedTime": completedTime,
                                    "taskDays": taskDays,
                                    "taskFrequency": taskFrequency,
                                    "leftoverMultiplier": leftoverMultiplier,
                                    "leftoverTime": leftoverTime]
        
    }
    
    func saveToStatsDictionary(name taskName: String, stats taskStats: [String: [String:Int]]) {
        taskStatsDictionary[taskName] = taskStats[taskName]
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskNameList, forKey: "taskNameList")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let taskNameList = aDecoder.decodeObject(forKey: "taskNameList") as? [String : Bool] else {
            return nil
        }
        
        // Must call designated initializer.
        self.init(name: taskNameList, taskSettings: taskDictionary, statistics: taskStatsDictionary)
        
    }
    
    init(name: [String], taskSettings: [String:[String:Int]], statistics: [String:[String:Int]]) {
        
        self.taskNameList = name
        
    }
    
    override init() {
        super.init()
    }
    
}

