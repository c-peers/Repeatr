//
//  NewTasksViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 6/16/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

class NewTasksViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newTaskView: UIView!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    @IBOutlet weak var occurrenceRateTextField: UITextField!
    
    @IBOutlet weak var taskLengthTextField: UITextField!
    
    // Used to corretly show the keyboard and scroll the view into place
    var activeTextField: UITextField?
    
    // For occurrence
    var taskDays = [String]()
    
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
        
        taskNameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        //******************************
        // Notification Bar start
        //******************************
        
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 44))
        self.view.addSubview(navBar);
        let navItem = UINavigationItem(title: "Add Task");
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelTask))
        navItem.leftBarButtonItems = [cancelBarButton]
        
        navBar.setItems([navItem], animated: false);
        
        //******************************
        // Notification Bar finished
        //******************************
        
        //let navBarColor = navBar.color
        //UIApplication.shared.statusBarStyle = .default
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor(hexString: "52A7DF")
        view.addSubview(statusBarView)
        

    
        //******************************
        // Occurrence rate start
        //******************************

        let decimalPadToolBar = UIToolbar.init()
        decimalPadToolBar.sizeToFit()
        let decimalDoneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneOccurrence))
        decimalPadToolBar.items = [decimalDoneButton]
        
        occurrenceRateTextField.keyboardType = .numberPad
        occurrenceRateTextField.inputAccessoryView = decimalPadToolBar
        occurrenceRateTextField.delegate = self
        
        //******************************
        // Occurrence rate initialization finished
        //******************************

        
        //******************************
        // Pickerview initialization start
        //******************************

        for number in 1...12 {
            
            minutes.append(String(number * 5))
            
        }
        
        print(minutes)
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
        taskLengthTextField.delegate = self
        taskLengthTextField.inputView = timePickerView
        taskLengthTextField.inputAccessoryView = pickerToolBar
        
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
    
    @IBAction func sundayTapped(_ sender: UIButton) {
        if sunday.layer.backgroundColor == UIColor.black.cgColor {
            sunday.layer.backgroundColor = UIColor.white.cgColor
            sunday.setTitleColor(UIColor.black, for: .normal)
            taskDays = taskDays.filter { $0 != "Sunday" }
        } else {
            sunday.layer.backgroundColor = UIColor.black.cgColor
            sunday.setTitleColor(UIColor.white, for: .normal)
            taskDays.append("Sunday")
        }
    }
    
    @IBAction func mondayTapped(_ sender: UIButton) {
        if monday.layer.backgroundColor == UIColor.black.cgColor {
            monday.layer.backgroundColor = UIColor.white.cgColor
            monday.setTitleColor(UIColor.black, for: .normal)
            taskDays = taskDays.filter { $0 != "Monday" }
        } else {
            monday.layer.backgroundColor = UIColor.black.cgColor
            monday.setTitleColor(UIColor.white, for: .normal)
            taskDays.append("Monday")

        }
    }
    
    @IBAction func tuesdayTapped(_ sender: UIButton) {
        if tuesday.layer.backgroundColor == UIColor.black.cgColor {
            tuesday.layer.backgroundColor = UIColor.white.cgColor
            tuesday.setTitleColor(UIColor.black, for: .normal)
            taskDays = taskDays.filter { $0 != "Tuesday" }
        } else {
            tuesday.layer.backgroundColor = UIColor.black.cgColor
            tuesday.setTitleColor(UIColor.white, for: .normal)
            taskDays.append("Tuesday")
        }
    }
    
    @IBAction func wednesdayTapped(_ sender: UIButton) {
        if wednesday.layer.backgroundColor == UIColor.black.cgColor {
            wednesday.layer.backgroundColor = UIColor.white.cgColor
            wednesday.setTitleColor(UIColor.black, for: .normal)
            taskDays = taskDays.filter { $0 != "Wednesday" }
        } else {
            wednesday.layer.backgroundColor = UIColor.black.cgColor
            wednesday.setTitleColor(UIColor.white, for: .normal)
            taskDays.append("Wednesday")
        }
    }
    
    @IBAction func thursdayTapped(_ sender: UIButton) {
        if thursday.layer.backgroundColor == UIColor.black.cgColor {
            thursday.layer.backgroundColor = UIColor.white.cgColor
            thursday.setTitleColor(UIColor.black, for: .normal)
            taskDays = taskDays.filter { $0 != "Thursday" }
        } else {
            thursday.layer.backgroundColor = UIColor.black.cgColor
            thursday.setTitleColor(UIColor.white, for: .normal)
            taskDays.append("Thursday")
        }
    }
    
    @IBAction func fridayTapped(_ sender: UIButton) {
        if friday.layer.backgroundColor == UIColor.black.cgColor {
            friday.layer.backgroundColor = UIColor.white.cgColor
            friday.setTitleColor(UIColor.black, for: .normal)
            taskDays = taskDays.filter { $0 != "Friday" }
        } else {
            friday.layer.backgroundColor = UIColor.black.cgColor
            friday.setTitleColor(UIColor.white, for: .normal)
            taskDays.append("Friday")
        }
    }
    
    @IBAction func saturdayTapped(_ sender: UIButton) {
        if saturday.layer.backgroundColor == UIColor.black.cgColor {
            saturday.layer.backgroundColor = UIColor.white.cgColor
            saturday.setTitleColor(UIColor.black, for: .normal)
            taskDays = taskDays.filter { $0 != "Saturday" }
        } else {
            saturday.layer.backgroundColor = UIColor.black.cgColor
            saturday.setTitleColor(UIColor.white, for: .normal)
            taskDays.append("Saturday")
        }
    }
    
    
    @IBAction func createTask(_ sender: Any) {

        // TODO: check that all fields have data. Popup if blank
        
        print(taskDays)
        performSegue(withIdentifier: "createdTaskUnwindSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createdTaskUnwindSegue" {
            
            let vc = segue.destination as! TaskViewController
            
            let taskName = taskNameTextField.text!
            //let completedTime = 0
            //let taskDaysBinary = TaskData().taskDaysAsBinary(from: taskDays)
            var taskFrequency = 0.0
            if let frequencyValue = Double(occurrenceRateTextField.text!) {
                taskFrequency = frequencyValue
            }
            
            var taskTime = 0.0
            
            if selectedHours != "0" {
                
                let hoursAsInt = Int(selectedHours)
                
                if selectedMinutes != "0" {
                    let minutesAsInt = Int(selectedMinutes)
                    taskTime = Double(hoursAsInt! * 3600 + minutesAsInt! * 60)
                } else {
                    taskTime = Double(hoursAsInt! * 3600)
                }
            } else if selectedMinutes != "0" {
                let minutesAsInt = Int(selectedMinutes)
                taskTime = Double(minutesAsInt! * 60)
            }
            
            vc.taskData.newTask(name: taskName, time: taskTime, days: taskDays, frequency: taskFrequency)
            vc.taskData.newStatsDictionaryEntry(name: taskName)
            
            vc.tasks.append(taskName)
            
            
        }
    }
    
    func doneOccurrence() {
        occurrenceRateTextField.resignFirstResponder()
    }

    func cancelTask() {
        //navigationController?.popViewController(animated: true)
        //self.removeFromParentViewController()
        //navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func donePicker() {
        taskLengthTextField.resignFirstResponder()
    }
    
    func cancelPicker() {
        taskLengthTextField.resignFirstResponder()
        taskLengthTextField.text = ""
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
        print("Keyboard was shown")
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        print(taskLengthTextField.isFirstResponder)
        
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
    
}

//******************************
//UIPickerView functions
//******************************

//MARK: - Picker View Delegate

extension NewTasksViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedHours = pickerData[0][timePickerView.selectedRow(inComponent: 0)]
        selectedMinutes = pickerData[1][timePickerView.selectedRow(inComponent: 1)]
        
        if selectedHours == "0" && selectedMinutes != "0" {
            taskLengthTextField.text = selectedMinutes + " minutes"
        } else if selectedHours != "0" && selectedMinutes  == "0" {
            taskLengthTextField.text = selectedHours + " hours"
        } else if selectedHours != "0" && selectedMinutes != "0" {
            taskLengthTextField.text = selectedHours + " hours " + selectedMinutes + " minutes"
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

//******************************
//UITextField functions
//******************************

//MARK: - Text Field Delegate

extension NewTasksViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == occurrenceRateTextField {
            
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
