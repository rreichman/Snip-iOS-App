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
    @IBOutlet weak var writeCommentBox: UITextView!
    
    var firstTapOnCommentBox : Bool = true
    
    override func awakeFromNib()
    {
        print("in awake from nib")
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        setCellStyles()
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
        
        writeCommentBox.layer.cornerRadius = 10
        writeCommentBox.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        writeCommentBox.layer.borderWidth = 0.5
        writeCommentBox.clipsToBounds = true
        writeCommentBox.placeholder = "Write a comment..."
        writeCommentBox.delegate = self
        
        removePaddingFromTextView(textView: writer)
        removePaddingFromTextView(textView: body)
        removePaddingFromTextView(textView: date)
        removePaddingFromTextView(textView: replyButton)
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if let placeholderLabel = textView.viewWithTag(TEXTVIEW_PLACEHOLDER_TAG) as? UILabel
        {
            placeholderLabel.isHidden = textView.attributedText.length > 0
        }
        // TODO:: implement
        print("in textview changing")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        print("in set selected")
        super.setSelected(selected, animated: animated)
    }
}
