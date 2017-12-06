//
//  CommentTableViewCell.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/22/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell, UITextViewDelegate
{
    @IBOutlet weak var writer: UITextView!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var date: UITextView!
    @IBOutlet weak var replyButton: UITextView!
    @IBOutlet weak var deleteButton: UITextView!
    @IBOutlet weak var surroundingView: UIView!
    
    @IBOutlet weak var bufferBetweenComments: UIImageView!
    
    @IBOutlet weak var replyButtonWidthConstraint: NSLayoutConstraint!
    
    // TODO:: perhaps this isn't ideal
    var viewController : CommentsTableViewController = CommentsTableViewController()
    
    var commentID : Int = 0
    var replyingToBox : UITextView = UITextView()
    var externalCommentBox : UITextView = UITextView()
    var closeReplyButton : UIButton = UIButton()
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        setCellStyles()
        makeReplyButtonClickable()
        makeDeleteButtonClickable()
    }
    
    func setCellConstraintsAccordingToLevel(commentLevel : Int)
    {
        leftConstraint.constant = CGFloat(commentLevel * SystemVariables().COMMENT_INDENTATION_FROM_LEFT_PER_LEVEL)
    }
    
    func makeReplyButtonClickable()
    {
        let replyButtonRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.replyButtonPressed(sender:)))
        replyButton.isUserInteractionEnabled = true
        replyButton.addGestureRecognizer(replyButtonRecognizer)
    }
    
    func makeDeleteButtonClickable()
    {
        let deleteButtonRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.deleteButtonPressed(sender:)))
        deleteButton.isUserInteractionEnabled = true
        deleteButton.addGestureRecognizer(deleteButtonRecognizer)
    }
    
    @objc func replyButtonPressed(sender: UITapGestureRecognizer)
    {
        if (UserInformation().isUserLoggedIn())
        {
            externalCommentBox.becomeFirstResponder()
            setConstraintConstantForView(constraintName: "replyingHeightConstraint", view: replyingToBox, constant: CGFloat(SystemVariables().DEFAULT_HEIGHT_OF_REPLYING_TO_BAR))
            let cellChosen : CommentTableViewCell = sender.view?.superview?.superview?.superview as! CommentTableViewCell
            let replyingToString : String = "Replying to " + cellChosen.writer.text
            replyingToBox.attributedText = NSAttributedString(string: replyingToString)
            replyingToBox.isHidden = false
            closeReplyButton.isHidden = false
            
            viewController.isCurrentlyReplyingToComment = true
            viewController.commentIdReplyingTo = commentID
        }
        else
        {
            viewController.popAlertController()
        }
    }
    
    func deleteComment(alertAction: UIAlertAction)
    {
        var deleteCommandJson : Dictionary<String,String> = Dictionary<String,String>()
        deleteCommandJson["id"] = String(commentID)
        WebUtils().runFunctionAfterGettingCsrfToken(functionData: CommentActionData(receivedActionString: "delete", receivedActionJson: deleteCommandJson), completionHandler: viewController.performCommentDeleteAction)
    }
    
    @objc func deleteButtonPressed(sender: UITapGestureRecognizer)
    {
        let alertController : UIAlertController = UIAlertController(title: "Are you sure you want to delete this comment?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let alertActionOk : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.deleteComment)
        let alertActionCancel : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertActionOk)
        alertController.addAction(alertActionCancel)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func setCellStyles()
    {
        addFontAndForegroundColorToView(textView: writer, newFont: SystemVariables().HEADLINE_TEXT_FONT, newColor: SystemVariables().HEADLINE_TEXT_COLOR)
        addFontAndForegroundColorToView(textView: body, newFont: SystemVariables().CELL_TEXT_FONT!, newColor: SystemVariables().CELL_TEXT_COLOR)
        addFontAndForegroundColorToView(textView: date, newFont: SystemVariables().PUBLISH_TIME_AND_WRITER_FONT!, newColor: SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR)
        addFontAndForegroundColorToView(textView: replyButton, newFont: SystemVariables().PUBLISH_TIME_AND_WRITER_FONT!, newColor: SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR)
        addFontAndForegroundColorToView(textView: deleteButton, newFont: SystemVariables().PUBLISH_TIME_AND_WRITER_FONT!, newColor: SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR)
        
        removePaddingFromTextView(textView: writer)
        removePaddingFromTextView(textView: body)
        removePaddingFromTextView(textView: date)
        removePaddingFromTextView(textView: replyButton)
        removePaddingFromTextView(textView: deleteButton)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
