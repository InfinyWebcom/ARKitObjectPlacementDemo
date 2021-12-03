//
//  SettingsViewController.swift
//  ArkitDemo
//
//  Created by Siddhesh on 22/11/21.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let settings = ["Add object on Vertical Surface",
                    "Add object on both Vertical and Horizontal Surface",
                    "Lock Object"]
    
    let defaults = UserDefaults.standard
    var settingsChanged = false
    var updateSession: ((Bool?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 300, height: 225)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true)
        if let cb = self.updateSession{
            cb(settingsChanged)
        }
    }
    
    
    @IBAction func ToggleSettings(_ sender: UISwitch) {
        settingsChanged = true
        if sender.tag == 0{
            defaults.set(sender.isOn, for: .verticalPlane)
            if sender.isOn{
                defaults.set(false, for: .horizontalAndVerticalPlane)
            }
        }else if sender.tag == 1{
            defaults.set(sender.isOn, for: .horizontalAndVerticalPlane)
            if sender.isOn{
                defaults.set(false, for: .verticalPlane)
            }
        }else if sender.tag == 2{
            defaults.set(sender.isOn, for: .lockObject)
        }
        
        self.tableView.reloadData()
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        
        cell.settingNameLal.text = settings[index]
        cell.SettingOnOffSwitch.tag = index
        
        if index == 0{
            cell.SettingOnOffSwitch.setOn(defaults.bool(forKey: Settings.verticalPlane.rawValue), animated: false)
        }else if index == 1{
            cell.SettingOnOffSwitch.setOn(defaults.bool(forKey: Settings.horizontalAndVerticalPlane.rawValue), animated: false)
        }else if index == 2{
            cell.SettingOnOffSwitch.setOn(defaults.bool(forKey: Settings.lockObject.rawValue), animated: false)
        }
        
        return cell
    }
    
}
