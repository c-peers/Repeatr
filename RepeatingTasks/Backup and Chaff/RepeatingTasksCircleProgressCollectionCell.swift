//
//  RepeatingTasksCircleProgressCollectionCell.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 10/12/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import KDCircularProgress

class RepeatingTasksCircleProgressCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var playStopButton: UIButton!
    @IBOutlet weak var taskNameField: UILabel!
    @IBOutlet weak var taskTimeRemaining: UILabel!
    //@IBOutlet weak var bgView: UIView!    
    @IBOutlet weak var circularProgressView: KDCircularProgress!

}
