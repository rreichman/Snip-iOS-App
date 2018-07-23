//
//  WriterHeaderCollectionCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import IGListKit
import Nuke

class WriterHeaderCollectionCell: UICollectionViewCell, ListBindable {
    var model: WriterHeaderViewModel? {
        didSet {
            bindView()
        }
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let model = viewModel as? WriterHeaderViewModel else { fatalError() }
        self.model = model
    }
    
    func bindView() {
        guard let _ = self.nameLabel, let model = self.model else { return }
        if let urlString = model.avatarUrl, let url = URL(string: urlString) {
            self.avatarImageView.isHidden = false
            self.initalsLabel.isHidden = true
            Nuke.loadImage(with: url, into: self.avatarImageView)
        } else {
            self.avatarImageView.isHidden = true
            self.initalsLabel.isHidden = false
            self.initalsLabel.text = model.initials
        }
        
        self.nameLabel.text = model.writerName
    }

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var initalsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bindView()
    }

}
