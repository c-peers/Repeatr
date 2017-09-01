//
//  NewTasksViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 6/16/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

class NewTasksViewController: UIViewController, UIScrollViewDelegate {

    //MARK: - Outlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var statusBarView: UIView!
    
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
    
    @IBOutlet weak var createTaskButton: UIButton!
    
    //MARK: - Properties
    
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
    var selectedFromPicker: UILabel!
    
    var timePickerView = UIPickerView()
    let pickerViewDatasource = TaskTimePicker()
    
    var appData = AppData()
    
    var navigationBar: UINavigationBar?

    //MARK: - View and Basic Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.contentSize.width = view.bounds.width
        
        // Themeing made the buttons blue. This 
        //self.setThemeUsingPrimaryColor(appData.appColor, withSecondaryColor: UIColor.clear, andContentStyle: .contrast)
        
        taskNameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        //******************************
        // Notification Bar
        //******************************
        
        prepareNavBar()
        
        //******************************
        // Occurrence rate start
        //******************************

        let decimalPadToolBar = UIToolbar.init()
        decimalPadToolBar.sizeToFit()
        decimalPadToolBar.barTintColor = appData.appColor
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
        pickerToolBar.barTintColor = appData.appColor
        //pickerToolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
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

        let bgColor = navigationBar?.barTintColor
        
        if appData.darknessCheck(for: bgColor) {
            
            pickerToolBar.tintColor = UIColor.white
            decimalPadToolBar.tintColor = UIColor.white
            
        } else {
            
            pickerToolBar.tintColor = UIColor.black
            decimalPadToolBar.tintColor = UIColor.black

        }

        //******************************
        // Day selection start
        //******************************

        sunday.layer.borderWidth = 1
        sunday.layer.borderColor = appData.appColor.cgColor
        monday.layer.borderWidth = 1
        monday.layer.borderColor = appData.appColor.cgColor
        tuesday.layer.borderWidth = 1
        tuesday.layer.borderColor = appData.appColor.cgColor
        wednesday.layer.borderWidth = 1
        wednesday.layer.borderColor = appData.appColor.cgColor
        thursday.layer.borderWidth = 1
        thursday.layer.borderColor = appData.appColor.cgColor
        friday.layer.borderWidth = 1
        friday.layer.borderColor = appData.appColor.cgColor
        saturday.layer.borderWidth = 1
        saturday.layer.borderColor = appData.appColor.cgColor

        sunday.tag = 0
        monday.tag = 0
        tuesday.tag = 0
        wednesday.tag = 0
        thursday.tag = 0
        friday.tag = 0
        saturday.tag = 0
        
        createTaskButton.layer.borderColor = appData.appColor.cgColor
        createTaskButton.layer.borderWidth = 2
        createTaskButton.layer.cornerRadius = 10.0
        
