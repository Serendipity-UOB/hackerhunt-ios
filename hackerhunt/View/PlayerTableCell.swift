//
//  PlayerTableCell.swift
//  hackerhunt
//
//  Created by Louis Heath on 24/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class PlayerTableCell: UITableViewCell {
    
    var player: Player = Player(realName: "test", hackerName: "test", id: -1)
    
    var realName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "Courier", size: 14)
        return textView
    }()
    
    var hackerName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor(red:0.21, green:0.11, blue:0.46, alpha:1.0)
        textView.textAlignment = .right
        textView.font = UIFont(name: "Courier", size: 14)
        return textView
    }()
    
    var intelBarBackground: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = UIColor.white
        return uiView
    }()
    
    var intelBarForeground: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = UIColor(red:0.42, green:0.66, blue:0.31, alpha:1.0)
        return uiView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none // remove silly background
        
        self.addSubview(realName)
        realName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        realName.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        realName.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        realName.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        
        self.addSubview(hackerName)
        hackerName.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        hackerName.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        hackerName.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        hackerName.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        
        self.addSubview(intelBarBackground)
        intelBarBackground.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 7).isActive = true
        intelBarBackground.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -7).isActive = true
        intelBarBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7).isActive = true
        intelBarBackground.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -17).isActive = true
        
        self.addSubview(intelBarForeground)
        intelBarForeground.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 7).isActive = true
        intelBarForeground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7).isActive = true
        intelBarForeground.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -17).isActive = true
    }
    
    // anything dependent on the player object must be executed here
    override func layoutSubviews() {
        super.layoutSubviews()
        
        realName.text = player.realName
        
        if (player.intel == 1.0) {
            hackerName.text = player.hackerName
        }
        
        setDefaultBackgroundColor()
        
        intelBarForeground.widthAnchor.constraint(equalTo: intelBarBackground.widthAnchor, multiplier: CGFloat(player.intel)).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            //self.backgroundColor = UIColor.purple
        } else {
            setDefaultBackgroundColor()
        }
    }
    
    func setDefaultBackgroundColor() {
        if (player.nearby) {
            self.backgroundColor = UIColor(red:0.57, green:0.57, blue:0.80, alpha:1.0) // #9191CD
        } else {
            self.backgroundColor = UIColor(red:0.37, green:0.37, blue:0.53, alpha:1.0) // #5E5E86
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
