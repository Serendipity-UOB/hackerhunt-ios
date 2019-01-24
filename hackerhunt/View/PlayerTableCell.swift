//
//  PlayerTableCell.swift
//  hackerhunt
//
//  Created by Louis Heath on 24/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class PlayerTableCell: UITableViewCell {
    
    var playerName: String?
    var playerNearby: Bool = false
    
    var messageView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "Courier", size: 14)
        textView.isScrollEnabled = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if (playerNearby) {
            self.backgroundColor = UIColor(red:0.57, green:0.80, blue:1.00, alpha:1.0) // #91CDFF
        } else {
            self.backgroundColor = UIColor(red:0.37, green:0.53, blue:1.00, alpha:1.0) // #5E86FF
        }
        
        self.addSubview(messageView)
        messageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        messageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let playerName = playerName {
            messageView.text = playerName
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
