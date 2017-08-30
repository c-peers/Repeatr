//
//  AppSettingsViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/28/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation
import UIKit
import Chameleon

class AppSettingsViewController: UITableViewController {
    
    @IBOutlet weak var setColorLabel: UILabel!
    @IBOutlet weak var setResetTimeLabel: UILabel!
    @IBOutlet var nightModeSwitch: UISwitch!
    
    var appData = AppData()
    
    // MARK: - Initializers
    
//    convenience init() {
//        self.init(style: .grouped)
//    }
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setColorLabel.text = String(describing: appData.appColor)
        setResetTimeLabel.text = "1:00"
        
        nightModeSwitch.isOn = false
        
        title = "Application Settings"

//        tableView.rowHeight = 50
//        
//        dataSource.sections = [
//            Section(header: "Theme and Color", rows: [
//                Row(text: "Theme Color", detailText: "Detail", selection: {
//                    let colorVC = ColorSettingsViewController()
//                    //present(vc, animated: true, completion: nil)
//                    self.navigationController?.pushViewController(colorVC, animated: true)
//                    
//                }, accessory: .disclosureIndicator, cellClass: Value1Cell.self),
//                ], footer: "This is a section footer."),
//            Section(header: "Reset", rows: [
//                Row(text: "Reset Time", detailText: "Detail", selection: {
//                    let colorVC = ColorSettingsViewController()
//                    colorVC.appData = self.appData
//                    self.navigationController?.pushViewController(colorVC, animated: true)
//                }, accessory: .disclosureIndicator, cellClass: Value1Cell.self),
//                Row(text: "Disclosure Indicator", accessory: .disclosureIndicator),
//                Row(text: "Checkmark", accessory: .checkmark),
//                ], footer: "Try tapping the ⓘ buttons."),
//            Section(header: "Selection", rows: [
//                Row(text: "Tap this row", selection: { [unowned self] in
//                    
//                    //self.showAlert(title: "Row Selection")
//                }),
////                Row(text: "Tap this row", selection: { [unowned self] in
////                    let viewController = ViewController()
////                    self.navigationController?.pushViewController(viewController, animated: true)
////                })
//                ]),
//        ]
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        self.setThemeUsingPrimaryColor(appData.appColor, withSecondaryColor: UIColor.clear, andContentStyle: .contrast)
//        
//    }
    
    func setTextColor() {
        
        let navigationBar = navigationController?.navigationBar
        let toolbar = navigationController?.toolbar
        
        if darknessCheck() {
            
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
    
    func darknessCheck(for color:UIColor? = nil) -> Bool {
        
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        
        let bgColor = navigationController?.navigationBar.barTintColor
        bgColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if r  < 0.7 && g  < 0.7 && b < 0.7 {
            return true
        } else {
            return false
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
            performSegue(withIdentifier: "colorSettingsSegue", sender: self)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if appData.isNightMode {
            cell.contentView.backgroundColor = FlatBlack()
        } else {
            cell.contentView.backgroundColor = UIColor.white
        }
        
    }
    
    @IBAction func nightModeSelected(_ sender: UISwitch) {
        
        if sender.isOn == true {
            print("Night mode enabled")
            appData.isNightMode = true
            
            setNightMode(to: true)
            
            save()
            
        } else {
            print("Night mode disabled")
            appData.isNightMode = false
            
            setNightMode(to: false)
            
            save()
            
        }
        
    }
    
    func setNightMode(to nightModeEnabled: Bool) {
        
        if nightModeEnabled {
            
            UIView.animate(withDuration: 0.3) {

                self.view.backgroundColor = FlatBlack()
                
                self.navigationController?.navigationBar.barTintColor = FlatBlackDark()
                self.navigationController?.toolbar.barTintColor = FlatBlackDark()

                self.navigationController?.navigationBar.layoutIfNeeded()
                
                self.tableView.backgroundColor = FlatBlack()
                //self.tableView.backgroundView?.backgroundColor = FlatBlack()
                self.tableView.reloadData()
                
            }
            
        } else {
            
            UIView.animate(withDuration: 0.3) {
                
                self.view.backgroundColor = UIColor.white
                self.tableView.backgroundColor = UIColor.white
            
                self.tableView.backgroundColor = UIColor.white
                //self.tableView.backgroundView?.backgroundColor = FlatBlack()
                self.tableView.reloadData()
                
                self.setTheme()
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateColorChange()
        setTextColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = "Settings"
    }
    
    private func animateColorChange() {
        guard let coordinator = self.transitionCoordinator else {
            return
        }
        
        coordinator.animate(alongsideTransition: {
            [weak self] context in
            self?.setTheme()
            }, completion: nil)
    }
    
    private func setTheme() {
        //setThemeUsingPrimaryColor(self.appData.appColor, withSecondaryColor: UIColor.clear, andContentStyle: .contrast)
        navigationController?.navigationBar.barTintColor = appData.appColor
        navigationController?.toolbar.barTintColor = appData.appColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "colorSettingsSegue" {
            
            let colorSettingsVC = segue.destination as! ColorSettingsViewController
            colorSettingsVC.appData = appData
            
        }
    }
    
    func save() {
        
        appData.saveAppSettingsToDictionary()
        appData.save()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.appData.saveAppSettingsToDictionary()
        appDelegate.appData.save()
        
    }
    
}
