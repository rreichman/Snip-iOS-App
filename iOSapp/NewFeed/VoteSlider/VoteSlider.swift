//
//  VoteSlider.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/18/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit


class VoteSlider: UISlider {
    
    weak var filledSliderTrack: UIImageView?
    var filledImage: UIImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    func initViews() {
        self.filledImage = UIImage(named: "sliderFillStretch")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0), resizingMode: .stretch)
        self.maximumTrackTintColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1)
        let default_max_image = self.currentMaximumTrackImage
        self.setMinimumTrackImage(default_max_image!.withHorizontallyFlippedOrientation(), for: .normal)
        let filledSliderTrack = UIImageView(image: filledImage)
        filledSliderTrack.frame = calculateFilledImageViewFrame()
        self.addSubview(filledSliderTrack)
        self.bringSubview(toFront: filledSliderTrack)
        self.filledSliderTrack = filledSliderTrack
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        guard let filledSliderTrack = self.filledSliderTrack else { return }
        self.bringSubview(toFront: filledSliderTrack)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let filledSliderTrack = self.filledSliderTrack else { return }
        filledSliderTrack.frame = calculateFilledImageViewFrame()
    }
    
    func calculateFilledImageViewFrame() -> CGRect {
        let track_rect = self.trackRect(forBounds: self.bounds)
        let thumb_rect = self.thumbRect(forBounds: self.bounds, trackRect: track_rect, value: self.value)
        let y_origin = track_rect.origin.y
        let mid_point = track_rect.width / 2.0
        if thumb_rect.contains(CGPoint(x: track_rect.width / 2.0, y: track_rect.origin.y)) {
            //Thumb image completely covers the filled part
            return CGRect(x: mid_point, y: track_rect.origin.y, width: 0.0, height: track_rect.height)
        } else {
            if thumb_rect.origin.x >= mid_point {
                //past center case
                return CGRect(x: mid_point, y: y_origin, width: (thumb_rect.origin.x + 2.0 - mid_point), height: 2.0)
            } else {
                //before center case
                return CGRect(x: thumb_rect.maxX - 2, y: y_origin, width: (mid_point - (thumb_rect.maxX - 2)), height: 2.0)
            }
        }
        
    }
}
