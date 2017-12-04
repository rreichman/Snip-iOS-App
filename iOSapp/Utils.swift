//
//  Tools.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/13/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func getAuthorizationString() -> String
{
    var tokenDeclarationString: String = "Token "
    let tokenValueString: String = UserInformation().getUserInfo(key: "key")
    tokenDeclarationString.append(tokenValueString)
    
    return tokenDeclarationString
}

func getDefaultURLRequest(serverString: String, csrfValue : String) -> URLRequest
{
    let url: URL = URL(string: serverString)!
    var urlRequest: URLRequest = URLRequest(url: url)
    
    urlRequest.httpMethod = "POST"
    urlRequest.setValue(csrfValue, forHTTPHeaderField: "X-CSRFTOKEN")
    urlRequest.setValue(SystemVariables().URL_STRING, forHTTPHeaderField: "Referer")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    if (UserInformation().isUserLoggedIn())
    {
        urlRequest.setValue(getAuthorizationString(), forHTTPHeaderField: "Authorization")
    }
    
    return urlRequest
}

func storeUserInformation(authenticationToken : String)
{
    // TODO:: allow these to come back by receiving them from server
    //UserInformation().setUserInfo(key: UserInformation().emailKey, value: self.emailSignupField.text!)
    //UserInformation().setUserInfo(key: UserInformation().firstNameKey, value: self.firstNameSignupField.text!)
    //UserInformation().setUserInfo(key: UserInformation().lastNameKey, value: self.lastNameSignupField.text!)
    UserInformation().setUserInfo(key: UserInformation().authenticationTokenKey, value: authenticationToken)
}

func getUniqueDeviceID() -> String
{
    return UIDevice.current.identifierForVendor!.uuidString
}

func promptToUser(promptMessageTitle: String, promptMessageBody: String, viewController: UIViewController, completionHandler : ((UIAlertAction) -> Void)? = nil)
{
    let alert = UIAlertController(title: promptMessageTitle, message: promptMessageBody, preferredStyle: UIAlertControllerStyle.alert)
    
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: completionHandler))
    
    viewController.present(alert, animated: true, completion: nil)
}

func setConstraintConstantForView(constraintName : String, view : UIView, constant : CGFloat)
{
    for constraint in view.constraints
    {
        if constraint.identifier == constraintName
        {
            constraint.constant = constant
        }
    }
    view.updateConstraints()
}

func removePaddingFromTextView(textView : UITextView)
{
    textView.textContainerInset = UIEdgeInsets.zero
    textView.textContainer.lineFragmentPadding = 0
}

func getWidthOfSingleChar(font : UIFont) -> Float
{
    let text = NSAttributedString(string: "a", attributes: [NSAttributedStringKey.font : font])
    return Float(text.size().width)
}

func addFontAndForegroundColorToView(textView : UITextView, newFont : Any, newColor : Any)
{
    let attributedString : NSMutableAttributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
    attributedString.addAttribute(NSAttributedStringKey.font, value: newFont, range: NSRange(location: 0, length: attributedString.length))
    attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: newColor, range: NSRange(location: 0, length: attributedString.length))
    textView.attributedText = attributedString
}

func getTimeFromDateString(dateString : String) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy HH:mm:ss"
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    let dateAsDataStructure = dateFormatter.date(from : dateString)
    // TODO:: is Rani's format for date different in comments? Go to Foxconn Apple snip
    if (dateAsDataStructure == nil)
    {
        return "error in date"
    }
    
    var displayedTime = ""
    let dateDifferenceInDays = Date().days(from: dateAsDataStructure!)
    if (dateDifferenceInDays < 30)
    {
        if (dateDifferenceInDays == 0)
        {
            let dateDifferenceInHours = Date().hours(from: dateAsDataStructure!)
            if (dateDifferenceInHours == 0)
            {
                let dateDifferenceInMinutes = Date().minutes(from: dateAsDataStructure!)
                if (dateDifferenceInMinutes == 0)
                {
                    let dateDifferenceInSeconds = Date().seconds(from: dateAsDataStructure!)
                    displayedTime.append(String(dateDifferenceInSeconds))
                    displayedTime.append(" secs ago")
                }
                else
                {
                    displayedTime.append(String(dateDifferenceInMinutes))
                    if (dateDifferenceInMinutes == 1)
                    {
                        displayedTime.append(" min ago")
                    }
                    else
                    {
                        displayedTime.append(" mins ago")
                    }
                }
            }
            else
            {
                displayedTime.append(String(dateDifferenceInHours))
                if (dateDifferenceInHours == 1)
                {
                    displayedTime.append(" hour ago")
                }
                else
                {
                    displayedTime.append(" hours ago")
                }
            }
        }
        else
        {
            displayedTime.append(String(dateDifferenceInDays))
            if (dateDifferenceInDays == 1)
            {
                displayedTime.append(" day ago")
            }
            else
            {
                displayedTime.append(" days ago")
            }
        }
    }
    else
    {
        displayedTime = String(dateString.prefix(10))
    }
    return displayedTime
}

public func getLastIndexOfSubstringInString(originalString : String, substring : String) -> Int
{
    return (originalString.range(of: substring, options: .backwards)?.lowerBound.encodedOffset)!
}

func convertDictionaryToJsonString(dictionary: Dictionary<String,String>) -> String
{
    var dictionaryString = ""
    var isFirstKey = true
    
    for key in dictionary.keys
    {
        if !isFirstKey
        {
            dictionaryString.append("&")
        }
        isFirstKey = false
        
        dictionaryString.append(key)
        dictionaryString.append("=")
        dictionaryString.append(dictionary[key]!)
    }
    return dictionaryString
}

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

// Use this for tests
/*let calendar = NSCalendar.current
 var componentSet = Set<Calendar.Component>()
 componentSet.insert(Calendar.Component.year)
 componentSet.insert(Calendar.Component.month)
 componentSet.insert(Calendar.Component.day)
 componentSet.insert(Calendar.Component.hour)
 componentSet.insert(Calendar.Component.minute)
 
 let components = calendar.dateComponents(componentSet, from: dateAsDataStructure!)
 let year = components.year
 let month = components.month
 let day = components.day
 let hour = components.hour
 let minutes = components.minute*/



/*
 Constrainsts stuff
 
 if (setOfCellsNotToTruncate.contains(indexPath.row))
 {
 let referencesTextView = cell.contentView.viewWithTag(999)
 //referencesTextView?.removeFromSuperview()
 if (referencesTextView != nil)
 {
 return cell
 }
 
 //addReferencesToPost(cell : cell, postData: postData)
 let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
 textView.attributedText = NSAttributedString(string: "hello this is a text view which is sub. what is done with this")
 
 textView.tag = 999
 textView.translatesAutoresizingMaskIntoConstraints = false
 cell.contentView.addSubview(textView)
 
 print("here\n\n\n")
 for view in cell.contentView.subviews
 {
 print("Another view: \(view)\n\n")
 print(view.constraints)
 print("\n\n\n")
 }
 //print("imageview constraints")
 //print(cell.imageView?.constraints)
 
 let constraintBelowImage = NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: cell.imageView, attribute: .top, multiplier: 1, constant: 0)
 cell.contentView.addConstraint(constraintBelowImage)
 _tableView.updateConstraints()
 }
 else
 {
 //cell.likeButton.isHidden = true
 //cell.references.isHidden = true
 }
 
 */
