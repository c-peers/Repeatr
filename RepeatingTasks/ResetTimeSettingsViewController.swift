//
//  ResetTimeSettingsViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/31/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

class ResetTimeSettingsViewController: UITableViewController {

    var appData = AppData()
    
    var previouslySelectedCell: IndexPath?
    
    var resetTimes = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM"]
    var resetTimes24H = ["0:00", "1:00", "2:00", "3:00", "4:00"]
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        
        self.title = "Reset Time"
        
        //tableView.sectionIndexColor = UIColor.black
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResetTimeCell", for: indexPath)
        
        if previouslySelectedCell != nil {
            
            let previousCell = tableView.dequeueReusableCell(withIdentifier: "ResetTimeCell", for: previouslySelectedCell!)
            previousCell.accessoryType = .none
            previousCell.selectionStyle = .none
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        cell.accessoryType = .checkmark
        cell.textLabel?.text = resetTimes[indexPath.row]
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.contentView.backgroundColor = UIColor.white
            cell.accessoryView?.backgroundColor = UIColor.white
            cell.backgroundColor = UIColor.white
            
        })
        
        appData.resetOffset = resetTimes[indexPath.row]
        
        previouslySelectedCell = indexPath
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        appDelegate.appData.resetOffset = resetTimes[indexPath.row]
        
        print(appDelegate.appData.resetOffset)
        appDelegate.appData.save()
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResetTimeCell", for: indexPath)
        
        cell.accessoryType = .none
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.white
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resetTimes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResetTimeCell", for: indexPath)
        
        cell.textLabel?.text = resetTimes[indexPath.row]
        
        return cell
    }

}