        createTaskButton.setTitleColor(appData.appColor, for: .normal)
        
    }
    
    func prepareNavBar() {
        
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 44))
        self.view.addSubview(navigationBar!);
        let navItem = UINavigationItem(title: "Add Task");
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelTask))
        navItem.leftBarButtonItems = [cancelBarButton]
        
        navigationBar?.setItems([navItem], animated: false);
        
        setTheme()
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func setTheme() {
        
        statusBarView.backgroundColor = appData.appColor
        statusBarView.alpha = 0.85 // Needed to match translucent navBar
        
        //let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        //navBar.isTranslucent = false

        navigationBar?.barTintColor = appData.appColor
        
        let toolbar = navigationController?.toolbar
        toolbar?.barTintColor = appData.appColor
        
        if appData.isNightMode {
            NightNight.theme = .night
        } else {
            NightNight.theme = .normal
        }
        
        let bgColor = navigationBar?.barTintColor
        
        if appData.darknessCheck(for: bgColor) {
            
            navigationBar?.tintColor = UIColor.white
            navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            toolbar?.tintColor = UIColor.white
            setStatusBarStyle(.lightContent)
            
        } else {
            
            navigationBar?.tintColor = UIColor.black
            navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
            toolbar?.tintColor = UIColor.black
            setStatusBarStyle(.default)
        }
        
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
    
    //MARK: - Button Actions/Functions
    
    func buttonAction(for button: UIButton) {
        
        if button.tag == 0 {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                button.layer.backgroundColor = self.appData.appColor.cgColor
                button.setTitleColor(UIColor.white, for: .normal)
            })
            button.tag = 1
        } else {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                button.layer.backgroundColor = UIColor.white.cgColor
                button.setTitleColor(UIColor.black, for: .normal)
            })
            button.tag = 0
        }
    
    }
    
    @IBAction func sundayTapped(_ sender: UIButton) {

        if sunday.tag == 0 {
            taskDays.append("Sunday")
        } else {
            taskDays = taskDays.filter { $0 != "Sunday" }
        }
        
        buttonAction(for: sender)
        
    }
    
    @IBAction func mondayTapped(_ sender: UIButton) {

        if monday.tag == 0 {
            taskDays.append("Monday")
        } else {
            taskDays = taskDays.filter { $0 != "Monday" }
        }
        
        buttonAction(for: sender)
        
    }
    
    @IBAction func tuesdayTapped(_ sender: UIButton) {

        if tuesday.tag == 0 {
            taskDays.append("Tuesday")
        } else {
            taskDays = taskDays.filter { $0 != "Tuesday" }
        }
        
        buttonAction(for: sender)
        
    }
    
    @IBAction func wednesdayTapped(_ sender: UIButton) {

        if wednesday.tag == 0 {
            taskDays.append("Wednesday")
        } else {
            taskDays = taskDays.filter { $0 != "Wednesday" }
        }
        
        buttonAction(for: sender)
        
    }
    
    @IBAction func thursdayTapped(_ sender: UIButton) {

        if thursday.tag == 0 {
            taskDays.append("Thursday")
        } else {
            taskDays = taskDays.filter { $0 != "Thursday" }
        }
        
        buttonAction(for: sender)
        
    }
    
    @IBAction func fridayTapped(_ sender: UIButton) {

        if friday.tag == 0 {
            taskDays.append("Friday")
        } else {
            taskDays = taskDays.filter { $0 != "Friday" }
        }
        
        buttonAction(for: sender)
        
    }
    
    @IBAction func saturdayTapped(_ sender: UIButton) {

        if saturday.tag == 0 {
            taskDays.append("Saturday")
        } else {
            taskDays = taskDays.filter { $0 != "Saturday" }
        }
        
        buttonAction(for: sender)
        
    }
    
    
    @IBAction func createTask(_ sender: Any) {

        let taskNameWasEntered = taskNameTextField.hasText
        let taskTimeWasEntered = taskLengthTextField.hasText
        let frequencyWasEntered = occurrenceRateTextField.hasText
        let taskDaysWereEntered = !taskDays.isEmpty
        
        if taskNameWasEntered && taskTimeWasEntered && frequencyWasEntered && taskDaysWereEntered {
            
            performSegue(withIdentifier: "createdTaskUnwindSegue", sender: self)

        } else {
            
            popAlert()
            
        }

    }
    
    func popAlert() {
        
        let alertController = UIAlertController(title: "Warning",
                                                message: "Please fill out all fields to add your task",
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            print("Hello")
        }
        
        alertController.addAction(okAction)
        
        present(alertController,animated: true,completion: nil)
        
    }
    
    //MARK: - Keyoard Functions
    
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
        
        selectedFromPicker = pickerView.view(forRow: row, forComponent: component) as! UILabel
        
        pickerView.reloadAllComponents()

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(100.0)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        let text = pickerData[component][row]
        
        pickerLabel.text = text
        //pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        pickerLabel.layer.masksToBounds = true
        pickerLabel.layer.cornerRadius = 5.0
        
        if let lb = pickerView.view(forRow: row, forComponent: component) as? UILabel {
            
            selectedFromPicker = lb
            //selectedFromPicker.backgroundColor = UIColor.orange
            //selectedFromPicker.textColor = UIColor.white
            if component == 0 {
                selectedFromPicker.text = text + " hours"
            } else if component == 1 {
                selectedFromPicker.text = text + " minutes"
            }
            
        }
        
        return pickerLabel
        
    }
    
    func donePicker() {
        taskLengthTextField.resignFirstResponder()
    }
    
    func cancelPicker() {
        taskLengthTextField.resignFirstResponder()
        taskLengthTextField.text = ""
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
    
    func doneOccurrence() {
        occurrenceRateTextField.resignFirstResponder()
    }
    
    func cancelTask() {
        //navigationController?.popViewController(animated: true)
        //self.removeFromParentViewController()
        //navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
