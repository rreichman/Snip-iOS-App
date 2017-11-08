//
//  TableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

class TableViewController: UITableViewController
{
    let feedDataSource = FeedDataSource()
    
    let firstPostText = "12345678901234567890123456789012345678901234567890 This is an interesting introduction to something which is gibbrish and not very interesting. abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        turnNavigationBarTitleIntoButton(title: "Home")
        
        if feedDataSource.postDataArray.count == 0
        {
            getJsonFromURL(completionHandler: loadDataFromWebIntoFeed)
            
            //loadDataFromWebIntoFeed()
            sleep(3)
            tableView.dataSource = feedDataSource
        }
        // TODO:: Animation of loading data
    }
    
    func loadDataFromWebIntoFeed(resultArray: [[String : Any]])
    {
        print("callback called")
        for postAsJson in resultArray
        {
            print("iterating in result array")
            let newPost = PostData(
                id : postAsJson["id"] as! Int,
                author : SnipAuthor(authorData: postAsJson["author"] as! [String : Any]),
                headline : postAsJson["title"] as! String,
                text : postAsJson["body"] as! String,
                date : postAsJson["date"] as! String,
                image : SnipImage(imageData: postAsJson["image"] as! [String : Any]))
            
            feedDataSource.addPost(newPost: newPost)
        }
    }
    
    func getJsonFromURL(completionHandler: @escaping (_ resultArray: [[String : Any]]) -> ())
    {
        let URL_STRING = "https://www.snip.today/"
        let url: URL = URL(string: URL_STRING)!
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            print(response as Any)
            print(error as Any)

            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String : Any]]
            {
                print("in json")
                completionHandler(jsonObj)
            }
            
            print("after json parse")
        }).resume()
    }
    
    /*func getSnipsFromWeb(completionHandler: @escaping (_ resultArray: NSArray) -> ())
    {
        //let urlPath = "https://www.snip.today"
        let urlPath = "https://api.etherscan.io/api?module=account&action=tokenbalance&contractaddress=0x44f588aeeb8c44471439d1270b3603c66a9262f1&address=0x76b6bb812a3718689d4c1d6123e4c8d20f3ecdf8&tag=latest&apikey=YourApiKeyToken"
        print(urlPath)
        let url: NSURL = NSURL(string: urlPath)!
        let session = URLSession.shared
        
        let task = session.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            print("Task completed")
            if (error != nil)
            {
                print(error?.localizedDescription as Any)
            }
            var jsonResult: NSDictionary = NSDictionary()
            do
            {
                try jsonResult = JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            }
            catch let error as NSError
            {
                print("JSON Error \(error.localizedDescription)")
            }
            catch
            {
                
            }
            let resultsArray = jsonResult["genres"] as! NSArray
            completionHandler(resultsArray)
        })
        task.resume()
    }*/
    
    /*func startConnection()
    {
        let urlPath: String = "https://www.snip.today"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(url: url as URL)
        var connection: NSURLConnection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!)
    {
        self.data.append(_:data as Data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        //var err: NSError
        print("here")
        var jsonResult: NSDictionary = NSDictionary()
        // throwing an error on the line below (can't figure out where the error message is)
        do
        {
            try jsonResult = JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        }
        catch// is NSError
        {
        
        }
        print(jsonResult)
    }*/
    
    /*func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest) as! URL)
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var boardsDictionary: NSDictionary = JSONSerialization.JSONObjectWithData(inputData, options: JSONSerialization.ReadingOptions.MutableContainers) as! NSDictionary
        
        return boardsDictionary
    }*/
    
    /*func loadDataFromWebIntoFeed()
    {
        print("hello")
        // TODO:: handle situation of no internet connection. As part of this, cache headlines and texts in addition to the already-cached images
        /*feedDataSource.addPost(
            headline: "headline1", text: firstPostText, imageURL: "https://cdn.pixabay.com/photo/2016/08/31/17/41/sunrise-1634197_1280.jpg")
        feedDataSource.addPost(
            headline: "headline2", text: "text2", imageURL: "https://cdn.pixabay.com/photo/2013/09/15/05/27/sunrise-182302_1280.jpg")
        feedDataSource.addPost(
            headline: "headline3", text: "text3", imageURL: "https://static.pexels.com/photos/7653/pexels-photo.jpeg")
        feedDataSource.addPost(
            headline: "headline4", text: "text4", imageURL: "https://cdn.pixabay.com/photo/2017/04/08/00/31/usa-2212202_960_720.jpg")
        feedDataSource.addPost(
            headline: "headline5", text: "text5", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/pizza.png")
        feedDataSource.addPost(
            headline: "headline6", text: "text6", imageURL: "https://upload.wikimedia.org/wikipedia/commons/7/79/San_Francisco–Oakland_Bay_Bridge-_New_and_Old_bridges.jpg")
        feedDataSource.addPost(
            headline: "headline7", text: "text7", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        feedDataSource.addPost(
            headline: "headline8", text: "text8", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")*/
    }*/
    
    // Perhaps this can be non-objc with some modifications
    @objc func buttonAction(sender: Any)
    {
        print("Got it!")
        // This is a nice additional margin so that the cell isn't too crowded with the top of the page. Probably there's a better way to do this but not too important.
        let additionalMarginAtBottomOfNavigationBar = CGFloat(20)
        // Bring the content to the top of the screen in a nice animated way.
        let heightOfTopOfPage = -self.navigationController!.navigationBar.frame.size.height - additionalMarginAtBottomOfNavigationBar
        tableView.setContentOffset(CGPoint(x : 0, y : heightOfTopOfPage), animated: true)
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
}

