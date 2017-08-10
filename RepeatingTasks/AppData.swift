//
//  AppData.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/4/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class AppData: NSObject, NSCoding {

    //MARK: - Object

    //MARK: - Coding
    
    // Basic task information
    var taskResetTime = Date()
    var taskLastTime = Date()
    var taskCurrentTime = Date()
    var colorScheme: [String : Bool]?
    
    // App settings
    var isNightMode = false
    var usesCircularProgress = false
    
    // Vars that holds all task data
    // Used for saving
    var appSettings = [String : Bool]()
    var timeSettings = [String : Date]()
    
    //MARK: Archiving Paths
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveAppSettings = documentsDirectory.appendingPathComponent("appSettings")
    static let archiveTimeSettings = documentsDirectory.appendingPathComponent("timeSettings")
    
    func save() {
        let appSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(appSettings, toFile: AppData.archiveAppSettings.path)
        let timeSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(timeSettings, toFile: AppData.archiveTimeSettings.path)
        
        print("Saved app settings: \(appSettingsSaveSuccessful)")
        print("Saved time settings: \(timeSettingsSaveSuccessful)")
        
    }
    
    func load() {
        
        if let loadAppSettings = NSKeyedUnarchiver.unarchiveObject(withFile: AppData.archiveAppSettings.path) as? [String : Bool] {
            appSettings = loadAppSettings
        }
        if let loadTimeSettings = NSKeyedUnarchiver.unarchiveObject(withFile: AppData.archiveTimeSettings.path) as? [String : Date] {
            timeSettings = loadTimeSettings
        }
        
    }
    
    func setAppValues() {
        
        var defaultReset = DateComponents()
        defaultReset.year = Calendar.current.component(.year, from: Date())
        defaultReset.month = Calendar.current.component(.month, from: Date())
        defaultReset.day = Calendar.current.component(.day, from: Date())
        defaultReset.hour = 2
        defaultReset.minute = 0
        defaultReset.second = 0
        
        //taskResetTime = timeSettings["taskResetTime"]!
        taskResetTime = Calendar.current.date(from: defaultReset)!
        taskLastTime = timeSettings["taskLastTime"]!
        taskCurrentTime = timeSettings["taskCurrentTime"]!
        
        isNightMode = appSettings["isNightMode"]!
        usesCircularProgress = appSettings["usesCircularProgress"]!
        
    }
    
    
    func saveAppSettingsToDictionary(){
        
        appSettings["isNightMode"] = isNightMode
        appSettings["usesCircularProgress"] = usesCircularProgress
        
    }
    
    func saveTimeSettingsToDictionary(){
        
        timeSettings["taskResetTime"] = taskResetTime
        timeSettings["taskLastTime"] = taskLastTime
        timeSettings["taskCurrentTime"] = taskCurrentTime
        
    }

    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(appSettings, forKey: "appSettings")
        aCoder.encode(timeSettings, forKey: "timeSettings")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let appSettings = aDecoder.decodeObject(forKey: "appSettings") as? [String : Bool] else {
            return nil
        }
        guard let timeSettings = aDecoder.decodeObject(forKey: "timeSettings") as? [String : Date] else {
            return nil
        }
        
        // Must call designated initializer.
        self.init(appSettings: appSettings,  timeSettings: timeSettings)
        
    }
    
    init(appSettings: [String : Bool], timeSettings: [String : Date]) {
        
        self.appSettings = appSettings
        self.timeSettings = timeSettings
        
    }
    
    override init() {
        super.init()
    }
    
}

