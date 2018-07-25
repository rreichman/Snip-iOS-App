//
//  NotificationPromptController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 7/22/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

protocol NotificationPromptDelegate: class {
    func onNotificationsRequested()
    func onNotificationsDismissed()
}

class NotificationPromptController: ListSectionController {
    weak var delegate: NotificationPromptDelegate?
    let promptMessage: String = "Tap here to enable notifications and stay up to date on your favorite topics."
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { fatalError() }
        // Button width: 24, Right padding: 16, Seperation between button and label: 10, Total: 50
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 50)
        let labelHeight = TextSize.size(promptMessage, font: UIFont.lato(size: 15), width: width, insets: insets).height
        
        // Top and Bottom padding of 20
        return CGSize(width: width, height: labelHeight + 40)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "NotificationPromptCollectionCell", bundle: nil, for: self, at: index) as? NotificationPromptCollectionCell else {
            fatalError()
        }
        cell.delegate = self.delegate
        cell.promptText = self.promptMessage
        return cell
    }
    
    override func didUpdate(to object: Any) {
        guard let _ = object as? NotificationPromptViewModel else {
            fatalError()
        }
    }
}
