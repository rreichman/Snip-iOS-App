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
    
    //var commentView : UIView = UIView()
    var replyingToBox : UITextView = UITextView()
    var externalCommentBox : UITextView = UITextView()
    var closeReplyButton : UIButton = UIButton()
    var snippetID : Int = 0
    
    var firstTapOnCommentBox : Bool = true
    
    override func awakeFromNib()
    {
        print("in awake from nib")
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        setCellStyles()
        makeReplyClickable()
    }
    
    func makeReplyClickable()
    {
        let replyButtonRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.replyButtonPressed(sender:)))
        replyButton.isUserInteractionEnabled = true
        replyButton.addGestureRecognizer(replyButtonRecognizer)
    }
    
    func holdRelease()
    {
        print("here")
    }
    
    @objc func replyButtonPressed(sender: UITapGestureRecognizer)
    {
        externalCommentBox.becomeFirstResponder()
        setConstraintConstantForView(constraintName: "replyingHeightConstraint", view: replyingToBox, constant: 30)
        let cellChosen : CommentTableViewCell = sender.view?.superview?.superview as! CommentTableViewCell
        let replyingToString : String = "Replying to " + cellChosen.writer.text
        replyingToBox.attributedText = NSAttributedString(string: replyingToString)
        replyingToBox.isHidden = false
        closeReplyButton.isHidden = false
    }
    
    func setCellStyles()
    {
        // TODO:: divide this function
        let attributedWriterString : NSMutableAttributedString = writer.attributedText.mutableCopy() as! NSMutableAttributedString
        
        attributedWriterString.addAttribute(NSAttributedStringKey.font, value: SystemVariables().HEADLINE_TEXT_FONT, range: NSRange(location: 0, length: attributedWriterString.length))
        attributedWriterString.addAttribute(NSAttributedStringKey.foregroundColor, value: SystemVariables().HEADLINE_TEXT_COLOR, range: NSRange(location: 0, length: attributedWriterString.length))
        writer.attributedText = attributedWriterString
        
        let attributedDateString : NSMutableAttributedString = date.attributedText.mutableCopy() as! NSMutableAttributedString
        attributedDateString.addAttribute(NSAttributedStringKey.font, value: SystemVariables().PUBLISH_TIME_AND_WRITER_FONT!, range: NSRange(location: 0, length: attributedDateString.length))
        attributedDateString.addAttribute(NSAttributedStringKey.foregroundColor, value: SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR, range: NSRange(location: 0, length: attributedDateString.length))
        date.attributedText = attributedDateString
        
        let attributedReplyString : NSMutableAttributedString = replyButton.attributedText.mutableCopy() as! NSMutableAttributedString
        attributedReplyString.addAttribute(NSAttributedStringKey.font, value: SystemVariables().PUBLISH_TIME_AND_WRITER_FONT!, range: NSRange(location: 0, length: attributedReplyString.length))
        attributedReplyString.addAttribute(NSAttributedStringKey.foregroundColor, value: SystemVariables().PUBLISH_TIME_AND_WRITER_COLOR, range: NSRange(location: 0, length: attributedReplyString.length))
        replyButton.attributedText = attributedReplyString
        
        removePaddingFromTextView(textView: writer)
        removePaddingFromTextView(textView: body)
        removePaddingFromTextView(textView: date)
        removePaddingFromTextView(textView: replyButton)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
