//
//  String+Extensions.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/8/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

extension NSAttributedString
{
    internal convenience init?(htmlString: String)
    {
        guard let data = htmlString.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }
        
        /*guard let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], attributes: attributes) else {
            return nil
        }*/
        //let options : [NSAttributedString.DocumentReadingOptionKey : NSAttributedString.DocumentType] =
        
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString: attributedString)
    }
}
