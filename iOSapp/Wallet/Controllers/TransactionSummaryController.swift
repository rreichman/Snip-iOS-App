//
//  TransactionSummaryController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 4/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol TransactionSummaryViewDelegate: class {
    func finishedViewing()
}

class TransactionSummaryController: UIViewController {
    
    var delegate: TransactionSummaryViewDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setDelegate(del: TransactionSummaryViewDelegate) {
        self.delegate = del
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    @IBAction func onDonePressed() {
        delegate.finishedViewing()
    }
    
    
}
