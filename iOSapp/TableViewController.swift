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
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    var heightAtIndexPath = NSMutableDictionary()
    
    let firstPostText = "12345678901234567890123456789012345678901234567890 This is an interesting introduction to something which is gibbrish and not very interesting. abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG abc def ghi jkl mno pqr stu vwx yza bcd efg hij klm nop qrs tuv wxy zab cde fgh ijk lmn opq rst uvw xyz ABC DEF GHI JKL MNO PQR STU VWX YZA BCD EFG"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        turnNavigationBarTitleIntoButton(title: "Home")
        
        // TODO:: Perhaps need more advanced logic here
        if feedDataSource.postDataArray.count == 0
        {
            getJsonFromURL(completionHandler: loadDataFromWebIntoFeed)
            
            //loadDataFromWebIntoFeed()

            sleep(3)
            tableView.dataSource = feedDataSource
        }
        // TODO:: Animation of loading data
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    // This is put here so that the content doesn't jump when updating row in table (based on: https://stackoverflow.com/questions/27996438/jerky-scrolling-after-updating-uitableviewcell-in-place-with-uitableviewautomati)
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
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
}
