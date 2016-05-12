//
//  settingCell.swift
//  HoloWAN_Recoder
//
//  Created by 史凯迪 on 16/5/11.
//  Copyright © 2016年 msy. All rights reserved.
//

import UIKit

class settingFreqCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    let dropDown = DropDown();
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func selectAction(sender: AnyObject) {
        if dropDown.hidden {
            dropDown.show()
        } else {
            dropDown.hide()
        }
    }
}

class settingPktSizeCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var input: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}