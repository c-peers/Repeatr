//
//  ColorSettingsViewController.swift
//  RepeatingTasks
//
//  Created by Chase Peers on 8/28/17.
//  Copyright © 2017 Chase Peers. All rights reserved.
//

import UIKit
import Chameleon

class ColorSettingsViewController: UITableViewController {
    
    var appData = AppData()
    
    var previouslySelectedCell: IndexPath?
    var selectedColor: UIColor?
    
    var colors = ["Black",
                  "Blue",
                  "Brown",
                  "Coffee",
                  "Forest Green",
                  "Gray",
                  "Green",
                  "Lime",
                  "Magenta",
                  "Maroon",
                  "Mint",
                  "Navy Blue",
                  "Orange",
                  "Pink",
                  "Plum",
                  "Powder Blue",
                  "Purple",
                  "Red",
                  "Sand",
                  "Sky Blue",
                  "Teal",
                  "Watermelon",
                  "White",
                  "Yellow",
                  "Dark Black",
                  "Dark Blue",
                  "Dark Brown",
                  "Dark Coffee",
                  "Dark Forest Green",
                  "Dark Gray",
                  "Dark Green",
                  "Dark Lime",
                  "Dark Magenta",
                  "Dark Maroon",
                  "Dark Mint",
                  "Dark Navy Blue",
                  "Dark Orange",
                  "Dark Pink",
                  "Dark Plum",
                  "Dark Powder Blue",
                  "Dark Purple",
                  "Dark Red",
                  "Dark Sand",
                  "Dark Sky Blue",
                  "Dark Teal",
                  "Dark Watermelon",
                  "Dark White",
                  "Dark Yellow",
                  "Random color"]
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {

        self.title = "Theme Color"
        
        tableView.sectionIndexColor = UIColor.black
        
        
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ColorCell")
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        
        if previouslySelectedCell != nil {
            
            let previousCell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: previouslySelectedCell!)
            previousCell.accessoryType = .none
            previousCell.selectionStyle = .none
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        cell.accessoryType = .checkmark
        cell.textLabel?.text = colors[indexPath.row]
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.contentView.backgroundColor = UIColor.white
            cell.accessoryView?.backgroundColor = UIColor.white
            cell.backgroundColor = UIColor.white

        })
   
        setColor(as: colors[indexPath.row])
        
        print(colors[indexPath.row])
        
        previouslySelectedCell = indexPath

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        
        cell.accessoryType = .none
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        
        cell.textLabel?.text = colors[indexPath.row]
        
        return cell
    }
        
    func setColor(as color: String) {
    
        if color.range(of:"Dark") == nil {
            switch color {
            case "Black":
                selectedColor = FlatBlack()
            case "Blue":
                selectedColor = FlatBlue()
            case "Brown":
                selectedColor = FlatBrown()
            case "Coffee":
                selectedColor = FlatCoffee()
            case "Forest Green":
                selectedColor = FlatForestGreen()
            case "Gray":
                selectedColor = FlatGray()
            case "Green":
                selectedColor = FlatGreen()
            case "Lime":
                selectedColor = FlatLime()
            case "Magenta":
                selectedColor = FlatMagenta()
            case "Maroon":
                selectedColor = FlatMaroon()
            case "Mint":
                selectedColor = FlatMint()
            case "Navy Blue":
                selectedColor = FlatNavyBlue()
            case "Orange":
                selectedColor = FlatOrange()
            case "Pink":
                selectedColor = FlatPink()
            case "Plum":
                selectedColor = FlatPlum()
            case "Powder Blue":
                selectedColor = FlatPowderBlue()
            case "Purple":
                selectedColor = FlatPurple()
            case "Red":
                selectedColor = FlatRed()
            case "Sand":
                selectedColor = FlatSand()
            case "Sky Blue":
                selectedColor = FlatSkyBlue()
            case "Teal":
                selectedColor = FlatTeal()
            case "Watermelon":
                selectedColor = FlatWatermelon()
            case "White":
                selectedColor = FlatWhite()
            case "Yellow":
                selectedColor = FlatYellow()
            case "Random color":
                selectedColor = RandomFlatColor()
            default:
                selectedColor = FlatBlue()
            }
        } else {
            switch color {
            case "Dark Black":
                selectedColor = FlatBlackDark()
            case "Dark Blue":
                selectedColor = FlatBlueDark()
            case "Dark Brown":
                selectedColor = FlatBrownDark()
            case "Dark Coffee":
                selectedColor = FlatCoffeeDark()
            case "Dark Forest Green":
                selectedColor = FlatForestGreenDark()
            case "Dark Gray":
                selectedColor = FlatGrayDark()
            case "Dark Green":
                selectedColor = FlatGreenDark()
            case "Dark Lime":
                selectedColor = FlatLimeDark()
            case "Dark Magenta":
                selectedColor = FlatMagentaDark()
            case "Dark Maroon":
                selectedColor = FlatMaroonDark()
            case "Dark Mint":
                selectedColor = FlatMintDark()
            case "Dark Navy Blue":
                selectedColor = FlatNavyBlueDark()
            case "Dark Orange":
                selectedColor = FlatOrangeDark()
            case "Dark Pink":
                selectedColor = FlatPinkDark()
            case "Dark Plum":
                selectedColor = FlatPlumDark()
            case "Dark Powder Blue":
                selectedColor = FlatPowderBlueDark()
            case "Dark Purple":
                selectedColor = FlatPurpleDark()
            case "Dark Red":
                selectedColor = FlatRedDark()
            case "Dark Sand":
                selectedColor = FlatSandDark()
            case "Dark Sky Blue":
                selectedColor = FlatSkyBlueDark()
            case "Dark Teal":
                selectedColor = FlatTealDark()
            case "Dark Watermelon":
                selectedColor = FlatWatermelonDark()
            case "Dark White":
                selectedColor = FlatWhiteDark()
            case "Dark Yellow":
                selectedColor = FlatYellowDark()
            default:
                selectedColor = FlatBlue()
            }
            
        }
    
        appData.appColor = selectedColor!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setTheme(as: selectedColor!)

        appDelegate.appData.appColorName = color
        appDelegate.appData.saveColorSettingsToDictionary()
        appDelegate.appData.save()
        
        //appData.saveColorSettingsToDictionary()
        //appData.save()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        self.setThemeUsingPrimaryColor(appData.appColor, withSecondaryColor: UIColor.clear, andContentStyle: .contrast)
//        
//    }
    
    override func willMove(toParentViewController parent: UIViewController?) { // tricky part in iOS 10
        if selectedColor != nil {
            navigationController?.navigationBar.barTintColor = selectedColor
            navigationController?.toolbar.barTintColor = selectedColor
        }
        super.willMove(toParentViewController: parent)
    }
    

    
}
