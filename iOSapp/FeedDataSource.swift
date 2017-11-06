//
//  FeedDataSource.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import ReadMoreTextView

class FeedDataSource: NSObject, UITableViewDataSource
{
    var postDataArray: [PostData] = []
    
    public func getLinkAttributesForWebsite(linkWebsite : String) -> [String : Any]
    {
        let linkAttributes = [
            NSAttributedStringKey.link.rawValue: NSURL(string: linkWebsite)!,
            NSAttributedStringKey.foregroundColor: UIColor.blue
            ] as! [String : Any]
        return linkAttributes
    }
    
    /*private func addReadMoreToLabel(label : UILabel)
    {
        //let readMoreText = " ...Read More" as String;
        let mutableLabelString = label.attributedText?.mutableCopy() as! NSMutableAttributedString
        let MAX_LENGTH_FOR_PREVIEW = 40
        let PREVIEW_SIZE = 20
        let len = mutableLabelString.length
        
        if (len >= MAX_LENGTH_FOR_PREVIEW)
        {
            let partialString : NSMutableAttributedString = mutableLabelString.attributedSubstring(from : NSMakeRange(0, PREVIEW_SIZE)) as! NSMutableAttributedString
            let restOfString : NSMutableAttributedString = mutableLabelString.attributedSubstring(from : NSMakeRange(PREVIEW_SIZE, mutableLabelString.length)) as! NSMutableAttributedString
            partialString.append(restOfString)
            label.attributedText = partialString
        }
        else
        {
            NSLog("No need for 'Read More'...")
        }
        
        /*if (lengthForString >= 30)
        {
            NSInteger lengthForVisibleString = [self fitString:label.text intoLabel:label];
            NSMutableString *mutableString = [[NSMutableString alloc] initWithString:label.text];
            NSString *trimmedString = [mutableString stringByReplacingCharactersInRange:NSMakeRange(lengthForVisibleString, (label.text.length - lengthForVisibleString)) withString:@""];
            NSInteger readMoreLength = readMoreText.length;
            NSString *trimmedForReadMore = [trimmedString stringByReplacingCharactersInRange:NSMakeRange((trimmedString.length - readMoreLength), readMoreLength) withString:@""];
            NSMutableAttributedString *answerAttributed = [[NSMutableAttributedString alloc] initWithString:trimmedForReadMore attributes:@{
                NSFontAttributeName : label.font
                }];
            
            NSMutableAttributedString *readMoreAttributed = [[NSMutableAttributedString alloc] initWithString:readMoreText attributes:@{
                NSFontAttributeName : Font(TWRegular, 12.),
                NSForegroundColorAttributeName : White
                }];
            
            [answerAttributed appendAttributedString:readMoreAttributed];
            label.attributedText = answerAttributed;
            
            UITagTapGestureRecognizer *readMoreGesture = [[UITagTapGestureRecognizer alloc] initWithTarget:self action:@selector(readMoreDidClickedGesture:)];
            readMoreGesture.tag = 1;
            readMoreGesture.numberOfTapsRequired = 1;
            [label addGestureRecognizer:readMoreGesture];
            
            label.userInteractionEnabled = YES;
        }
        else {
            
            NSLog(@"No need for 'Read More'...");
        }*/
    }*/
    
    public func addPost(headline : String, text : String, imageURL : String)
    {
        let newPost = PostData(headline: headline, text: text, imageURL: imageURL)
        postDataArray.append(newPost)
    }
    
    public func getLastIndexOfSubstringInString(originalString : String, substring : String) -> Int
    {
        return (originalString.range(of: substring, options: .backwards)?.lowerBound.encodedOffset)!
    }
    
    public func getTextAfterTruncation(text : String, contentSizeOfRow: Float) -> String
    {
        var truncatedText = text
        // Above this number of rows we want to truncate the snippet because it's too long
        let NUMBER_OF_ROWS_TO_TRUNCATE = 5
        let NUMBER_OF_ROWS_IN_PREVIEW = 2
        
        let READ_MORE_TEXT = " ... Read More"
        
        let MAX_LENGTH_TO_TRUNCATE = Int(floor(Float(contentSizeOfRow) * Float(NUMBER_OF_ROWS_TO_TRUNCATE)))

        let PREVIEW_SIZE = Int(floor(Float(contentSizeOfRow) * Float(NUMBER_OF_ROWS_IN_PREVIEW))) - READ_MORE_TEXT.count
        
        if (text.count >= MAX_LENGTH_TO_TRUNCATE)
        {
            truncatedText = String(text.prefix(PREVIEW_SIZE))
            // Get text until the last space
            truncatedText = String(truncatedText.prefix(getLastIndexOfSubstringInString(originalString: truncatedText, substring: " ")))
            truncatedText.append(READ_MORE_TEXT)
        }
        
        return truncatedText
    }
    
    func getWIdthOfSingleChar(font : UIFont) -> Int
    {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let myText = "a"
        
        return Int((myText as NSString).size(withAttributes: fontAttributes).width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        handleInfiniteScroll(tableView : tableView, currentRow: indexPath.row);
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        let currentPostData = postDataArray[indexPath[1]]
        tableView.allowsSelection = false
        
        cell.cellText.lineBreakMode = NSLineBreakMode.byTruncatingMiddle;
        cell.cellText.numberOfLines = 0;
        let cellFont = UIFont(name: "Helvetica", size: 14)
        if (!(cellFont != nil))
        {
            return cell
        }
        cell.cellText.font = cellFont
        
        let rowWidth = cell.cellText.bounds.size.width
        let sizeOfRowInChars = floor(Float(rowWidth) / Float(getWIdthOfSingleChar(font: cellFont!)))
        
        let textAfterTruncation : String = getTextAfterTruncation(text: currentPostData._text, contentSizeOfRow: sizeOfRowInChars)
        cell.cellText.attributedText = getCellTextStyle(cellText: textAfterTruncation, indexPath: indexPath)
        
        cell.cellHeadline.font = UIFont.boldSystemFont(ofSize: cell.cellHeadline.font.pointSize)
        cell.cellHeadline.text = currentPostData._headline
        
        do
        {
            _ = try cell.cellImage.imageFromServerURL(urlString: currentPostData._imageURL)
        }
        catch is ProgramError
        {
            // TODO:: currently doesn't handle failed loads of data
            // deleteRowSafelyFromTable(currentLocation: indexPath[1])
        }
        catch
        {
            // All is good
        }
        
        return cell
    }
    
    func getCellTextStyle(cellText : String, indexPath: IndexPath) -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        return NSMutableAttributedString(string: cellText, attributes: [NSAttributedStringKey.paragraphStyle:paragraphStyle])
    }
    
    func handleInfiniteScroll(tableView : UITableView, currentRow : Int)
    {
        let SPARE_ROWS_UNTIL_MORE_SCROLL = 3
        if postDataArray.count - currentRow < SPARE_ROWS_UNTIL_MORE_SCROLL
        {
            loadMorePostsToTable()
            tableView.reloadData()
        }
    }
    
    func loadMorePostsToTable()
    {
        // TODO:: actually get data from website instead of adding spam
        addPost(
            headline: "headline9", text: "text1", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/pizza.png")
        addPost(
            headline: "headline10", text: "text2", imageURL: "https://upload.wikimedia.org/wikipedia/commons/7/79/San_Francisco–Oakland_Bay_Bridge-_New_and_Old_bridges.jpg")
        addPost(
            headline: "headline11", text: "text3", imageURL: "https://static.pexels.com/photos/7653/pexels-photo.jpeg")
        addPost(
            headline: "headline12", text: "text4", imageURL: "https://cdn.pixabay.com/photo/2017/04/08/00/31/usa-2212202_960_720.jpg")
        addPost(
            headline: "headline13", text: "text5", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        addPost(
            headline: "headline14", text: "text6", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        addPost(
            headline: "headline15", text: "text7", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
        addPost(
            headline: "headline16", text: "text8", imageURL: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")
    }
    
    func deleteRowSafelyFromTable(currentLocation : Int)
    {
        // Need data reload?
        //postDataArray.remove(at: currentLocation)
    }
}
