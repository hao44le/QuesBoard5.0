//
//  CustomTableViewCell.swift
//  JobSearch
//
//  Created by Carl Chen on 3/7/15.
//  Copyright (c) 2015 Purdue Bang. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var imageView1: UIImageView!

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var textField1: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
