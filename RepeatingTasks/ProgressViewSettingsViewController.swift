//
//  ProgressViewSettingsViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 9/1/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

class ProgressViewSettingsViewController: UITableViewController {
    
    var appData = AppData()
    
    var previouslySelectedCell: IndexPath?
    
    var progressStyle = ["Flat", "Circular"]
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        
        self.title = "Progress View"
        
        //tableView.sectionIndexColor = UIColor.black
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressViewStyleCell", for: indexPath)
        
        if previouslySelectedCell != nil {
            
            let previousCell = tableView.dequeueReusableCell(withIdentifier: "ProgressViewStyleCell", for: previouslySelectedCell!)
            previousCell.accessoryType = .none
            previousCell.selectionStyle = .none
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        cell.accessoryType = .checkmark
        cell.textLabel?.text = progressStyle[indexPath.row]
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.contentView.backgroundColor = UIColor.white
            cell.accessoryView?.backgroundColor = UIColor.white
            cell.backgroundColor = UIColor.white
            
        })
        
        previouslySelectedCell = indexPath
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if progressStyle[indexPath.row] == "Circular" {
            appData.usesCircularProgress = true
            appDelegate.appData.usesCircularProgress = true
        } else {
            appData.usesCircularProgress = false
            appDelegate.appData.usesCircularProgress = false
        }
        
        appDelegate.appData.save()
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressViewStyleCell", for: indexPath)
        
        cell.accessoryType = .none
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progressStyle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressViewStyleCell", for: indexPath)
        
        cell.textLabel?.text = progressStyle[indexPath.row]
        
        return cell
    }
    
}
