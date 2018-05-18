//
//  NewCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

class NewCell : UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var commentInput: UITextInput!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    
    @IBOutlet var cellView: UIView!
    
}
