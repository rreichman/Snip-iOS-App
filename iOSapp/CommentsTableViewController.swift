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
    @IBOutlet weak var tableView: UITableView!
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
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // This is for the cases where there are no comments
        setTableViewBackground()
    }
    
    // This allows the text view to receive input normally even with a recognizer.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
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
    
    func scrollToCommentInTable(commentID: Int)
    {
        var index = 0
        for i in 0...getCommentArray().count-1
        {
            let comment : Comment = getCommentArray()[i]
            if(comment.id == commentID)
            {
                index = i
                break
            }
        }
        
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    func handlePostedComment(responseString: String)
    {
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            let postedComment = Comment(commentData: jsonObj)
            var newCommentArray : [Comment] = getCommentArray()
            newCommentArray.append(postedComment)
            setCommentArray(newCommentArray: getCommentArraySortedAndReadyForPresentation(commentArray: newCommentArray))
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
                self.hideReplyingToBox()
                self.writeCommentBox.endEditing(true)
                self.writeCommentBox.text = ""
                
                self.noDataLabel.isHidden = true
                self.scrollToCommentInTable(commentID: postedComment.id)
            }
        }
        else
        {
            // TODO:: What happens here?
        }
        
        isPostButtonValid = true
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
                        let deletedIDs : [Int] = jsonObj["deleted"] as! [Int]
                        self.setCommentArray(newCommentArray: self.getCommentListWithoutDeletedComments(commentArray: self.getCommentArray(), deletedIDs: deletedIDs))
                        self.setTableViewBackground()
                        self.tableView.reloadData()
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
        commentDataAsJson["body"] = writeCommentBox.text
        
        return commentDataAsJson
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : CommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let currentComment : Comment = getCommentArray()[indexPath.row]
        cell.externalCommentBox = writeCommentBox
        cell.replyingToBox = replyingToView
        cell.closeReplyButton = closeReplyButton
        cell.commentID = currentComment.id

        if (currentComment.level == 2)
        {
            cell.replyButtonWidthConstraint.constant = 0
        }
        else
        {
            cell.replyButtonWidthConstraint.constant = 55
        }
        // Note - You can only delete comment if you're the owner (i.e. username is same as yours)
        cell.deleteButton.isHidden = (currentComment.writer._username != UserInformation().getUserInfo(key: "username"))
        cell.setCellConstraintsAccordingToLevel(commentLevel: currentComment.level)
        cell.viewController = self
        
        cell.body.text = currentComment.body
        cell.date.text = getTimeFromDateString(dateString: currentComment.date)
        cell.writer.text = currentComment.writer._name
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
