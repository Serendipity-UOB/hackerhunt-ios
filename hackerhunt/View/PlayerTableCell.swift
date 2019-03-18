//
//  PlayerTableCell.swift
//  hackerhunt
//
//  Created by Louis Heath on 24/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class PlayerTableCell: UITableViewCell {
    
    let cellHeight: CGFloat = 65
    var cellWidth: CGFloat = 0
    var cellY: CGFloat = 0
    
    var player: Player = Player(realName: "test", codeName: "test", id: -1)
    var isTarget: Bool = false
    var buttonsView: UIView?
    
    var percentagePositionConstraint: NSLayoutConstraint!
    
    var greyOutView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 1.0)
        return view
    }()
    
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
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()

    var codeName: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.textColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        textView.font = UIFont(name: "ShareTech-Regular", size: 16)
        textView.alpha = 0
        textView.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return textView
    }()
    
    var exchangeRequested: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont(name: "ShareTech-Regular", size: 13)
        textView.textColor = UIColor(red:0.58, green:0.74, blue:0.81, alpha:1.0)
        textView.textContainer.lineFragmentPadding = 0
        textView.text = "exchange requested"
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
    
    var evidencePercent: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.textColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        textView.font = UIFont(name: "ShareTechMono-Regular", size: 15)
        textView.backgroundColor = UIColor.clear
        textView.alpha = 1
        textView.textContainerInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        return textView
    }()
    
    var exchangeBtn: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "exchange_button"), for: .normal)
        button.setTitle("Exchange", for: .normal)
        button.titleLabel?.font = UIFont(name: "ShareTechMono-Regular", size: 15)
        button.isHidden = true
        return button
    }()
    
    var interceptBtn: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "intercept_button"), for: .normal)
        button.setTitle("Intercept", for: .normal)
        button.titleLabel?.font = UIFont(name: "ShareTechMono-Regular", size: 15)
        button.isHidden = true
        return button
    }()
    
    var exposeBtn: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "expose_button"), for: .normal)
        button.setTitle("Expose", for: .normal)
        button.titleLabel?.font = UIFont(name: "ShareTechMono-Regular", size: 15)
        button.isHidden = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        cellWidth = UIScreen.main.bounds.width - 20
        
        self.addSubview(backgroundImage)
        backgroundImage.frame.size.width = cellWidth
        backgroundImage.frame.size.height = cellHeight
        
        self.addSubview(playerCardDivider)
        playerCardDivider.frame.size.width = cellWidth - 40
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
        
        self.addSubview(evidencePercent)
        evidencePercent.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        percentagePositionConstraint = NSLayoutConstraint.init(item: evidencePercent, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -9)
        NSLayoutConstraint.activate([percentagePositionConstraint])
        
        self.addSubview(greyOutView)
        greyOutView.frame.size.width = UIScreen.main.bounds.width - 20
        greyOutView.frame.size.height = cellHeight + 1
        greyOutView.frame.origin.x = UIScreen.main.bounds.origin.x
        greyOutView.frame.origin.y = UIScreen.main.bounds.origin.y
        
        self.addSubview(exchangeRequested)
        exchangeRequested.rightAnchor.constraint(equalTo: playerCardDivider.rightAnchor, constant: -20).isActive = true
        exchangeRequested.topAnchor.constraint(equalTo: playerCardDivider.bottomAnchor, constant: 2).isActive = true
    }
    
    func initialiseButtons(_ buttonsView: UIView) {
        let buttonWidth = (UIScreen.main.bounds.width - 20 - 10) / 3
        let buttonHeight = cellHeight - 10
        
        buttonsView.addSubview(exchangeBtn)
        exchangeBtn.frame.size.width = buttonWidth
        exchangeBtn.frame.size.height = buttonHeight
        exchangeBtn.frame.origin.x = UIScreen.main.bounds.origin.x
        
        buttonsView.addSubview(interceptBtn)
        interceptBtn.frame.size.width = buttonWidth
        interceptBtn.frame.size.height = buttonHeight
        interceptBtn.frame.origin.x = UIScreen.main.bounds.origin.x + buttonWidth + 5
        
        buttonsView.addSubview(exposeBtn)
        exposeBtn.frame.size.width = buttonWidth
        exposeBtn.frame.size.height = buttonHeight
        exposeBtn.frame.origin.x = UIScreen.main.bounds.origin.x + 2 * (buttonWidth + 5)
        
        buttonsView.frame.size.width = UIScreen.main.bounds.width - 20
        buttonsView.frame.size.height = buttonHeight
        self.buttonsView = buttonsView
        
        // use these tags to identify which button was pressed
        exchangeBtn.tag = player.id
        interceptBtn.tag = player.id
        exposeBtn.tag = player.id
    }
    
    // anything dependent on the player object must be executed here
    override func layoutSubviews() {
        super.layoutSubviews()
        
        realName.text = player.realName
        evidencePercent.text = String(format: "%.f%%", player.evidence)
        if (player.codeNameDiscovered) {
            codeName.text = player.codeName
            codeName.backgroundColor = (isTarget) ? UIColor(red:0.88, green:0.40, blue:0.40, alpha:0.7) : UIColor(red:0.00, green:0.65, blue:0.93, alpha:0.54)
            codeName.alpha = 1
        }
        else {
            codeName.alpha = 0
        }
        
        if (player.evidence == 100.0) {
            percentagePositionConstraint.constant = -9
        }
        else if (player.evidence >= 10.0){
            percentagePositionConstraint.constant = -12
        }
        else {
            percentagePositionConstraint.constant = -15
        }
        
        setDefaultBackgroundColor()
        
        drawEvidenceBar()
        
        exchangeRequested.alpha = (player.exchangeRequested) ? 1 : 0
    }
    
    func drawEvidenceBar() {
        let center = CGPoint(x: backgroundImage.frame.origin.x + backgroundImage.frame.size.width - 30, y: backgroundImage.frame.origin.y + backgroundImage.frame.size.height * 0.5)
        let radius = CGFloat(21)
        let startAngle = -0.5 * CGFloat.pi
        let endAngle = 2 * CGFloat.pi * CGFloat(player.evidence/100.0) - 0.5 * CGFloat.pi
        
        // draw background
        self.evidenceCircleBg.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        
        // draw foreground
        self.evidenceCircle.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
    }

    func setDefaultBackgroundColor() {
        if (player.nearby) {
            backgroundImage.image = UIImage(named: "player_card")
            evidenceCircle.strokeColor = UIColor(red:0.61, green:0.81, blue:0.93, alpha:1.0).cgColor
            evidenceCircleBg.strokeColor = UIColor(red:0.02, green:0.20, blue:0.31, alpha:1.0).cgColor
        }
        else {
            backgroundImage.image = UIImage(named: "player_card_far")
            evidenceCircle.strokeColor = UIColor(red:0.69, green:0.67, blue:0.67, alpha:1.0).cgColor
            evidenceCircleBg.strokeColor = UIColor(red:0.02, green:0.10, blue:0.17, alpha:1.0).cgColor
        }
    }
    
    func hideButtons() {
        self.exchangeBtn.isHidden = true
        self.interceptBtn.isHidden = true
        self.exposeBtn.isHidden = true
        buttonsView?.isUserInteractionEnabled = false
    }
    
    func showButtons() {
        if let buttonsView = self.buttonsView {
            buttonsView.frame.origin.y = cellY + cellHeight + 4
        }
        self.exchangeBtn.isHidden = false
        self.interceptBtn.isHidden = false
        self.exposeBtn.isHidden = false
        buttonsView?.isUserInteractionEnabled = true
    }
    
    func greyOut() {
        self.greyOutView.alpha = 0.8
    }
    
    func ungreyOut() {
        self.greyOutView.alpha = 0
    }
    
    func isHidden() -> Bool {
        return self.greyOutView.alpha != 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

