//
//  AppData.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/4/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation
import Chameleon

class AppData: NSObject, NSCoding {

    //MARK: - Object

    //MARK: - Coding
    
    // Basic task information
    var taskResetTime = Date()
    var taskLastTime = Date()
    var taskCurrentTime = Date()
    //var colorScheme: [String : Bool]?
    var colorScheme: [UIColor] = []
    var appColor = UIColor.red
    
    // App settings
    var isNightMode = false
    var usesCircularProgress = false
    
    // Vars that holds all task data
    // Used for saving
    var appSettings = [String : Bool]()
    var timeSettings = [String : Date]()
    var colorSettings = [String : UIColor]()
    
    //MARK: Archiving Paths
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveAppSettings = documentsDirectory.appendingPathComponent("appSettings")
    static let archiveTimeSettings = documentsDirectory.appendingPathComponent("timeSettings")
    static let archiveColorSettings = documentsDirectory.appendingPathComponent("colorSettings")

    func save() {
        let appSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(appSettings, toFile: AppData.archiveAppSettings.path)
        let timeSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(timeSettings, toFile: AppData.archiveTimeSettings.path)
        let colorSettingsSaveSuccessful = NSKeyedArchiver.archiveRootObject(colorSettings, toFile: AppData.archiveColorSettings.path)
        
        print("Saved app settings: \(appSettingsSaveSuccessful)")
        print("Saved time settings: \(timeSettingsSaveSuccessful)")
        print("Saved color settings: \(colorSettingsSaveSuccessful)")
        
    }
    
    func load() {
        
        if let loadAppSettings = NSKeyedUnarchiver.unarchiveObject(withFile: AppData.archiveAppSettings.path) as? [String : Bool] {
            appSettings = loadAppSettings
        }
        if let loadTimeSettings = NSKeyedUnarchiver.unarchiveObject(withFile: AppData.archiveTimeSettings.path) as? [String : Date] {
            timeSettings = loadTimeSettings
        }
        
        if let loadColorSettings = NSKeyedUnarchiver.unarchiveObject(withFile: AppData.archiveColorSettings.path) as? [String : UIColor] {
            colorSettings = loadColorSettings
        }

        
    }
    
    func loadColors() {
        
        if let appColor = colorSettings["appColor"] {
            self.appColor = appColor
        }
        
        setColorScheme()
        
    }
    
    func setColorScheme() {
        
        colorScheme = ColorSchemeOf(.analogous, color: appColor, isFlatScheme: true)
        
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
    
    func saveColorSettingsToDictionary() {
        
        colorSettings["appColor"] = appColor
    }

    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(appSettings, forKey: "appSettings")
        aCoder.encode(timeSettings, forKey: "timeSettings")
        aCoder.encode(colorSettings, forKey: "colorSettings")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let appSettings = aDecoder.decodeObject(forKey: "appSettings") as? [String : Bool] else {
            return nil
        }
        guard let timeSettings = aDecoder.decodeObject(forKey: "timeSettings") as? [String : Date] else {
            return nil
        }
        guard let colorSettings = aDecoder.decodeObject(forKey: "colorSettings") as? [String : UIColor] else {
            return nil
        }
        
        // Must call designated initializer.
        self.init(appSettings: appSettings,  timeSettings: timeSettings, colorSettings: colorSettings)
        
    }
    
    //MARK: Init
    
    init(appSettings: [String : Bool], timeSettings: [String : Date], colorSettings: [String : UIColor]) {
        
        self.appSettings = appSettings
        self.timeSettings = timeSettings
        self.colorSettings = colorSettings
        
    }
    
    override init() {
        super.init()
        
        if let appColor = colorSettings["appColor"] {
            self.appColor = appColor
        }
        
        setColorScheme()
        
    }
    
}

