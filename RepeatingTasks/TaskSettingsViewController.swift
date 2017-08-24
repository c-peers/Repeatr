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
    
    // Used to corretly show the keyboard and scroll the view into place
    var activeTextField: UITextField?
    
    // For pickerview
    var hours = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    var minutes: [String] = ["0"]
    var selectedHours = "0"
    var selectedMinutes = "0"
    var pickerData: [[String]] = []
    
    var timePickerView = UIPickerView()
    let pickerViewDatasource = TaskTimePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskData.setTask(as: task)
        
        nameTextField.delegate = self
        timeTextField.delegate = self
        occurranceTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        rolloverSlider.minimumValue = 0.0
        rolloverSlider.maximumValue = 2.5
        rolloverSlider.tintColor = FlatSkyBlueDark()
        
    
        nameTextField.text = task
        timeTextField.text = setTaskTime()
        occurranceTextField.text = String(Int(occurranceRate))
        
        rolloverSlider.value = Float(rolloverMultiplier)
        let sliderValueAsString = String(rolloverSlider.value)
        rolloverSliderValueLabel.text = sliderValueAsString
        
        //******************************
        // Occurrence rate start
        //******************************
        
        let decimalPadToolBar = UIToolbar.init()
        decimalPadToolBar.sizeToFit()
        let decimalDoneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneOccurrence))
        decimalPadToolBar.items = [decimalDoneButton]
        
        occurranceTextField.keyboardType = .numberPad
        occurranceTextField.inputAccessoryView = decimalPadToolBar
        
        //******************************
        // Occurrence rate initialization finished
        //******************************
        
        
        //******************************
        // Pickerview initialization start
        //******************************
        
        for number in 1...12 {
            
            minutes.append(String(number * 5))
            
        }
        
        pickerData = [hours, minutes]

        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = UIBarStyle.default
        pickerToolBar.isTranslucent = true
        pickerToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        pickerToolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        pickerToolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        pickerToolBar.isUserInteractionEnabled = true
        
        
        timePickerView.dataSource = self
        timePickerView.delegate = self
        timeTextField.inputView = timePickerView
        timeTextField.inputAccessoryView = pickerToolBar
        
        //******************************
        // Pickerview initialization finished
        //******************************
        
        //******************************
        // Day selection start
        //******************************
        
        sunday.layer.borderWidth = 1
        sunday.layer.borderColor = UIColor.black.cgColor
        monday.layer.borderWidth = 1
        monday.layer.borderColor = UIColor.black.cgColor
        tuesday.layer.borderWidth = 1
        tuesday.layer.borderColor = UIColor.black.cgColor
        wednesday.layer.borderWidth = 1
        wednesday.layer.borderColor = UIColor.black.cgColor
        thursday.layer.borderWidth = 1
        thursday.layer.borderColor = UIColor.black.cgColor
        friday.layer.borderWidth = 1
        friday.layer.borderColor = UIColor.black.cgColor
        saturday.layer.borderWidth = 1
        saturday.layer.borderColor = UIColor.black.cgColor

    }
    
    func setTaskTime() -> String {
        
        var timeString = ""
        
        
        return timeString
        
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        
        let toRound = Int(sender.value * 10)
        sender.setValue(Float(toRound) / 10, animated: true)
        print(sender.value)
        
        rolloverSliderValueLabel.text = String(sender.value)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let newTaskName = nameTextField.text {
            
            if newTaskName != task {

                taskData.changeTaskName(from: task, to: newTaskName)
                
                taskData.taskName = newTaskName
                task = newTaskName
                
            }
        }
        
        taskData.rolloverMultiplier = Double(rolloverSlider.value)
        taskData.taskDays = taskDays

        if let frequency = occurranceTextField.text {
            taskData.taskFrequency = Double(frequency)!
            occurranceRate = Double(frequency)!
        }
        
        taskData.saveTask(task)
        taskData.save()
        
        let i = navigationController?.viewControllers.count
        let vc = navigationController?.viewControllers[i!-1] as! TaskDetailViewController
        vc.task = task
        vc.taskDays = taskDays
        vc.rolloverMultiplier = rolloverMultiplier
        vc.taskFrequency = occurranceRate
        
        
        
    }
    
    @IBAction func sundayTapped(_ sender: UIButton) {
        if sunday.tag == 0 {
            sunday.layer.backgroundColor = UIColor.white.cgColor
            sunday.setTitleColor(UIColor.black, for: .normal)
            sunday.tag = 1
            taskDays = taskDays.filter { $0 != "Sunday" }
        } else {
            sunday.layer.backgroundColor = UIColor.black.cgColor
            sunday.setTitleColor(UIColor.white, for: .normal)
            sunday.tag = 0
            taskDays.append("Sunday")
        }
    }
    
    @IBAction func mondayTapped(_ sender: UIButton) {
        if monday.tag == 0 {
            monday.layer.backgroundColor = UIColor.white.cgColor
            monday.setTitleColor(UIColor.black, for: .normal)
            monday.tag = 1
            taskDays = taskDays.filter { $0 != "Monday" }
        } else {
            monday.layer.backgroundColor = UIColor.black.cgColor
            monday.setTitleColor(UIColor.white, for: .normal)
            monday.tag = 0
            taskDays.append("Monday")
            
        }
    }
    
    @IBAction func tuesdayTapped(_ sender: UIButton) {
        if tuesday.tag == 0 {
            tuesday.layer.backgroundColor = UIColor.white.cgColor
            tuesday.setTitleColor(UIColor.black, for: .normal)
            tuesday.tag = 1
            taskDays = taskDays.filter { $0 != "Tuesday" }
        } else {
            tuesday.layer.backgroundColor = UIColor.black.cgColor
            tuesday.setTitleColor(UIColor.white, for: .normal)
            tuesday.tag = 0
            taskDays.append("Tuesday")
        }
    }
    
    @IBAction func wednesdayTapped(_ sender: UIButton) {
        if wednesday.tag == 0 {
            wednesday.layer.backgroundColor = UIColor.white.cgColor
            wednesday.setTitleColor(UIColor.black, for: .normal)
            wednesday.tag = 1
            taskDays = taskDays.filter { $0 != "Wednesday" }
        } else {
            wednesday.layer.backgroundColor = UIColor.black.cgColor
            wednesday.setTitleColor(UIColor.white, for: .normal)
            wednesday.tag = 0
            taskDays.append("Wednesday")
        }
    }
    
    @IBAction func thursdayTapped(_ sender: UIButton) {
        if thursday.tag == 0 {
            thursday.layer.backgroundColor = UIColor.white.cgColor
            thursday.setTitleColor(UIColor.black, for: .normal)
            thursday.tag = 1
            taskDays = taskDays.filter { $0 != "Thursday" }
        } else {
            thursday.layer.backgroundColor = UIColor.black.cgColor
            thursday.setTitleColor(UIColor.white, for: .normal)
            thursday.tag = 0
            taskDays.append("Thursday")
        }
    }
    
    @IBAction func fridayTapped(_ sender: UIButton) {
        if friday.tag == 0 {
            friday.layer.backgroundColor = UIColor.white.cgColor
            friday.setTitleColor(UIColor.black, for: .normal)
            friday.tag = 1
            taskDays = taskDays.filter { $0 != "Friday" }
        } else {
            friday.layer.backgroundColor = UIColor.black.cgColor
            friday.setTitleColor(UIColor.white, for: .normal)
            friday.tag = 0
            taskDays.append("Friday")
        }
    }
    
    @IBAction func saturdayTapped(_ sender: UIButton) {
        if saturday.tag == 0 {
            saturday.layer.backgroundColor = UIColor.white.cgColor
            saturday.setTitleColor(UIColor.black, for: .normal)
            saturday.tag = 1
            taskDays = taskDays.filter { $0 != "Saturday" }
        } else {
            saturday.layer.backgroundColor = UIColor.black.cgColor
            saturday.setTitleColor(UIColor.white, for: .normal)
            saturday.tag = 0
            taskDays.append("Saturday")
        }
    }
    
    func doneOccurrence() {
        occurranceTextField.resignFirstResponder()
    }
    
    func donePicker() {
        timeTextField.resignFirstResponder()
    }
    
    func cancelPicker() {
        timeTextField.resignFirstResponder()
        timeTextField.text = ""
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions

        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeTextField = self.activeTextField {
            if (!aRect.contains(activeTextField.frame.origin)){
                print(!aRect.contains(activeTextField.frame.origin))
                
                self.scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
                
            }
        }
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
        
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

//******************************
//UITextField functions
//******************************

//MARK: - Text Field Delegate

extension TaskSettingsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == occurranceTextField {
            
            // We only want the last character input to be in this field
            // current characters will be removed and the last input character will be added
            
            if string == "." {
                return false
            } else {
                textField.text = ""
                print(textField.text!)
            }
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeTextField = nil
    }
    
}

//******************************
//UIPickerView functions
//******************************

//MARK: - Picker View Delegate

extension TaskSettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedHours = pickerData[0][timePickerView.selectedRow(inComponent: 0)]
        selectedMinutes = pickerData[1][timePickerView.selectedRow(inComponent: 1)]
        
        if selectedHours == "0" && selectedMinutes != "0" {
            timeTextField.text = selectedMinutes + " minutes"
        } else if selectedHours != "0" && selectedMinutes  == "0" {
            timeTextField.text = selectedHours + " hours"
        } else if selectedHours != "0" && selectedMinutes != "0" {
            timeTextField.text = selectedHours + " hours " + selectedMinutes + " minutes"
        }
        
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
