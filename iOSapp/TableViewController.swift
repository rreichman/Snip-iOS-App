//
//  TableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

let firstString = "A team of security researchers at the University of Washington have found that for about $1,000, it’s possible to target and track individuals using only mobile advertising networks. The researchers bought advertisements on a popular demand-side platform (DSP), an advertising distributor that permits ad buyers to target specific demographics and choose the sites and apps where their ad appears. The DSPs provide ad buyers with feedback about where and when people see the ad. By simply buying an ad aimed at users of the texting app Talkatone, the researchers were able to determine the home address, work address, and current locations of Seattle residents to within a range of 25 feet."
let secondString = "In a summary of their findings, the research team wrote, \"Regular people, not just impersonal, commercially motivated merchants or advertising networks, can exploit the online advertising ecosystem to extract private information about other people.\" The researchers will present their findings at the Workshop on Privacy in the Electronic Society in Dallas later this month."
let thirdString = "The research suggests that to protect your privacy, it’s a good idea to pay a bit extra for ad-free versions of apps and switch off location sharing features whenever possible."
let snipString = firstString + "\n\n" + secondString + "\n\n" + thirdString

class TableViewController: UITableViewController {
    let shoppingList = [
        snipString,
        "Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread", "Milk", "Eggs", "Honey", "Veggies", "fdsajfdasjkjdfshhjksdfkadfshjkdsfajkhfdsajfdasjkjdfshhjksdfkadfshjkdsfajkhfdsajfdasjkjdfshhjksdfkadfshjkdsfajkh",
        "Pizza", "Lettuce"]
    let headlines = [
        "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6", "Headline7", "Headline8", "Headline9"]
    //let shoppingList = ["Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread", "Milk", "Eggs", "Honey", "Veggies"]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shoppingList.count
    }
    
    // TODO:: probably need static Home Bar (like twtr) for UI to make sense
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("here")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        
        /*var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        var attributedString = NSMutableAttributedString(cell.cellText.text)
        attributedString.addAttribute(name : NSMutableParagraphStyle, value: paragraphStyle, range: NSMakeRange(start, length))*/
        
        cell.cellText.lineBreakMode = NSLineBreakMode.byTruncatingMiddle;
        cell.cellText.numberOfLines = 0;
        cell.cellText.text = shoppingList[indexPath.row]
        tableView.allowsSelection = false
        
        cell.cellHeadline.font = UIFont.boldSystemFont(ofSize: cell.cellHeadline.font.pointSize)
        cell.cellHeadline.text = headlines[indexPath.row]
        
        var imageName = "dogImage"
        if (indexPath.row % 2 == 1)
        {
            imageName = "mapImage"
        }
        let loadedImage = UIImage(named:imageName)
        cell.cellImage.image = loadedImage
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("table view has loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
