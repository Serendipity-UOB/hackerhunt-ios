//
//  LeaderboardTableCell.swift
//  hackerhunt
//
//  Created by Louis Heath on 26/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class LeaderBoardTableCell: UITableViewCell {
    
    let cellHeight: CGFloat = 60
    var cellWidth: CGFloat = 0
    
    var position: Int = 0
    var name: String = "test"
    var score: Int = 0
    var isCurrentPlayer: Bool = false
    
    var backgroundImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "player_card_far"))
        imageView.contentMode = UIView.ContentMode.scaleToFill
        return imageView
    }()
    
    var posView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(red:0.62, green:0.89, blue:0.99, alpha:1.0)
        textView.font = UIFont(name: "ShareTechMono-Regular", size: 20)
        return textView
    }()
    
    var nameView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(red:0.62, green:0.89, blue:0.99, alpha:1.0)
        textView.textAlignment = .right
        textView.font = UIFont(name: "ShareTech-Regular", size: 18)
        return textView
    }()
    
    var scoreView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(red:0.62, green:0.89, blue:0.99, alpha:1.0)
        textView.textAlignment = .right
        textView.font = UIFont(name: "ShareTech-Regular", size: 16)
        return textView
    }()
    
    var cardDivider: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "leaderboard_card_divider"))
        imageView.contentMode = UIView.ContentMode.scaleToFill
        return imageView
    }()
    
    var positionCircle: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red:0.61, green:0.81, blue:0.93, alpha:1.0).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        return shapeLayer
    }()
    
    var crownImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleToFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none // remove silly background
        self.backgroundColor = UIColor.clear
        
        cellWidth = UIScreen.main.bounds.width - 20
        
        self.addSubview(backgroundImage)
        backgroundImage.frame.size.width = cellWidth
        backgroundImage.frame.size.height = cellHeight
        
        self.addSubview(cardDivider)
        cardDivider.frame.size.width = cellWidth
        cardDivider.frame.size.height = 2
        cardDivider.frame.origin.y = self.frame.origin.y + self.frame.size.height * 0.7
        //cardDivider.frame.origin.x = self.frame.origin.x + 40
        
        self.addSubview(posView)
        posView.centerXAnchor.constraint(equalTo: self.leftAnchor, constant: 30).isActive = true
        posView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(nameView)
        nameView.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -20).isActive = true
        nameView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameView.bottomAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(scoreView)
        scoreView.leftAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scoreView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        scoreView.topAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        scoreView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.layer.addSublayer(positionCircle)
        
        self.addSubview(crownImage)
        crownImage.frame.origin.x = 60
        crownImage.frame.origin.y = 5
        crownImage.frame.size.width = 25
        crownImage.frame.size.height = 20
    }
    
    // anything dependent on the player object must be executed here
    override func layoutSubviews() {
        super.layoutSubviews()
        
        posView.text = "#\(position)"
        nameView.text = name
        scoreView.text = "\(score) rep"
        
        if (isCurrentPlayer) {
            backgroundImage.image = UIImage(named: "player_card")
        } else {
            backgroundImage.image = UIImage(named: "player_card_far")
        }
        
        //crownImage.frame.origin.x = cellWidth - 5 - CGFloat(name.count * 10)
        if (position == 1) {
            crownImage.image = UIImage(named: "gold_crown")
        } else if (position == 2) {
            crownImage.image = UIImage(named: "silver_crown")
        } else if (position == 3) {
            crownImage.image = UIImage(named: "bronze_crown")
        } else {
            crownImage.image = nil
        }
        
        drawCircle()
    }
    
    func drawCircle() {
        let center = CGPoint(x: backgroundImage.frame.origin.x + 30, y: backgroundImage.frame.origin.y + backgroundImage.frame.size.height * 0.5)
        let radius = CGFloat(21)
        let startAngle = CGFloat(0)
        let endAngle = 2 * CGFloat.pi
        
        self.positionCircle.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
