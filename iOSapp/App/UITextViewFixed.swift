//https://stackoverflow.com/questions/746670/how-to-lose-margin-padding-in-uitextview
import Foundation
import UIKit
@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
        //contentInset = UIEdgeInsets.zero
        // this is not ideal, but you can sometimes use this
        // to fix the "space at bottom" insanity
        var b = bounds
        let h = sizeThatFits(CGSize(
            width: bounds.size.width,
            height: CGFloat.greatestFiniteMagnitude)
            ).height
        b.size.height = h
        bounds = b
    }
    
    override var intrinsicContentSize: CGSize {
        let height = self.sizeThatFits(CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        return CGSize(width: self.contentSize.width, height: height)
    }
}
