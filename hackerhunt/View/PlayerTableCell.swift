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
    
    var backgroundImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "player_card"))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        return imageView
    }()
    
    var realName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "ShareTech-Regular", size: 14)
        textView.textColor = UIColor(red:0.61, green:0.81, blue:0.93, alpha:1.0)
        return textView
    }()

    var codeName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(red:0.21, green:0.11, blue:0.46, alpha:1.0)
        textView.textAlignment = .right
        textView.font = UIFont(name: "ShareTech-Regular", size: 14)
        return textView
    }()
    
    var evidenceCircle: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red:0.61, green:0.81, blue:0.93, alpha:1.0).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.clear.cgColor
        return shapeLayer
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        self.addSubview(backgroundImage)
        backgroundImage.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(realName)
        realName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        realName.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        realName.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        realName.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true

        self.addSubview(codeName)
        codeName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        codeName.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        realName.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        codeName.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        
        self.layer.addSublayer(evidenceCircle)
    }
    
    // anything dependent on the player object must be executed here
    override func layoutSubviews() {
        super.layoutSubviews()

        realName.text = player.realName

        if (player.intel == 1.0) {
            codeName.text = player.codeName
        }
        else {
            codeName.text = ""
        }
        
        setDefaultBackgroundColor()
        
        drawEvidenceBar()
    }
    
    func drawEvidenceBar() {
        let center = self.center
        let startAngle = -0.5 * CGFloat.pi
        let endAngle = 2 * CGFloat.pi * CGFloat(player.intel) - 0.5 * CGFloat.pi
        let circularPath = UIBezierPath(arcCenter: center, radius: 10, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.evidenceCircle.path = circularPath.cgPath
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
        }
        else if (player.hide) {
            self.alpha = 0.25
        }
        else {
            backgroundImage.image = UIImage(named: "player_card_far")
        }
//        backgroundImage.bounds = self.bounds
//        backgroundImage.frame = self.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
