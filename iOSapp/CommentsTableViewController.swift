//
//  CommentsTableViewControllerNew.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/28/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

// TODO:: consider when and if to refresh the content

class CommentsTableViewController: GenericProgramViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var writeCommentBox: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var replyingToView: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeReplyButton: UIButton!
    
    var commentsInNestedFormat : [Comment] = []
    var currentSnippetID : Int = 0
    var isCurrentlyReplyingToComment : Bool = false
    var commentIdReplyingTo : Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        setCommentBoxStyle()
        registerForKeyboardNotifications()
        hideReplyingToBox()
        
        let writeCommentRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleCommentClick(sender:)))
        writeCommentBox.isUserInteractionEnabled = true
        writeCommentBox.addGestureRecognizer(writeCommentRecognizer)
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // This is for the cases where there are no comments
        setTableViewBackground()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("preparing to segue to sign up")
        
        let nextViewController = segue.destination as! GenericProgramViewController
        nextViewController.viewControllerToReturnTo = self
    }
    
    @objc func handleCommentClick(sender: UITapGestureRecognizer)
    {
        print("handling comment click")
        if (UserInformation().isUserLoggedIn())
        {
            writeCommentBox.becomeFirstResponder()
        }
        else
        {
            // TODO:: before you segue, pop an alert
            performSegue(withIdentifier: "segueFromCommentsToSignup", sender: self)
        }
    }
    
    @IBAction func closedRepliedTo(_ sender: Any)
    {
        print("closed replied to")
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
        if (commentsInNestedFormat.count > 0)
        {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Be the first to comment."
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            writeCommentBox.becomeFirstResponder()
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
        var info = notification.userInfo!
        let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
        bottomConstraint.constant = keyboardHeight!
    }
    
    func setCommentBoxStyle()
    {
        print("setting style")
        
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
        SnipRetrieverFromWeb().runFunctionAfterGettingCsrfToken(functionData: CommentActionData(receivedActionString: "publish", receivedActionJson: getCommentDataAsJson()), completionHandler: self.performCommentAction)
    }
    
    func performCommentAction(handlerParams : Any, csrfToken : String)
    {
        let actionParams : CommentActionData = handlerParams as! CommentActionData
        SnipRetrieverFromWeb().postContentWithJsonBody(jsonString: actionParams.actionJson, urlString: getServerStringForComment(commentActionString: actionParams.actionString), csrfToken: csrfToken)
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
        let currentComment : Comment = commentsInNestedFormat[indexPath.row]
        cell.externalCommentBox = writeCommentBox
        cell.replyingToBox = replyingToView
        cell.closeReplyButton = closeReplyButton
        cell.commentID = currentComment.id
        cell.deleteButtonAvailable = currentComment.isWrittenByCurrentUser
        cell.setCellConstraintsAccordingToLevel(commentLevel: currentComment.level)
        cell.viewController = self
        
        cell.body.text = currentComment.body
        cell.date.text = getTimeFromDateString(dateString: currentComment.date)
        cell.writer.text = currentComment.writer._name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return commentsInNestedFormat.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}
