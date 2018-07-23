//
//  NotificationPromptCollectionCell.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit
import IGListKit

class NotificationPromptCollectionCell: UICollectionViewCell, ListBindable {
    
    var promptText: String? {
        didSet {
            bindView()
        }
    }
    func bindViewModel(_ viewModel: Any) {
        // No Usable Information comes from the view model
        bindView()
    }
    
    func bindView() {
        guard let _ = self.promptLabel else { return }
        self.promptLabel.text = promptText
    }
    
    
    weak var delegate: NotificationPromptDelegate?
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var promptLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindView()
        closeButton.addTarget(self, action: #selector(notificationsDismissed), for: .touchUpInside)
        
        self.contentView.isUserInteractionEnabled = true
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationsRequested)))
    }
    
    @objc func notificationsDismissed() {
        if let d = self.delegate {
            d.onNotificationsDismissed()
        }
    }
    
    @objc func notificationsRequested() {
        if let d = self.delegate {
            d.onNotificationsRequested()
        }
    }

}
