//
//  LeaderboardTableCell.swift
//  hackerhunt
//
//  Created by Louis Heath on 26/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class LeaderBoardTableCell: UITableViewCell {
    
    var position: Int = 0
    var name: String = "test"
    var score: Int = 0
    var isCurrentPlayer: Bool = false
    
    var posView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "Courier", size: 18)
        return textView
    }()
    
    var nameView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "Courier", size: 18)
        return textView
    }()
    
    var scoreView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .right
        textView.font = UIFont(name: "Courier", size: 18)
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none // remove silly background
        self.backgroundColor = UIColor(red:0.37, green:0.37, blue:0.53, alpha:1.0) // #5E5E86
        
        self.addSubview(posView)
        posView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        posView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        posView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        posView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.15).isActive = true
        
        self.addSubview(nameView)
        nameView.leftAnchor.constraint(equalTo: posView.rightAnchor, constant: 5).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        nameView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        
        self.addSubview(scoreView)
        scoreView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        scoreView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scoreView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scoreView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
    }
    
    // anything dependent on the player object must be executed here
    override func layoutSubviews() {
        super.layoutSubviews()
        
        posView.text = "#\(position)"
        nameView.text = name
        scoreView.text = "\(score)"
        
        if (isCurrentPlayer) {
            posView.textColor = UIColor.white
            nameView.textColor = UIColor.white
            scoreView.textColor = UIColor.white
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
