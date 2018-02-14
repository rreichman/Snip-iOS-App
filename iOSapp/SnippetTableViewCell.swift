//
//  MealTableViewCell.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/24/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class SnippetTableViewCell: UITableViewCell
{
    @IBOutlet weak var snippetView: SnippetView!
    
    var m_isTextLongEnoughToBeTruncated : Bool = true
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
