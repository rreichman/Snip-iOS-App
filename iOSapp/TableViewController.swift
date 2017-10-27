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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("here")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        
        cell.cellText.lineBreakMode = NSLineBreakMode.byTruncatingMiddle;
        cell.cellText.numberOfLines = 0;
        tableView.allowsSelection = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        let attributedString = NSMutableAttributedString(string: shoppingList[indexPath.row], attributes: [NSAttributedStringKey.paragraphStyle:paragraphStyle])
        cell.cellText.attributedText = attributedString
        cell.cellText.font = cell.cellText.font.withSize(14)
        
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
    
    private func turnNavigationBarTitleIntoButton(title: String)
    {
        let button =  UIButton(type: .custom)
        let buttonHeight = self.navigationController!.navigationBar.frame.size.height
        // 0.8 is arbitrary ratio of bar to be clickable
        let buttonWidth = self.navigationController!.navigationBar.frame.size.width * 0.8
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize : 18)
        button.addTarget(self,
                         action: #selector(self.buttonAction),
                         for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    @objc func buttonAction(sender: Any)
    {
        print("Got it!")
        // This is a nice additional margin so that the cell isn't too crowded with the top of the page. Probably there's a better way to do this but not too important.
        let additionalMarginAtBottomOfNavigationBar = CGFloat(20)
        // Bring the content to the top of the screen in a nice animated way.
        let heightOfTopOfPage = -self.navigationController!.navigationBar.frame.size.height - additionalMarginAtBottomOfNavigationBar
        tableView.setContentOffset(CGPoint(x : 0, y : heightOfTopOfPage), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        turnNavigationBarTitleIntoButton(title: "Home")
        
        print("table view has loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
