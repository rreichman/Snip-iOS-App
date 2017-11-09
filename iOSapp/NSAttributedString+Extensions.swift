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
    internal convenience init?(htmlString: String, font : UIFont)
    {
        guard let data = htmlString.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }
        
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        attributedString.addAttribute(NSAttributedStringKey.font, value: font, range: NSRange(location: 0,length: attributedString.length))
        
        self.init(attributedString: attributedString)
    }
}
