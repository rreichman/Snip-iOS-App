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
    
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var address: String!
    var amountString: String!
    
    
    var delegate: TransactionSummaryViewDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        if address != nil {
            setAddressAndAmount(to: self.address, with: self.amountString)
        }
    }
    
    func setDelegate(del: TransactionSummaryViewDelegate) {
        self.delegate = del
    }
    
    func setAddressAndAmount(to address: String, with amount: String) {
        self.address = address
        self.amountString = amount
        
        if let _ = self.amountLabel {
            amountLabel!.text = amount
            addressLabel!.text = "to \(address[..<address.index(address.startIndex, offsetBy:6)])...\(address[address.index(address.endIndex, offsetBy:-6)...])"
        }
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
