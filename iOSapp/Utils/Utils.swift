//
//  Tools.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/13/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

let NUMBER_OF_COMMENTS_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().NUMBER_OF_COMMENTS_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().NUMBER_OF_COMMENTS_COLOR]

func getSnippetAreaWidth() -> CGFloat
{
    // TODO: this is not ideal
    let sizeOfLeftBorder = 20
    let sizeOfRightBorder = 20
    
    return CGFloat(Int(CachedData().getScreenWidth()) - sizeOfLeftBorder - sizeOfRightBorder)
}

func getAuthorizationString() -> String
{
    var tokenDeclarationString: String = "Token "
    let tokenValueString: String = UserInformation().getUserInfo(key: "key")
    tokenDeclarationString.append(tokenValueString)
    
    return tokenDeclarationString
}

func getTermsAndConditionsString(color: UIColor) -> NSMutableAttributedString
{
    let termsStringPartOne : String = "By registering you confirm that you accept the "
    let termsStringPartTwo : String = "Terms and Conditions"
    let fullText : String = termsStringPartOne + termsStringPartTwo
    
    let termsAttributedString : NSMutableAttributedString = NSMutableAttributedString(string : fullText)
    
    let linkAttributes : [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.link: "https://media.snip.today/Snip+-+Terms+of+Service.pdf",
        NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
    ]
    
    let style = NSMutableParagraphStyle()
    style.alignment = NSTextAlignment.center
    
    termsAttributedString.addAttributes(linkAttributes, range: NSMakeRange(termsStringPartOne.count, termsStringPartTwo.count))
    termsAttributedString.addAttribute(NSAttributedStringKey.font, value: SystemVariables().TERMS_AND_CONDITIONS_FONT!, range: NSMakeRange(0, fullText.count))
    termsAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSMakeRange(0, fullText.count))
    termsAttributedString.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, fullText.count))
    
    return termsAttributedString
}

func getErrorMessageFromResponse(jsonObj : Dictionary<String, Any>) -> String
{
    var messageString : String = ""
    for key in jsonObj.keys
    {
        if (jsonObj.keys.count > 1)
        {
            messageString.append("\n- ")
        }
        
        var stringResponse : String = "Error"
        
        if (jsonObj[key] is String)
        {
            stringResponse = jsonObj[key] as! String
        }
        else
        {
            stringResponse = (jsonObj[key] as! Array<String>)[0]
        }
        messageString.append(key)
        messageString.append(": ")
        messageString.append(stringResponse)
    }
    
    return messageString
}

func convertDateToCookieString(date: Date) -> String
{
    let formatter = DateFormatter()
    formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss"
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    var res = formatter.string(from: date)
    res.append(" GMT")
    return res
}

func getCookiesForUrlRequest() -> [String]
{
    var cookieString = ""
    var cookieStringArray : [String] = []
    
    for cookie in HTTPCookieStorage.shared.cookies!
    {
        if (cookie.name == "sniptoday")
        {
            cookieString.append(cookie.name)
            cookieString.append("=")
            cookieString.append(cookie.value)
            cookieString.append("; ")
            cookieString.append("path=")
            cookieString.append(cookie.path)
            cookieString.append("; ")
            cookieString.append("domain=")
            cookieString.append(cookie.domain)
            cookieString.append("; ")
            if (cookie.isHTTPOnly)
            {
                cookieString.append("HttpOnly; ")
            }
            if (cookie.expiresDate != nil)
            {
                cookieString.append("Expires=")
                cookieString.append(convertDateToCookieString(date: cookie.expiresDate!))
                cookieString.append(";")
            }
            cookieStringArray.append(cookieString)
        }
        cookieString = ""
    }
    
    return cookieStringArray
}

