//
//  CommentsTableViewControllerNew.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/28/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

// TODO:: spread this class to another one
class CommentsTableViewController: GenericProgramViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var snippetView: SnippetView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewInsideOfScrollView: UIView!
    
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollviewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var writeCommentBox: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var replyingToView: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeReplyButton: UIButton!
    
    var snippetsViewController : SnippetsTableViewController = SnippetsTableViewController()
    var currentSnippetID : Int = 0
    var isCurrentlyReplyingToComment : Bool = false
    var commentIdReplyingTo : Int = 0
    var noDataLabel: UILabel = UILabel()
    var isPostButtonValid = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        snippetsViewController = viewControllerToReturnTo as! SnippetsTableViewController
        
        setCommentArray(newCommentArray: getCommentArraySortedAndReadyForPresentation(commentArray: getCommentArray()))
        loadSnippetView(shouldTruncate: true)
        snippetView.currentViewController = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        setCommentBoxStyle()
        registerForKeyboardNotifications()
        hideReplyingToBox()
        
        let writeCommentRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleCommentClick(sender:)))
        writeCommentRecognizer.delegate = self
        writeCommentBox.isUserInteractionEnabled = true
        writeCommentBox.addGestureRecognizer(writeCommentRecognizer)
        
        loadInitialsIntoUserImage(writerName: snippetView.writerName.attributedText!, userImage: snippetView.userImage)
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // This is for the cases where there are no comments
        setTableViewBackground()
    }
    
    override func viewDidLayoutSubviews()
    {
        tableHeightConstraint.constant = tableView.contentSize.height
        
        snippetView.setNeedsLayout()
        snippetView.layoutIfNeeded()
        scrollviewHeightConstraint.constant = snippetView.bounds.height + tableView.contentSize.height + 20
    }
    
    // This allows the text view to receive input normally even with a recognizer.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func loadSnippetView(shouldTruncate: Bool)
    {
        (snippetsViewController.tableView.dataSource as! FeedDataSource).loadSnippetFromID(snippetView: snippetView, snippetID: currentSnippetID, shouldTruncate: shouldTruncate)
    }
    
    func getCommentArray() -> [Comment]
    {
        return (snippetsViewController.tableView.dataSource as! FeedDataSource).getSnippetComments(snippetID: currentSnippetID)
    }
    
    func setCommentArray(newCommentArray: [Comment])
    {
        (snippetsViewController.tableView.dataSource as! FeedDataSource).setSnippetComments(snippetID: currentSnippetID, newComments: newCommentArray)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let nextViewController = segue.destination as! GenericProgramViewController
        nextViewController.shouldPressBackAndNotSegue = false
        nextViewController.viewControllerToReturnTo = self
    }
    
    func segueToSignup(action: UIAlertAction)
    {
        performSegue(withIdentifier: "segueFromCommentsToSignup", sender: self)
    }
    
    func popAlertController()
    {
        let alertController : UIAlertController = UIAlertController(title: "To Comment You Need to Sign Up", message: "It only takes a few seconds...", preferredStyle: UIAlertControllerStyle.alert)
        let alertActionSignup : UIAlertAction = UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.default, handler: self.segueToSignup)
        let alertActionStayHere : UIAlertAction = UIAlertAction(title: "Stay Here", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertActionSignup)
        alertController.addAction(alertActionStayHere)
        present(alertController, animated: true, completion: nil)
    }
    
    func handleCommentingAccordingToLoginStatus()
    {
        if (UserInformation().isUserLoggedIn())
        {
            if (!writeCommentBox.isFirstResponder)
            {
                writeCommentBox.becomeFirstResponder()
            }
        }
        else
        {
            popAlertController()
        }
    }
    
    @objc func handleCommentClick(sender: UITapGestureRecognizer)
    {
        handleCommentingAccordingToLoginStatus()
    }
    
    @IBAction func closedRepliedTo(_ sender: Any)
    {
        hideReplyingToBox()
        setNotReplyingTo()
    }
    
    func setNotReplyingTo()
    {
        isCurrentlyReplyingToComment = false
        commentIdReplyingTo = 0
    }
    
    func hideReplyingToBox()
    {
        replyingToView.isHidden = true
        setConstraintConstantForView(constraintName: "replyingHeightConstraint", view: replyingToView, constant: 0)
        closeReplyButton.isHidden = true
    }
    
    func setTableViewBackground()
    {
        if (getCommentArray().count > 0)
        {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        else
        {
            noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Be the first to comment."
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            handleCommentingAccordingToLoginStatus()
        }
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifications on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification)
    {
        var info = notification.userInfo!
        let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
        bottomConstraint.constant = keyboardHeight!
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        bottomConstraint.constant = 0
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    func setCommentBoxStyle()
    {
        commentView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        commentView.layer.borderWidth = 0.5
        writeCommentBox.clipsToBounds = true
        writeCommentBox.placeholder = "Write a comment..."
        writeCommentBox.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
         if let placeholderLabel = textView.viewWithTag(TEXTVIEW_PLACEHOLDER_TAG) as? UILabel
         {
            placeholderLabel.isHidden = textView.attributedText.length > 0
         }
    }
    
    @IBAction func postButtonClicked(_ sender: Any)
    {
        if (writeCommentBox.attributedText.length > 0)
        {
            if (UserInformation().isUserLoggedIn() && isPostButtonValid)
            {
                isPostButtonValid = false
                
                WebUtils().runFunctionAfterGettingCsrfToken(functionData: CommentActionData(receivedActionString: "publish", receivedActionJson: getCommentDataAsJson()), completionHandler: self.performCommentPostAction)
            }
            else
            {
                popAlertController()
            }
        }
    }
    
    func handlePostedComment(responseString: String)
    {
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            let postedComment = Comment(commentData: jsonObj)
            var newCommentArray : [Comment] = getCommentArray()
            newCommentArray.insert(postedComment, at: 0)
            setCommentArray(newCommentArray: getCommentArraySortedAndReadyForPresentation(commentArray: newCommentArray))
            DispatchQueue.main.async
            {
                self.setNotReplyingTo()
                self.tableHeightConstraint.constant = 10000
                self.tableView.reloadData()
                self.hideReplyingToBox()
                self.writeCommentBox.endEditing(true)
                self.writeCommentBox.text = ""
                if let placeholderLabel = self.writeCommentBox.viewWithTag(TEXTVIEW_PLACEHOLDER_TAG) as? UILabel
                {
                    placeholderLabel.isHidden = self.writeCommentBox.attributedText.length > 0
                }
                
                self.noDataLabel.isHidden = true
                
                self.tableView.setNeedsLayout()
                self.tableView.layoutIfNeeded()
                
                self.updateHeightsInCommentsController()
                self.scrollToPublishedComment(commentID: postedComment.id)
                
                self.snippetView.numberOfCommentsLabel.attributedText = getAttributedStringOfCommentCount(commentCount: self.tableView.visibleCells.count)
            }
        }
        else
        {
            // TODO:: What happens here?
        }
        
        isPostButtonValid = true
    }
    
    func updateHeightsInCommentsController()
    {
        self.tableHeightConstraint.constant = self.tableView.contentSize.height
        self.scrollviewHeightConstraint.constant = self.snippetView.bounds.height + self.tableView.contentSize.height + 20
    }
    
    func scrollToPublishedComment(commentID: Int)
    {
        var i = 0
        var heightInTableView = CGFloat(0)
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        for cell in self.tableView.visibleCells
        {
            heightInTableView += cell.bounds.height
            if (cell as! CommentTableViewCell).commentView.commentID != commentID
            {
                i+=1
            }
            else
            {
                break
            }
        }
        
        let absoluteHeight = heightInTableView + self.snippetView.bounds.height
        let scrollViewSize = scrollView.bounds.height
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        if (absoluteHeight > scrollViewSize)
        {
            scrollView.setContentOffset(CGPoint(x: 0, y: absoluteHeight - scrollViewSize), animated: false)
        }
    }
    
    func handleDeletedComment(responseString: String)
    {
        DispatchQueue.main.async
        {
            if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
            {
                if jsonObj.keys.contains("message")
                {
                    let deleteMessage : String = jsonObj["message"] as! String
                    if deleteMessage == "success"
                    {
                        self.tableHeightConstraint.constant = 10000
                        
                        let deletedIDs : [Int] = jsonObj["deleted"] as! [Int]
                        self.setCommentArray(newCommentArray: self.getCommentListWithoutDeletedComments(commentArray: self.getCommentArray(), deletedIDs: deletedIDs))
                        self.setTableViewBackground()
                        self.tableView.reloadData()
                        
                        self.tableView.setNeedsLayout()
                        self.tableView.layoutIfNeeded()
                        
                        self.updateHeightsInCommentsController()
                        self.snippetView.numberOfCommentsLabel.attributedText = getAttributedStringOfCommentCount(commentCount: self.tableView.visibleCells.count)
                    }
                }
            }
            else
            {
                promptToUser(promptMessageTitle: "Error", promptMessageBody: "Sorry, your comment was not deleted", viewController: self)
            }
        }
    }
    
    func getCommentListWithoutDeletedComments(commentArray: [Comment], deletedIDs: [Int]) -> [Comment]
    {
        var newCommentArray : [Comment] = []
        
        for comment in commentArray
        {
            if (!deletedIDs.contains(comment.id))
            {
                newCommentArray.append(comment)
            }
        }
        
        return newCommentArray
    }
    
    func performCommentPostAction(handlerParams : Any, csrfToken : String)
    {
        let actionParams : CommentActionData = handlerParams as! CommentActionData
        WebUtils().postContentWithJsonBody(jsonString: actionParams.actionJson, urlString: getServerStringForComment(commentActionString: actionParams.actionString), csrfToken: csrfToken, completionHandler: self.handlePostedComment)
    }
    
    func performCommentDeleteAction(handlerParams: Any, csrfToken : String)
    {
        let actionParams : CommentActionData = handlerParams as! CommentActionData
        WebUtils().postContentWithJsonBody(jsonString: actionParams.actionJson, urlString: getServerStringForComment(commentActionString: actionParams.actionString), csrfToken: csrfToken, completionHandler: self.handleDeletedComment)
    }
    
    func getServerStringForComment(commentActionString : String) -> String
    {
        var urlString : String = SystemVariables().URL_STRING
        urlString.append("comments/")
        urlString.append(commentActionString)
        urlString.append("/")
        
        return urlString
    }
    
    func getCommentDataAsJson() -> Dictionary<String,String>
    {
        var commentDataAsJson : Dictionary<String,String> = Dictionary<String,String>()
        commentDataAsJson["post_id"] = String(currentSnippetID)
        if (isCurrentlyReplyingToComment)
        {
            commentDataAsJson["parent"] = String(commentIdReplyingTo)
        }
        let text = writeCommentBox.text
        
        commentDataAsJson["body"] = encodeSpecialCharsForHttpRequest(textBeforeEncoding: text!)
        
        return commentDataAsJson
    }
    
    func encodeSpecialCharsForHttpRequest(textBeforeEncoding : String) -> String
    {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = NSCharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return textBeforeEncoding.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let currentComment : Comment = getCommentArray()[indexPath.row]
        cell.commentView.externalCommentBox = writeCommentBox
        cell.commentView.replyingToBox = replyingToView
        cell.commentView.closeReplyButton = closeReplyButton
        cell.commentView.commentID = currentComment.id

        if (currentComment.level == 2)
        {
            cell.commentView.replyButtonWidthConstraint.constant = 0
        }
        else
        {
            cell.commentView.replyButtonWidthConstraint.constant = 55
        }
        // Note - You can only delete comment if you're the owner (i.e. username is same as yours)
        cell.commentView.deleteButton.isHidden = (currentComment.writer._username != UserInformation().getUserInfo(key: "username"))
        cell.setCellConstraintsAccordingToLevel(commentLevel: currentComment.level)
        cell.commentView.viewController = self
        
        cell.commentView.body.text = currentComment.body
        cell.commentView.date.text = getTimeFromDateString(dateString: currentComment.date)
        cell.commentView.writer.text = currentComment.writer._name
        
        loadInitialsIntoUserImage(writerName: NSAttributedString(string: currentComment.writer._name), userImage: cell.commentView.userImage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return getCommentArray().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}
