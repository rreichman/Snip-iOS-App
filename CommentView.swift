//
//  CommentView.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/21/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

@IBDesignable

class CommentView: UIView
{    
    var contentView : UIView?
    
    @IBOutlet weak var userImage: UserImage!
    @IBOutlet weak var writer: UITextView!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var date: UITextView!
    @IBOutlet weak var replyButton: UITextView!
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
        makeDeleteButtonClickable()
        
        return view
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
            let comment : CommentView = sender.view?.superview?.superview?.superview as! CommentView
            let replyingToString : String = "Replying to " + comment.writer.text
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
        addFontAndForegroundColorToView(textView: writer, newFont: SystemVariables().PUBLISH_WRITER_FONT!, newColor: SystemVariables().PUBLISH_WRITER_COLOR)
        addFontAndForegroundColorToView(textView: body, newFont: SystemVariables().CELL_TEXT_FONT!, newColor: SystemVariables().CELL_TEXT_COLOR)
        addFontAndForegroundColorToView(textView: date, newFont: SystemVariables().PUBLISH_TIME_FONT!, newColor: SystemVariables().PUBLISH_TIME_COLOR)
        addFontAndForegroundColorToView(textView: replyButton, newFont: SystemVariables().COMMENT_ACTION_FONT!, newColor: SystemVariables().PUBLISH_WRITER_COLOR)
        addFontAndForegroundColorToView(textView: deleteButton, newFont: SystemVariables().COMMENT_ACTION_FONT!, newColor: SystemVariables().PUBLISH_WRITER_COLOR)
        
        removePaddingFromTextView(textView: writer)
        removePaddingFromTextView(textView: body)
        removePaddingFromTextView(textView: date)
        removePaddingFromTextView(textView: replyButton)
        removePaddingFromTextView(textView: deleteButton)
    }

}