func getDefaultURLRequest(serverString: String, method: String) -> URLRequest
{
    let url: URL = URL(string: serverString)!
    var urlRequest: URLRequest = URLRequest(url: url)
    
    urlRequest.httpMethod = method
    
    if (UserInformation().isUserLoggedIn())
    {
        urlRequest.setValue(getAuthorizationString(), forHTTPHeaderField: "Authorization")
    }
    
    let cookieStringArray = getCookiesForUrlRequest()
    for cookieString in cookieStringArray
    {
        urlRequest.setValue(cookieString, forHTTPHeaderField: "Cookie")
    }

    urlRequest.setValue(SystemVariables().URL_STRING, forHTTPHeaderField: "Referer")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
}

func storeUserAuthenticationToken(authenticationToken : String)
{
    UserInformation().setUserInfo(key: UserInformation().authenticationTokenKey, value: authenticationToken)
}

func getUniqueDeviceID() -> String
{
    return UIDevice.current.identifierForVendor!.uuidString
}

func promptToUser(promptMessageTitle: String, promptMessageBody: String, viewController: UIViewController, completionHandler : ((UIAlertAction) -> Void)? = nil)
{
    promptToUserWithAutoDismiss(promptMessageTitle: promptMessageTitle, promptMessageBody: promptMessageBody, viewController: viewController, lengthInSeconds: 99999, completionHandler: completionHandler)
}

func promptToUserWithAutoDismiss(promptMessageTitle: String, promptMessageBody: String, viewController: UIViewController, lengthInSeconds: Double, completionHandler : ((UIAlertAction) -> Void)? = nil)
{
    let alert = UIAlertController(title: promptMessageTitle, message: promptMessageBody, preferredStyle: UIAlertControllerStyle.alert)
    let alertAction = UIAlertAction(title: "Ok", style: .default, handler: completionHandler)
    
    alert.addAction(alertAction)
    
    viewController.present(alert, animated: true, completion: nil)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + lengthInSeconds) {
        alert.dismiss(animated: true)
        completionHandler!(alertAction)
    }
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

func getTimeFromDateString(dateString : String) -> String
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy HH:mm:ss"
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    let dateAsDataStructure = dateFormatter.date(from : dateString)
    
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
                    displayedTime.append("s")
                }
                else
                {
                    displayedTime.append(String(dateDifferenceInMinutes))
                    displayedTime.append("m")
                }
            }
            else
            {
                displayedTime.append(String(dateDifferenceInHours))
                displayedTime.append("h")
            }
        }
        else
        {
            displayedTime.append(String(dateDifferenceInDays))
            displayedTime.append("d")
        }
    }
    else
    {
        let calendar = Calendar.current
        
        displayedTime = ""
        displayedTime.append(String(calendar.component(.month, from: dateAsDataStructure!)))
        displayedTime.append("/")
        displayedTime.append(String(calendar.component(.day, from: dateAsDataStructure!)))
        displayedTime.append("/")
        displayedTime.append(String(calendar.component(.year, from: dateAsDataStructure!)))
    }
    return displayedTime
}

func getRowNumberOfClickOnTableView(sender : UITapGestureRecognizer, tableView: UITableView) -> Int
{
    let clickCoordinates = sender.location(in: tableView)
    return tableView.indexPathForRow(at: clickCoordinates)!.row
}

func getAttributedStringOfCommentCount(commentCount: Int) -> NSAttributedString
{
    if (commentCount > 0)
    {
        return NSAttributedString(string: commentCount.description, attributes: NUMBER_OF_COMMENTS_ATTRIBUTES)
    }
    else
    {
        return NSAttributedString()
    }
}

func getCharInString(str : String, position: Int) -> Character
{
    let index = str.index(str.startIndex, offsetBy: position)
    return str[index]
}

func goBackToPreviousViewController(navigationController : UINavigationController, showNavigationBar : Bool)
{
    navigationController.navigationBar.isHidden = !showNavigationBar
    navigationController.popViewController(animated: true)
}

func setConstraintToMiddleOfScreen(constraint : NSLayoutConstraint, view : UIView)
{
    constraint.constant = CachedData().getScreenWidth() / 2 - view.frame.width / 2
}

func setConstraintToMiddleOfView(constraint: NSLayoutConstraint, surroundingViewHeight : CGFloat, view : UIView)
{
    constraint.constant = surroundingViewHeight / 2 - view.frame.height / 2
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
