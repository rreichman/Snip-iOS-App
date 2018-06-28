//
//  CommentView.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/21/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

//@IBDesignable

class CommentView: UIView
{
    /**
    var contentView : UIView?
    
    @IBOutlet weak var userImage: UserImage!
    @IBOutlet weak var writer: UITextView!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var date: UITextView!
    @IBOutlet weak var replyButton: UITextView!
    @IBOutlet weak var editButton: UITextView!
    @IBOutlet weak var deleteButton: UITextView!
    
    @IBOutlet weak var surroundingView: UIView!
    
    @IBOutlet weak var bufferBetweenComments: UIImageView!
    
    @IBOutlet weak var replyButtonWidthConstraint: NSLayoutConstraint!
    
    // TODO: perhaps this isn't ideal
    var viewController : CommentsTableViewController = CommentsTableViewController()
    
    var commentID : Int = 0
    var replyingToBox : UITextView = UITextView()
    var externalCommentBox : UITextView = UITextView()
    var closeReplyButton : UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        setCellStyles()
        makeReplyButtonClickable()
        makeEditButtonClickable()
        makeDeleteButtonClickable()
        
        return view
    }
    
    func makeReplyButtonClickable()
    {
        let replyButtonRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.replyButtonPressed(sender:)))
        replyButton.isUserInteractionEnabled = true
        replyButton.addGestureRecognizer(replyButtonRecognizer)
    }
    
    func makeEditButtonClickable()
    {
        let editButtonRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.editButtonPressed(sender:)))
        editButton.isUserInteractionEnabled = true
        editButton.addGestureRecognizer(editButtonRecognizer)
    }
    
    func makeDeleteButtonClickable()
    {
        let deleteButtonRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.deleteButtonPressed(sender:)))
        deleteButton.isUserInteractionEnabled = true
        deleteButton.addGestureRecognizer(deleteButtonRecognizer)
    }
    
    @objc func replyButtonPressed(sender: UITapGestureRecognizer)
    {
        if (SessionManager.instance.loggedIn)
        {
            externalCommentBox.becomeFirstResponder()
            let comment : CommentView = sender.view?.superview?.superview?.superview as! CommentView
            loadReplyingToBox(replyingToText: "Replying to " + comment.writer.text)
            
            viewController.isCurrentlyReplyingToComment = true
            viewController.commentIdReplyingTo = commentID
        }
        else
        {
            viewController.popAlertController()
        }
    }
    
    func loadReplyingToBox(replyingToText: String)
    {
        setConstraintConstantForView(constraintName: "replyingHeightConstraint", view: replyingToBox, constant: CGFloat(SystemVariables().DEFAULT_HEIGHT_OF_REPLYING_TO_BAR))
        replyingToBox.attributedText = NSAttributedString(string: replyingToText)
        replyingToBox.isHidden = false
        closeReplyButton.isHidden = false
    }
    
    func deleteComment(alertAction: UIAlertAction)
    {
        var deleteCommandJson : Dictionary<String,String> = Dictionary<String,String>()
        deleteCommandJson["id"] = String(commentID)
        viewController.performCommentDeleteAction(commentActionData: CommentActionData(receivedActionString: "delete", receivedActionJson: deleteCommandJson))
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
    
    @objc func editButtonPressed(sender: UITapGestureRecognizer)
    {
        print("edit button")
        loadReplyingToBox(replyingToText: "Editing...")
        viewController.writeCommentBox.text = body.text
        viewController.textViewDidChange(viewController.writeCommentBox)
        viewController.writeCommentBox.becomeFirstResponder()
        viewController.isCurrentlyEditingComment = true
        viewController.commentIdInEdit = commentID
    }
    
    func setCellStyles()
    {
        addFontAndForegroundColorToView(textView: writer, newFont: SystemVariables().PUBLISH_WRITER_FONT!, newColor: SystemVariables().PUBLISH_WRITER_COLOR)
        addFontAndForegroundColorToView(textView: body, newFont: SystemVariables().CELL_TEXT_FONT!, newColor: SystemVariables().CELL_TEXT_COLOR)
        addFontAndForegroundColorToView(textView: date, newFont: SystemVariables().PUBLISH_TIME_FONT!, newColor: SystemVariables().PUBLISH_TIME_COLOR)
        addFontAndForegroundColorToView(textView: replyButton, newFont: SystemVariables().COMMENT_ACTION_FONT!, newColor: SystemVariables().PUBLISH_WRITER_COLOR)
        addFontAndForegroundColorToView(textView: editButton, newFont: SystemVariables().COMMENT_ACTION_FONT!, newColor: SystemVariables().PUBLISH_WRITER_COLOR)
        addFontAndForegroundColorToView(textView: deleteButton, newFont: SystemVariables().COMMENT_ACTION_FONT!, newColor: SystemVariables().PUBLISH_WRITER_COLOR)
        
        removePaddingFromTextView(textView: writer)
        removePaddingFromTextView(textView: body)
        removePaddingFromTextView(textView: date)
        removePaddingFromTextView(textView: replyButton)
        removePaddingFromTextView(textView: editButton)
        removePaddingFromTextView(textView: deleteButton)
    }
     **/
}
