//
//  DiscoverViewController.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

protocol DiscoverViewDelegate: class {
    func onCategorySelected(name: String)
}

class DiscoverViewController: UIViewController {
    
    let categories: [ String ] = [ "Top Stories", "Politics", "Business", "Tech", "World", "Crypto", "Health", "Science", "Sports", "Entertainment", "Misc" ]
    let categoryImages: [ UIImage ] = [#imageLiteral(resourceName: "discoverTopStories"), #imageLiteral(resourceName: "discoverPolitics"), #imageLiteral(resourceName: "discoverBusiness"), #imageLiteral(resourceName: "discoverTech"), #imageLiteral(resourceName: "discoverWorld"), #imageLiteral(resourceName: "discoverCrypto"), #imageLiteral(resourceName: "discoverHealth"), #imageLiteral(resourceName: "discoverScience"), #imageLiteral(resourceName: "discoverSports"), #imageLiteral(resourceName: "discoverEntertainment"), #imageLiteral(resourceName: "discoverMisc")]
    var columns: Int = 3
    
    var verticalStackView: UIStackView!
    var scrollView: UIScrollView!
    var categoryViews: [ UIView ] = []
    var categoryViewWidth: CGFloat!
    
    var delegate: DiscoverViewDelegate!
    
    override func viewDidLoad() {
        if UIScreen.main.bounds.width < 375.0 {
            self.columns = 2
        }
        print("DiscoverVC viewDidLoad()")
        scrollView = UIScrollView(frame: self.view.frame)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor).isActive = true
        buildStackViews()
    }
    
    override func viewWillLayoutSubviews() {
        print("DiscoverVC viewWillLayoutSubviews()")
        print("Screen Width \(UIScreen.main.bounds.width)")
    }
    
    func buildStackViews() {
        buildVerticalStackView()
        let end_row: Int = (categories.count / columns)
        for i in 0...end_row {
            let row = buildStackRow(row: i)
            verticalStackView.addArrangedSubview(row)
            if i == end_row {
                verticalStackView.bottomAnchor.constraint(equalTo: row.bottomAnchor).isActive = true
            }
        }
        verticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20.0).isActive = true
    }
    
    func buildVerticalStackView() {
        _calculateWidthOfCategoryView()
        self.verticalStackView = UIStackView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height))
        
        verticalStackView.axis = .vertical
        self.verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(verticalStackView)
        verticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20.0).isActive = true
        verticalStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20.0).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20.0).isActive = true
        
        verticalStackView.alignment = .top
        verticalStackView.distribution = .equalSpacing
        verticalStackView.spacing = 15.0
    }
    
    func buildStackRow(row: Int) -> UIStackView {
        let horizontalStackView = UIStackView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: self.categoryViewWidth))
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.alignment = .center
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.spacing = 15.0
        
        
        for i in (row * columns)...(row * columns) + columns - 1 {
            // Account for partially filled rows
            var catView: UIView!
            if i >= self.categories.count {
                catView = self._buildSingleCategoryView(title: "", image: UIImage())
                catView.isHidden = true
            } else {
                let title = self.categories[i]
                let image = self.categoryImages[i]
                catView = self._buildSingleCategoryView(title: title, image: image)
            }
            catView.tag = i
            catView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onCategorySelected(_:))))
            catView.isUserInteractionEnabled = true
            self.categoryViews.append(catView)
            horizontalStackView.addArrangedSubview(catView)
            if i == (row * columns) + columns - 1 {
                horizontalStackView.trailingAnchor.constraint(equalTo: catView.trailingAnchor).isActive = true
            }
        }
        
        return horizontalStackView
    }
    
    private func _buildSingleCategoryView(title: String, image: UIImage) -> UIView {
        let category_view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.categoryViewWidth, height: self.categoryViewWidth))
        category_view.backgroundColor = UIColor.white
        category_view.translatesAutoresizingMaskIntoConstraints = false
        category_view.heightAnchor.constraint(equalToConstant: self.categoryViewWidth).isActive = true
        category_view.widthAnchor.constraint(equalToConstant: self.categoryViewWidth).isActive = true
        
        let label_view = UILabel.init()
        label_view.translatesAutoresizingMaskIntoConstraints = false
        label_view.text = title
        label_view.font = UIFont.latoBold(size: 13.0)
        label_view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        category_view.addSubview(label_view)
        label_view.bottomAnchor.constraint(equalTo: category_view.bottomAnchor, constant: -12.0).isActive = true
        label_view.leadingAnchor.constraint(equalTo: category_view.leadingAnchor).isActive = true
        label_view.trailingAnchor.constraint(equalTo: category_view.trailingAnchor).isActive = true
        label_view.textAlignment = .center
        
        let image_view = UIImageView(image: image)
        image_view.translatesAutoresizingMaskIntoConstraints = false
        image_view.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        image_view.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        category_view.addSubview(image_view)
        image_view.centerXAnchor.constraint(equalTo: category_view.centerXAnchor).isActive = true
        
        // The offset is attempt to make the entire view feel more centered
        image_view.centerYAnchor.constraint(equalTo: category_view.centerYAnchor, constant: -(12.0 + (label_view.frame.height / 2.0)) ).isActive = true
        
        category_view.layer.borderWidth = 1
        category_view.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1).cgColor
        category_view.layer.cornerRadius = 4.0
        return category_view
    }
    
    private func _calculateWidthOfCategoryView() {
        // Total padding is 20 on each side and 15 between each column
        let screen_width: CGFloat = UIScreen.main.bounds.width
        let padding_width: CGFloat = CGFloat.init( 40 + ( 15 * (columns - 1) ) )
        let remaining_width: CGFloat = screen_width - padding_width
        self.categoryViewWidth = remaining_width / CGFloat.init( columns )
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func onCategorySelected(_ sender: UIGestureRecognizer) {
        guard let view = sender.view else { return }
        let tag = view.tag
        if tag < 0 || tag >= self.categories.count {
            print("DiscoverViewController view tag out of range of the data object")
            return
        }
        let categoryName = self.categories[tag]
        delegate.onCategorySelected(name: categoryName)
    }
}

