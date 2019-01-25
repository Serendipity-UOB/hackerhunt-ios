//
//  PlayerTableCell.swift
//  hackerhunt
//
//  Created by Louis Heath on 24/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class PlayerTableCell: UITableViewCell {
    
    var player: Player?
    
    var realName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "Courier", size: 14)
        textView.isScrollEnabled = false
        return textView
    }()
    
    var intelBarBackground: UIView = {
        let textView = UIView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.white
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        guard let player = self.player else { return }
        
        if (player.nearby) {
            self.backgroundColor = UIColor(red:0.57, green:0.80, blue:1.00, alpha:1.0) // #91CDFF
        } else {
            self.backgroundColor = UIColor(red:0.37, green:0.53, blue:1.00, alpha:1.0) // #5E86FF
        }
        
        self.addSubview(realName)
        realName.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        realName.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        realName.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        realName.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(intelBarBackground)
        intelBarBackground.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        intelBarBackground.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        intelBarBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        intelBarBackground.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -25).isActive = true
        intelBarBackground.heightAnchor.constraint(equalToConstant: 15).isActive = true
        intelBarBackground.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        
        if (intelBarBackground.hasAmbiguousLayout) {
            print("ambiguous")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let player = self.player else { return }
        if let playerRealName = player.realName {
            realName.text = playerRealName
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
