//
//  MealTableViewCell.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/24/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell
{
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellHeadline: UILabel!
    var isTruncated: Bool = true;
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
