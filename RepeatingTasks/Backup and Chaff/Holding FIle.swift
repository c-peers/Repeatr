//
//  Holding FIle.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/12/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import Foundation

class Holding {
    
    
//    func formatTimer(for task: String, from cell: RepeatingTasksCollectionCell? = nil, decrement: Bool) -> (String, Int) {
//        // Used for initialization and when the task timer is updated
//        
//        taskData.setTask(as: task)
//        
//        let (taskTime, weightedTaskTime) = getWeightedTime(for: task)
//        let completedTime = taskData.completedTime
//        
//        var remainingTaskTime = weightedTaskTime - completedTime
//        
//        print("Completed time is \(completedTime)")
//        
//        if decrement {
//            remainingTaskTime -= 1
//        }
//        
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .positional
//        
//        var remainingTimeAsString = formatter.string(from: TimeInterval(remainingTaskTime))!
//        
//        if remainingTaskTime == 0 {
//            remainingTimeAsString = "Complete"
//        }
//        
//        if (cell != nil) {
//            
//            let currentProgress = 1 - Float(remainingTaskTime)/Float(taskTime)
//            
//            cell!.progressView.setProgress(currentProgress, animated: true)
//            
//            print("Current progress is \(currentProgress)")
//            
//            cell!.taskTimeRemaining.text = remainingTimeAsString
//            
//        }
//        
//        return (remainingTimeAsString, remainingTaskTime)
//        
//    }

    
}

//func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    
//    var reuseIdentifier: String?
//    
//    
//    // TODO: add multiple cell types
//    if true {
//        reuseIdentifier = "taskCollectionCell_Line"
//    } else {
//        reuseIdentifier = "taskCollectionCell_Circle"
//    }
//    
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier!, for: indexPath as IndexPath) as! RepeatingTasksCollectionCell
//    
//    let task = tasks[indexPath.row]
//    
//    if taskTimer.isEnabled && task == selectedTask {
//        cell.playStopButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
//    } else {
//        cell.playStopButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
//    }
//    
//    cell.playStopButton.backgroundColor = UIColor.clear
//    
//    cell.taskNameField.text = task
//    
//    (_, _) = taskTimer.formatTimer(name: task, from: cell, dataset: taskData)
//    
//    let formatter = DateComponentsFormatter()
//    formatter.allowedUnits = [.hour, .minute, .second]
//    formatter.unitsStyle = .positional
//    
//    //cell.taskTimeRemaining.text = formatter.string(from: TimeInterval(Task.instance.timer.remainingTime))!
//    //cell.taskTimeRemaining.text = formatter.string(from: TimeInterval(countdownTimer.remainingTime))!
//    
//    if cell.taskTimeRemaining.text == "Complete" {
//        cell.playStopButton.isEnabled = false
//    } else {
//        cell.playStopButton.isEnabled = true
//    }
//    
//    //let colorArray = ColorSchemeOf(.analogous, color: .flatSkyBlue, isFlatScheme: true)
//    
//    print(indexPath)
//    
//    //let gradientBackground = GradientColor(.leftToRight, frame: cell.frame, colors: [UIColor.flatSkyBlue, UIColor.flatSkyBlueDark])
//    
//    //cell.backgroundColor = gradientBackground
//    
//    let cellBGColor = appData.colorScheme[indexPath.row % 4]
//    cell.backgroundColor = cellBGColor
//    
//    if appData.darknessCheck(for: cellBGColor) {
//        cell.taskNameField.textColor = .white
//        cell.taskTimeRemaining.textColor = .white
//    } else {
//        cell.taskNameField.textColor = .black
//        cell.taskTimeRemaining.textColor = .black
//    }
//    
//    let borderColor = cellBGColor.darken(byPercentage: 0.3)?.cgColor
//    
//    //        cell.layer.borderColor = borderColor
//    //        cell.layer.cornerRadius = 10.0
//    //        cell.layer.borderWidth = 2.5
//    cell.layer.masksToBounds = false
//    setBorder(for: cell.layer, borderWidth: 2.5, borderColor: borderColor!, radius: 10.0)
//    
//    cell.layer.shadowColor = UIColor.black.cgColor
//    cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)// CGSize.zero
//    cell.layer.shadowRadius = 2.0
//    cell.layer.shadowOpacity = 1.0
//    
//    cell.layer.shadowPath = UIBezierPath(roundedRect: cell.layer.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
//    
//    cell.progressView.barHeight = 6.0
//    //cell.progressView.transform = cell.progressView.transform.scaledBy(x: 1.0, y: 2.0)
//    //        cell.progressView.layer.borderWidth = 0.2
//    //        cell.progressView.layer.borderColor = borderColor
//    //        cell.progressView.layer.cornerRadius = 5.0
//    setBorder(for: cell.progressView.layer, borderWidth: 0.2, borderColor: borderColor!, radius: 5.0)
//    cell.progressView.progress = 0.0
//    cell.progressView.setProgress(0.0, animated: false)
//    //cell.progressView.progressTintColor = UIColor.darkGray
//    cell.progressView.clipsToBounds = true
//    
//    if taskDayCheck(for: task, at: currentDay) {
//        
//        cell.playStopButton.isHidden = false
//        cell.progressView.isHidden = false
//        
//        accessCheck(for: task)
//        
//    } else {
//        
//        cell.playStopButton.isHidden = true
//        cell.taskTimeRemaining.text = "No task today"
//        cell.progressView.isHidden = true
//        
//    }
//    
//    return cell
//    
//}