/*
let firstString = "A team of security researchers at the University of Washington have found that for about $1,000, it’s possible to target and track individuals using only mobile advertising networks. The researchers bought advertisements on a popular demand-side platform (DSP), an advertising distributor that permits ad buyers to target specific demographics and choose the sites and apps where their ad appears. The DSPs provide ad buyers with feedback about where and when people see the ad. By simply buying an ad aimed at users of the texting app Talkatone, the researchers were able to determine the home address, work address, and current locations of Seattle residents to within a range of 25 feet."
let secondString = "In a summary of their findings, the research team wrote, \"Regular people, not just impersonal, commercially motivated merchants or advertising networks, can exploit the online advertising ecosystem to extract private information about other people.\" The researchers will present their findings at the Workshop on Privacy in the Electronic Society in Dallas later this month."
let thirdString = "The research suggests that to protect your privacy, it’s a good idea to pay a bit extra for ad-free versions of apps and switch off location sharing features whenever possible."
let snipString = firstString + "\n\n" + secondString + "\n\n" + thirdString

class TableViewController: UITableViewController
{
    /*var imageUrlList = [String]()
    var shoppingList = [
        snipString,
        "Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread Bread", "Milk", "Eggs", "Honey", "Veggies", "fdsajfdasjkjdfshhjksdfkadfshjkdsfajkhfdsajfdasjkjdfshhjksdfkadfshjkdsfajkhfdsajfdasjkjdfshhjksdfkadfshjkdsfajkh",
        "Pizza","Lettuce","Cabbage", "Onion"]
    
    var headlines = [
        "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6", "Headline7", "Headline8", "Headline9", "Headline10", "Headline11"]*/
    
    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return imageUrlList.count
    }*/
    
    /*func deleteRowSafelyFromTable(indexPath: IndexPath)
    {
        //shoppingList.remove(at: indexPath[1])
        //headlines.remove(at: indexPath[1])
        imageUrlList.remove(at: indexPath[1])
        self.tableView.reloadData()
    }*/
    
    func getCellTextStyle(textList : [String], indexPath: IndexPath) -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        return NSMutableAttributedString(string: textList[indexPath[1]], attributes: [NSAttributedStringKey.paragraphStyle:paragraphStyle])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        
        tableView.allowsSelection = false
        
        cell.cellText.lineBreakMode = NSLineBreakMode.byTruncatingMiddle;
        cell.cellText.numberOfLines = 0;
        cell.cellText.attributedText = getCellTextStyle(textList: shoppingList, indexPath: indexPath)
        cell.cellText.font = cell.cellText.font.withSize(14)
        
        cell.cellHeadline.font = UIFont.boldSystemFont(ofSize: cell.cellHeadline.font.pointSize)
        cell.cellHeadline.text = headlines[indexPath[1]]
    
        do
        {
            print("getting image number \(indexPath[0])")
            print("getting image number \(indexPath[1])")
            _ = try cell.cellImage.imageFromServerURL(urlString: imageUrlList[indexPath[1]])
        }
        catch is ProgramError
        {
            deleteRowSafelyFromTable(indexPath: indexPath)
        }
        catch
        {
            // All is good
        }

        return cell
    }
    
    func buttonAction(sender: Any)
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
        
        imageUrlList = ["https://www.pizza.com/a.jpg",
                        "https://www.pizza.com/a.jpg",
                        "https://upload.wikimedia.org/wikipedia/commons/7/79/San_Francisco–Oakland_Bay_Bridge-_New_and_Old_bridges.jpg",
                        "https://upload.wikimedia.org/wikipedia/commons/d/da/SF_From_Marin_Highlands3.jpg",
                        "https://upload.wikimedia.org/wikipedia/commons/4/43/San_Francisco_%28Sunset%29.jpg",
                        "https://upload.wikimedia.org/wikipedia/commons/3/3b/San_Francisco_%28Evening%29.jpg",
                        "https://cdn.pixabay.com/photo/2017/01/14/12/58/san-francisco-1979443_960_720.jpg",
                        "http://www.publicdomainpictures.net/pictures/160000/velka/san-francisco-neighborhood-1459695606m8F.jpg",
                        "https://cdn.pixabay.com/photo/2016/12/09/09/22/san-francisco-1893985_960_720.jpg",
                        "https://static.pexels.com/photos/7653/pexels-photo.jpeg",
                        "https://cdn.pixabay.com/photo/2017/04/08/00/31/usa-2212202_960_720.jpg"]
        
        print("table view has loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
*/
