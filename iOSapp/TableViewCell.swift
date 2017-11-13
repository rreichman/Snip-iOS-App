//
//  MealTableViewCell.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/24/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell
{
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var imageDescription: UITextView!
    @IBOutlet weak var postTimeAndWriter: UITextView!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var headline: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
