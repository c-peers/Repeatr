//
//  TaskSettingsViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/21/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

class TaskSettingsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var rolloverSlider: UISlider!
    @IBOutlet weak var occurranceTextField: UITextField!
    @IBOutlet weak var rolloverSliderValueLabel: UILabel!
    
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!

    var task = ""
    var taskTime = 0.0
    var taskDays = [""]
    var occurranceRate = 0.0
    var rolloverMultiplier = 1.0
    
    var taskData = TaskData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rolloverSlider.value = Float(rolloverMultiplier)
        
        rolloverSlider.minimumValue = 0.0
        rolloverSlider.maximumValue = 2.5
        rolloverSlider.tintColor = FlatSkyBlueDark()
        
        let sliderValueAsString = String(rolloverSlider.value)
        rolloverSliderValueLabel.text = sliderValueAsString
        
        
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        
        let toRound = Int(sender.value * 10)
        sender.setValue(Float(toRound) / 10, animated: true)
        print(sender.value)
        
        rolloverSliderValueLabel.text = String(sender.value)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        taskData.saveTask(task)
        
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
