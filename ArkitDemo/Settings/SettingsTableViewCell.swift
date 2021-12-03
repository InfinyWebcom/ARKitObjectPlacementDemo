//
//  SettingsTableViewCell.swift
//  ArkitDemo
//
//  Created by Siddhesh on 22/11/21.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingNameLal: UILabel!
    @IBOutlet weak var SettingOnOffSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
