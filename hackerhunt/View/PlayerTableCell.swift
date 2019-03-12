//
//  PlayerTableCell.swift
//  hackerhunt
//
//  Created by Louis Heath on 24/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class PlayerTableCell: UITableViewCell {
    
    var player: Player = Player(realName: "test", codeName: "test", id: -1)
    var isTarget: Bool = false
    
    var backgroundImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "player_card"))
        imageView.contentMode = UIView.ContentMode.scaleToFill
        return imageView
    }()
    
    var realName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "ShareTech-Regular", size: 16)
        textView.textColor = UIColor(red:0.61, green:0.81, blue:0.93, alpha:1.0)
//        textView.backgroundColor = UIColor(red:0.88, green:0.40, blue:0.40, alpha:0.7)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    var codeName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
//        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        textView.font = UIFont(name: "ShareTech-Regular", size: 16)
//        textView.backgroundColor = UIColor(red:0.88, green:0.40, blue:0.40, alpha:0.7)
        textView.alpha = 0
        textView.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return textView
    }()
    
    var playerCardDivider: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "player_card_divider"))
        imageView.contentMode = UIView.ContentMode.scaleToFill
        return imageView
    }()
    
    var evidenceCircle: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red:0.61, green:0.81, blue:0.93, alpha:1.0).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        return shapeLayer
    }()
    
    var evidenceCircleBg: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red:0.02, green:0.20, blue:0.31, alpha:1.0).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        return shapeLayer
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        self.addSubview(backgroundImage)
        backgroundImage.frame.size.width = UIScreen.main.bounds.width - 20
        backgroundImage.frame.size.height = 65
        
        self.addSubview(playerCardDivider)
        playerCardDivider.frame.size.width = UIScreen.main.bounds.width - 60
        playerCardDivider.frame.size.height = 2
        playerCardDivider.frame.origin.y = self.frame.origin.y + self.frame.size.height * 0.6
        
        self.addSubview(realName)
        realName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        realName.topAnchor.constraint(equalTo: self.topAnchor, constant: -4).isActive = true
        realName.bottomAnchor.constraint(equalTo: self.playerCardDivider.topAnchor, constant: 0).isActive = true

        self.addSubview(codeName)
        codeName.leftAnchor.constraint(equalTo: self.realName.leftAnchor, constant: 0).isActive = true
        codeName.topAnchor.constraint(equalTo: playerCardDivider.bottomAnchor, constant: 7).isActive = true
        
        self.layer.addSublayer(evidenceCircleBg)
        self.layer.addSublayer(evidenceCircle)
    }
    
    // anything dependent on the player object must be executed here
    override func layoutSubviews() {
        super.layoutSubviews()

        realName.text = player.realName
        print(player.intel)
        if (player.intel == 100.0) {
            codeName.text = player.codeName
            codeName.backgroundColor = (isTarget) ? UIColor(red:0.88, green:0.40, blue:0.40, alpha:0.7) : UIColor(red:0.00, green:0.65, blue:0.93, alpha:0.54)
            codeName.alpha = 1
        }
        else {
            codeName.text = "CookingKing"
        }
        
        setDefaultBackgroundColor()
        
        drawEvidenceBar()
    }
    
    func drawEvidenceBar() {
        let center = CGPoint(x: backgroundImage.frame.origin.x + backgroundImage.frame.size.width - 23, y: backgroundImage.frame.origin.y + backgroundImage.frame.size.height * 0.5)
        let radius = CGFloat(16)
        let startAngle = -0.5 * CGFloat.pi
        let endAngle = 2 * CGFloat.pi * CGFloat(player.intel/100.0) - 0.5 * CGFloat.pi
        
        // draw background
        self.evidenceCircleBg.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: true).cgPath
        
        // draw foreground
        self.evidenceCircle.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            self.alpha = 0.8
        } else {
            setDefaultBackgroundColor()
        }
    }


    func setDefaultBackgroundColor() {
        if (player.nearby) {
            backgroundImage.image = UIImage(named: "player_card")
            evidenceCircle.strokeColor = UIColor(red:0.61, green:0.81, blue:0.93, alpha:1.0).cgColor
            evidenceCircleBg.strokeColor = UIColor(red:0.02, green:0.20, blue:0.31, alpha:1.0).cgColor
        }
        else if (player.hide) {
            self.alpha = 0.25
        }
        else {
            backgroundImage.image = UIImage(named: "player_card_far")
            evidenceCircle.strokeColor = UIColor(red:0.69, green:0.67, blue:0.67, alpha:1.0).cgColor
            evidenceCircleBg.strokeColor = UIColor(red:0.02, green:0.10, blue:0.17, alpha:1.0).cgColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

