//
//  TimePicker.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/24/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation
import UIKit

class TaskTimePicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // For pickerview
    var hours = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    var minutes: [String] = ["0"]
    var selectedHours = "0"
    var selectedMinutes = "0"
    var pickerData: [[String]] = []

    override init() {
        super.init()
        
        for number in 1...12 {
            
            minutes.append(String(number * 5))
            
        }
        
        pickerData = [hours, minutes]
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(100.0)
    }
    
}
