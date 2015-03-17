//
//  JobTableViewCell.swift
//  JobSearch
//
//  Created by Gelei Chen on 15/3/7.
//  Copyright (c) 2015年 Purdue Bang. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {

    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tags: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
