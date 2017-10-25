//
//  TaskSettingViewControllerBackup.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 10/16/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

//class TaskSettingsViewControllerBackup: UIViewController {
//
//    //MARK: - Outlets
//
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var bgView: UIView!
//
//    @IBOutlet weak var nameTextField: UITextField!
//    @IBOutlet weak var timeTextField: UITextField!
//    @IBOutlet weak var rolloverSlider: UISlider!
//    @IBOutlet weak var occurranceTextField: UITextField!
//    @IBOutlet weak var rolloverSliderValueLabel: UILabel!
//
//    @IBOutlet weak var sunday: UIButton!
//    @IBOutlet weak var monday: UIButton!
//    @IBOutlet weak var tuesday: UIButton!
//    @IBOutlet weak var wednesday: UIButton!
//    @IBOutlet weak var thursday: UIButton!
//    @IBOutlet weak var friday: UIButton!
//    @IBOutlet weak var saturday: UIButton!
//
//    //MARK: - Properties
//
//    var task = ""
//    var taskTime = 0.0
//    var taskDays = [""]
//    var occurranceRate = 0.0
//    var rolloverMultiplier = 1.0
//
//    var appData = AppData()
//    var taskData = TaskData()
//    let timer = CountdownTimer()
//
//    // Used to corretly show the keyboard and scroll the view into place
//    var activeTextField: UITextField?
//
//    // For pickerview
//    var hours = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
//    var minutes: [String] = ["0"]
//    var selectedHours = "0"
//    var selectedMinutes = "0"
//    var pickerData: [[String]] = []
//    var selectedFromPicker: UILabel!
//
//    var timePickerView = UIPickerView()
//    let pickerViewDatasource = TaskTimePicker()
//
//    //MARK: - View and Basic Functions
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let darkerThemeColor = appData.appColor.darken(byPercentage: 0.25)
//        view.backgroundColor = darkerThemeColor
//        scrollView.backgroundColor = darkerThemeColor
//        bgView.backgroundColor = darkerThemeColor
//
//        taskData.setTask(as: task)
//
//        nameTextField.delegate = self
//        timeTextField.delegate = self
//        occurranceTextField.delegate = self
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//
//        rolloverSlider.minimumValue = 0.0
//        rolloverSlider.maximumValue = 2.5
//        rolloverSlider.tintColor = FlatSkyBlueDark()
//
//        setValues()
//
//        //******************************
//        // Occurrence rate start
//        //******************************
//
//        let decimalPadToolBar = UIToolbar.init()
//        decimalPadToolBar.sizeToFit()
//        let decimalDoneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneOccurrence))
//        decimalPadToolBar.items = [decimalDoneButton]
//
//        occurranceTextField.keyboardType = .numberPad
//        occurranceTextField.inputAccessoryView = decimalPadToolBar
//
//        //******************************
//        // Occurrence rate initialization finished
//        //******************************
//
//
//        //******************************
//        // Pickerview initialization start
//        //******************************
//
//        for number in 1...12 {
//
//            minutes.append(String(number * 5))
//
//        }
//
//        pickerData = [hours, minutes]
//
//        let pickerToolBar = UIToolbar()
//        pickerToolBar.barStyle = UIBarStyle.default
//        pickerToolBar.isTranslucent = true
//        pickerToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
//        pickerToolBar.sizeToFit()
//
//        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
//
//        pickerToolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
//
//        pickerToolBar.isUserInteractionEnabled = true
//
//
//        timePickerView.dataSource = self
//        timePickerView.delegate = self
//        timeTextField.inputView = timePickerView
//        timeTextField.inputAccessoryView = pickerToolBar
//
//        timePickerView.selectRow(0, inComponent: 0, animated: true)
//        timePickerView.selectRow(0, inComponent: 1, animated: true)
//
//        //******************************
//        // Pickerview initialization finished
//        //******************************
//
//        //******************************
//        // Day selection start
//        //******************************
//
//        sunday.layer.borderWidth = 1
//        sunday.layer.borderColor = appData.appColor.cgColor
//        monday.layer.borderWidth = 1
//        monday.layer.borderColor = appData.appColor.cgColor
//        tuesday.layer.borderWidth = 1
//        tuesday.layer.borderColor = appData.appColor.cgColor
//        wednesday.layer.borderWidth = 1
//        wednesday.layer.borderColor = appData.appColor.cgColor
//        thursday.layer.borderWidth = 1
//        thursday.layer.borderColor = appData.appColor.cgColor
//        friday.layer.borderWidth = 1
//        friday.layer.borderColor = appData.appColor.cgColor
//        saturday.layer.borderWidth = 1
//        saturday.layer.borderColor = appData.appColor.cgColor
//
//    }
//
//    func setValues() {
//
//        nameTextField.text = task
//        timeTextField.text = setTaskTime()
//        occurranceTextField.text = String(Int(occurranceRate))
//
//        rolloverSlider.value = Float(rolloverMultiplier)
//        let sliderValueAsString = String(rolloverSlider.value)
//        rolloverSliderValueLabel.text = sliderValueAsString
//
//        for day in taskDays {
//
//            switch day {
//            case "Sunday":
//                sunday.tag = 1
//                setButtonOn(for: sunday)
//            case "Monday":
//                monday.tag = 1
//                setButtonOn(for: monday)
//            case "Tuesday":
//                tuesday.tag = 1
//                setButtonOn(for: tuesday)
//            case "Wednesday":
//                wednesday.tag = 1
//                setButtonOn(for: wednesday)
//            case "Thursday":
//                thursday.tag = 1
//                setButtonOn(for: thursday)
//            case "Friday":
//                friday.tag = 1
//                setButtonOn(for: friday)
//            case "Saturday":
//                saturday.tag = 1
//                setButtonOn(for: saturday)
//            default:
//                break
//            }
//
//        }
//
//    }
//
//    func setTaskTime() -> String {
//
//        let (timeString, _) = timer.formatTimer(name: task, dataset: taskData)
//
//        return timeString
//
//    }
//
//    @IBAction func sliderChanged(_ sender: UISlider) {
//
//        let toRound = Int(sender.value * 10)
//        sender.setValue(Float(toRound) / 10, animated: true)
//        print(sender.value)
//
//        rolloverSliderValueLabel.text = String(sender.value)
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//
//        if let newTaskName = nameTextField.text {
//
//            if newTaskName != task {
//
//                taskData.changeTaskName(from: task, to: newTaskName)
//
//                taskData.taskName = newTaskName
//                task = newTaskName
//
//            }
//        }
//
//        taskData.rolloverMultiplier = Double(rolloverSlider.value)
//        taskData.taskDays = taskDays
//
//        if let frequency = occurranceTextField.text {
//            taskData.taskFrequency = Double(frequency)!
//            occurranceRate = Double(frequency)!
//        }
//
//        taskData.saveTask(task)
//        taskData.save()
//
//        let i = navigationController?.viewControllers.count
//        let vc = navigationController?.viewControllers[i!-1] as! TaskDetailViewController
//        vc.task = task
//        vc.taskDays = taskDays
//        vc.rolloverMultiplier = rolloverMultiplier
//        vc.taskFrequency = occurranceRate
//
//    }
//
//    //MARK: - Button Actions/Functions
//
//    func setButtonOn(for button: UIButton) {
//
//        button.layer.backgroundColor = self.appData.appColor.cgColor
//        button.setTitleColor(UIColor.white, for: .normal)
//
//    }
//
//    func buttonAction(for button: UIButton) {
//
//        if button.tag == 0 {
//            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                button.layer.backgroundColor = self.appData.appColor.cgColor
//                button.setTitleColor(UIColor.white, for: .normal)
//            })
//            button.tag = 1
//        } else {
//            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                button.layer.backgroundColor = UIColor.white.cgColor
//                button.setTitleColor(UIColor.black, for: .normal)
//            })
//            button.tag = 0
//        }
//
//    }
//
//    @IBAction func sundayTapped(_ sender: UIButton) {
//
//        if sunday.tag == 0 {
//            taskDays.append("Sunday")
//        } else {
//            taskDays = taskDays.filter { $0 != "Sunday" }
//        }
//
//        buttonAction(for: sender)
//
//    }
//
//    @IBAction func mondayTapped(_ sender: UIButton) {
//
//        if monday.tag == 0 {
//            taskDays.append("Monday")
//        } else {
//            taskDays = taskDays.filter { $0 != "Monday" }
//        }
//
//        buttonAction(for: sender)
//
//    }
//
//    @IBAction func tuesdayTapped(_ sender: UIButton) {
//
//        if tuesday.tag == 0 {
//            taskDays.append("Tuesday")
//        } else {
//            taskDays = taskDays.filter { $0 != "Tuesday" }
//        }
//
//        buttonAction(for: sender)
//
//    }
//
//    @IBAction func wednesdayTapped(_ sender: UIButton) {
//
//        if wednesday.tag == 0 {
//            taskDays.append("Wednesday")
//        } else {
//            taskDays = taskDays.filter { $0 != "Wednesday" }
//        }
//
//        buttonAction(for: sender)
//
//    }
//
//    @IBAction func thursdayTapped(_ sender: UIButton) {
//
//        if thursday.tag == 0 {
//            taskDays.append("Thursday")
//        } else {
//            taskDays = taskDays.filter { $0 != "Thursday" }
//        }
//
//        buttonAction(for: sender)
//
//    }
//
//    @IBAction func fridayTapped(_ sender: UIButton) {
//
//        if friday.tag == 0 {
//            taskDays.append("Friday")
//        } else {
//            taskDays = taskDays.filter { $0 != "Friday" }
//        }
//
//        buttonAction(for: sender)
//
//    }
//
//    @IBAction func saturdayTapped(_ sender: UIButton) {
//
//        if saturday.tag == 0 {
//            taskDays.append("Saturday")
//        } else {
//            taskDays = taskDays.filter { $0 != "Saturday" }
//        }
//
//        buttonAction(for: sender)
//
//    }
//
//    //MARK: - Keyoard Functions
//
//    func registerForKeyboardNotifications(){
//        //Adding notifies on keyboard appearing
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//
//    func deregisterFromKeyboardNotifications(){
//        //Removing notifies on keyboard appearing
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//
//    @objc func keyboardWasShown(notification: NSNotification){
//        //Need to calculate keyboard exact size due to Apple suggestions
//
//        self.scrollView.isScrollEnabled = true
//        var info = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
//
//        self.scrollView.contentInset = contentInsets
//        self.scrollView.scrollIndicatorInsets = contentInsets
//
//        var aRect : CGRect = self.view.frame
//        aRect.size.height -= keyboardSize!.height
//        if let activeTextField = self.activeTextField {
//            if (!aRect.contains(activeTextField.frame.origin)){
//                print(!aRect.contains(activeTextField.frame.origin))
//
//                self.scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
//
//            }
//        }
//
//    }
//
//    @objc func keyboardWillBeHidden(notification: NSNotification){
//        //Once keyboard disappears, restore original positions
//        var info = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
//        self.scrollView.contentInset = contentInsets
//        self.scrollView.scrollIndicatorInsets = contentInsets
//        self.view.endEditing(true)
//        self.scrollView.isScrollEnabled = false
//
//    }
//
//
//
//    /*
//     // MARK: - Navigation
//
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//
//}
//
////******************************
////UITextField functions
////******************************
//
////MARK: - Text Field Delegate
//
//extension TaskSettingsViewController: UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        if textField == occurranceTextField {
//
//            // We only want the last character input to be in this field
//            // current characters will be removed and the last input character will be added
//
//            if string == "." {
//                return false
//            } else {
//                textField.text = ""
//                print(textField.text!)
//            }
//        }
//
//        return true
//
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField){
//        activeTextField = textField
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField){
//        activeTextField = nil
//    }
//
//    @objc func doneOccurrence() {
//        occurranceTextField.resignFirstResponder()
//    }
//
//}
//
////******************************
////UIPickerView functions
////******************************
//
////MARK: - Picker View Delegate
//
//extension TaskSettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//        selectedHours = pickerData[0][timePickerView.selectedRow(inComponent: 0)]
//        selectedMinutes = pickerData[1][timePickerView.selectedRow(inComponent: 1)]
//
//        if selectedHours == "0" && selectedMinutes != "0" {
//            timeTextField.text = selectedMinutes + " minutes"
//        } else if selectedHours != "0" && selectedMinutes  == "0" {
//            timeTextField.text = selectedHours + " hours"
//        } else if selectedHours != "0" && selectedMinutes != "0" {
//            timeTextField.text = selectedHours + " hours " + selectedMinutes + " minutes"
//        }
//
//        selectedFromPicker = pickerView.view(forRow: row, forComponent: component) as! UILabel
//
//        pickerView.reloadAllComponents()
//
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return pickerData[component].count
//    }
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 2
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[component][row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return CGFloat(100.0)
//    }
//
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//
//        let pickerLabel = UILabel()
//        let text = pickerData[component][row]
//
//        pickerLabel.text = text
//        //pickerLabel.textAlignment = NSTextAlignment.center
//        pickerLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        pickerLabel.layer.masksToBounds = true
//        pickerLabel.layer.cornerRadius = 5.0
//
//        if let lb = pickerView.view(forRow: row, forComponent: component) as? UILabel {
//
//            selectedFromPicker = lb
//            //selectedFromPicker.backgroundColor = UIColor.orange
//            //selectedFromPicker.textColor = UIColor.white
//            if component == 0 {
//                selectedFromPicker.text = text + " hours"
//            } else if component == 1 {
//                selectedFromPicker.text = text + " minutes"
//            }
//
//        }
//        
//        return pickerLabel
//
//    }
//
//    @objc func donePicker() {
//        timeTextField.resignFirstResponder()
//    }
//
//    @objc func cancelPicker() {
//        timeTextField.resignFirstResponder()
//        timeTextField.text = ""
//    }
//
//}
//
