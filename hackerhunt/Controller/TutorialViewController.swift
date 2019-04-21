//
//  TutorialViewController
//  hackerhunt
//
//  Created by Louis Heath on 03/04/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var players = [Player]()
    var target = "CookingKing"
    
    var gameState: GameState?
    var exitSegue = "undefinedSegue"
    
    @IBOutlet var parentView: UIView!
    
    @IBOutlet weak var backgroundGrid: UIImageView!
    
    @IBOutlet weak var agentName: UILabel!
    @IBOutlet weak var scoreAndRep: UILabel!
    
    @IBOutlet weak var targetBorder: UIImageView!
    @IBOutlet weak var yourTarget: UILabel!
    @IBOutlet weak var targetName: UILabel!
    
    @IBOutlet weak var timeBorder: UIImageView!
    @IBOutlet weak var time: UILabel!
    
    
    @IBOutlet weak var helpIcon: UIImageView!
    @IBOutlet weak var greyOutView: UIView!
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var interactionButtons: UIView!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var spyIcon: UIImageView!
    @IBOutlet weak var message: UITextView!
    
    @IBOutlet weak var exchangeRequestedBackground: UIImageView!
    @IBOutlet weak var exchangeRequestedAcceptButton: UIButton!
    @IBOutlet weak var exchangeRequestedRejectButton: UIButton!
    @IBOutlet weak var exchangeRequestedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeTestData()
        setMessageConstraints()
        setupPlayerTable()
        hideExchangeRequested()
    }
    
    func setMessageConstraints() {
        messageView.frame.origin.y = parentView.frame.size.height * 0.5 - 30
        messageView.frame.size.width = parentView.frame.size.width - 20
        
        messageImage.topAnchor.constraint(equalTo: messageView.topAnchor)
        messageImage.frame.size.width = messageView.frame.size.width
        messageImage.frame.size.height = 90
        
        spyIcon.frame.size.width = 56
        spyIcon.frame.size.height = 53
        
        message.frame.size.width = messageView.frame.size.width - 100
        message.frame.size.height = 150
        
        changeMessageText("Welcome to Spywhere.\nTap to begin your training")
    }
    
    func moveMessage(newY: CGFloat, newHeight: CGFloat) {
        messageView.frame.origin.y = newY
        messageImage.frame.size.height = newHeight
        spyIcon.frame.origin.y = newHeight * 0.5  - 25
        if newHeight == 70 {
            message.frame.origin.y = 19
        } else {
            message.frame.origin.y = 12
        }
    }
    
    func changeMessageText(_ text: String) {
        // to remedy xcode bug where text styling is deleted if unselectable
        message.isSelectable = true
        message.text = text
        message.isSelectable = false
    }
    
    /* tutorial flow */
    
    var tutorialStage = 0
    
    @IBAction func screenTapped(_ sender: Any) {
        if tutorialStage == 0 {
            scoreAndRep.text = "#1 / 0 rep  "
            reorderElements(toFront: [scoreAndRep], toBack: [])
            changeMessageText("This is your position and reputation.\nGet the most reputation to win!")
            moveMessage(newY: 60, newHeight: 110)
        } else if tutorialStage == 1 {
            scoreAndRep.text = "#1 / 0 rep /"
            reorderElements(toFront: [helpIcon], toBack: [scoreAndRep])
            changeMessageText("This is your current location.")
            moveMessage(newY: 60, newHeight: 70)
        } else if tutorialStage == 2 {
            reorderElements(toFront: [targetBorder, targetName, yourTarget], toBack: [helpIcon])
            changeMessageText("This is your target.")
            moveMessage(newY: 115, newHeight: 70)
        } else if tutorialStage == 3 {
            reorderElements(toFront: [timeBorder, time], toBack: [targetBorder, targetName, yourTarget])
            changeMessageText("This is the remaining game time.")
            moveMessage(newY: 115, newHeight: 80)
        } else if tutorialStage == 4 {
            reorderElements(toFront: [], toBack: [timeBorder, time])
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.ungreyOut()
            changeMessageText("This is another agent. The flag shows their current location.")
            moveMessage(newY: 190, newHeight: 90)
        } else if tutorialStage == 5 {
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.greyOut()
            nuhaCell.evidenceCircle.zPosition = 1000
            nuhaCell.evidenceCircleBg.zPosition = 1000
            nuhaCell.bringSubviewToFront(nuhaCell.evidencePercent)
            changeMessageText("This is how much evidence you've gathered about an agent.")
        } else if tutorialStage == 6 {
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.player.evidence = 100
            nuhaCell.player.codeNameDiscovered = true
            nuhaCell.bringSubviewToFront(nuhaCell.codeName)
            changeMessageText("If you have full evidence on the agent's activities their codename will be revealed.")
        } else if tutorialStage == 7 {
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.insertSubview(nuhaCell.codeName, aboveSubview: nuhaCell.realName)
            nuhaCell.insertSubview(nuhaCell.evidencePercent, aboveSubview: nuhaCell.codeName)
            nuhaCell.evidenceCircle.zPosition = 0
            nuhaCell.evidenceCircleBg.zPosition = 0
            nuhaCell.ungreyOut()
            getPlayerCell("Louis").ungreyOut()
            getPlayerCell("Tilly").ungreyOut()
            changeMessageText("These agents are nearby.\nTap Tilly to interact.")
            moveMessage(newY: 330, newHeight: 80)
        } else if tutorialStage == 8 {
            getPlayerCell("Nuha").greyOut()
            getPlayerCell("Louis").greyOut()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.cellY = playerTableView.frame.origin.y + tillyCell.frame.origin.y
            tillyCell.showButtons()
            tillyCell.interceptBtn.isHidden = true
            tillyCell.exposeBtn.isHidden = true
            changeMessageText("Press exchange to exchange evidence with this agent.")
        } else if tutorialStage == 10 {
            getPlayerCell("Nuha").ungreyOut()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence += 25
            tillyCell.hideButtons()
            tillyCell.layoutSubviews()
            
            // TODO green exchange accepted text
            
            let louisCell = getPlayerCell("Louis")
            louisCell.ungreyOut()
            louisCell.player.evidence += 10
            louisCell.layoutSubviews()
            changeMessageText("You gained evidence on Tilly from your exchange. Tilly also gave you evidence on Louis.")
            moveMessage(newY: 330, newHeight: 100)
        } else if tutorialStage == 11 {
            showExchangeRequested()
            exchangeRequestedLabel.text = "Tilly wants to exchange evidence with you."
            changeMessageText("Tilly has requested an exchange with you! Accept it!")
            moveMessage(newY: 330, newHeight: 80)
        } else if tutorialStage == 13 {
            changeMessageText("Tilly is exchanging with Louis. Tap Tilly again to intercept the exchange!")
        } else if tutorialStage == 14 {
            getPlayerCell("Louis").greyOut()
            getPlayerCell("Nuha").greyOut()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.cellY = playerTableView.frame.origin.y + tillyCell.frame.origin.y
            tillyCell.showButtons()
            tillyCell.exchangeBtn.isHidden = true
            tillyCell.exposeBtn.isHidden = true
            changeMessageText("Tap to deploy the spyware.")
            moveMessage(newY: 330, newHeight: 70)
        } else if tutorialStage == 16 {
            getPlayerCell("Nuha").ungreyOut()
            let louisCell = getPlayerCell("Louis")
            louisCell.ungreyOut()
            louisCell.player.evidence += 10
            louisCell.layoutSubviews()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence += 30
            tillyCell.player.codeNameDiscovered = true
            tillyCell.hideButtons()
            tillyCell.layoutSubviews()
            
            // TODO green intercept success text
            
            changeMessageText("Your intercept was successful. You gained evidence on Tilly and Louis.")
            moveMessage(newY: 330, newHeight: 90)
        } else if tutorialStage == 17 {
            getPlayerCell("Tilly").interactionRequested.alpha = 0
            changeMessageText("You have discovered Tilly's codename, and they are your target!\nTap on Tilly to expose her identity.")
            moveMessage(newY: 330, newHeight: 130)
        } else if tutorialStage == 18 {
            getPlayerCell("Nuha").greyOut()
            getPlayerCell("Louis").greyOut()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.cellY = playerTableView.frame.origin.y + tillyCell.frame.origin.y
            tillyCell.showButtons()
            tillyCell.exchangeBtn.isHidden = true
            tillyCell.interceptBtn.isHidden = true
            changeMessageText("Expose your target, releasing your evidence and increasing your reputation.")
            moveMessage(newY: 330, newHeight: 100)
        } else if tutorialStage == 20 {
            reorderElements(toFront: [], toBack: [scoreAndRep])
            getPlayerCell("Nuha").greyOut()
            getPlayerCell("Louis").greyOut()
            getPlayerCell("Tilly").greyOut()
            changeMessageText("The safety of the world is in your hands. Good luck!")
            moveMessage(newY: 250, newHeight: 80)
        } else if tutorialStage == 21 {
            // leave tutorial
            exitTutorial()
            tutorialStage = 0
            return
        } else { return }
        tutorialStage += 1
    }
    
    @objc func exchangeButtonAction(sender: UIButton!) {
        if tutorialStage == 9 {
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.disableExchange()
            tillyCell.interactionRequested.alpha = 1
            changeMessageText("Note: You can only have one exchange at a time!")
            tutorialStage += 1
        }
    }
    
    @objc func interceptButtonAction(sender: UIButton!) {
        if tutorialStage == 15 {
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.disableIntercept()
            tillyCell.interactionRequested.alpha = 1
            
            // TODO intercept pending text, rather than exchange requested
            
            changeMessageText("Note: You can only have one intercept active at once.")
            moveMessage(newY: 330, newHeight: 80)
            tutorialStage += 1
        }
    }
    
    @objc func exposeButtonAction(sender: UIButton!) {
        if tutorialStage == 19 {
            //getPlayerCell("Nuha").ungreyOut()
            //getPlayerCell("Louis").ungreyOut()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence = 0
            tillyCell.isTarget = false
            tillyCell.hideButtons()
            tillyCell.layoutSubviews()
            scoreAndRep.text = "#1 / 10 rep  "
            reorderElements(toFront: [scoreAndRep], toBack: [])
            changeMessageText("Your expose was succesful! You gained reputation and will be assigned your next target.")
            moveMessage(newY: 330, newHeight: 110)
            tutorialStage += 1
        }
    }
    
    @IBAction func acceptRequestedExchange(_ sender: Any) {
        if tutorialStage == 12 {
            hideExchangeRequested()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence += 25
            tillyCell.layoutSubviews()
            let louisCell = getPlayerCell("Louis")
            louisCell.player.evidence += 10
            louisCell.layoutSubviews()
            changeMessageText("You gained evidence on Tilly from your exchange. Tilly also gave you evidence on Louis.")
            moveMessage(newY: 330, newHeight: 100)
            tutorialStage += 1
        }
    }
    
    func getPlayerCell(_ agentRealName: String) -> PlayerTableCell {
        let playerCell = PlayerTableCell()
        for cell in playerTableView!.visibleCells {
            guard let ptCell = cell as? PlayerTableCell else { return playerCell }
            if ptCell.player.realName == agentRealName {
                return ptCell
            }
        }
        return playerCell
    }
    
    func reorderElements(toFront: [UIView], toBack: [UIView]) {
        for el in toBack {
            parentView.insertSubview(el, aboveSubview: backgroundGrid)
        }
        for el in toFront {
            parentView.bringSubviewToFront(el)
        }
    }
    
    func exitTutorial() {
        if self.exitSegue == "undefinedSegue" {
            print("no segue defined to exit tutorial")
        } else {
            self.performSegue(withIdentifier:self.exitSegue, sender:self);
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let registerViewController = segue.destination as? RegisterViewController {
            registerViewController.gameState = gameState
        }
    }
    
    func showExchangeRequested() {
        exchangeRequestedBackground.alpha = 1
        exchangeRequestedLabel.alpha = 1
        exchangeRequestedAcceptButton.isHidden = false
        exchangeRequestedRejectButton.isHidden = false
    }
    
    func hideExchangeRequested() {
        exchangeRequestedBackground.alpha = 0
        exchangeRequestedLabel.alpha = 0
        exchangeRequestedAcceptButton.isHidden = true
        exchangeRequestedRejectButton.isHidden = true
    }
    
    /* table view functionality */
    
    func makeTestData() {
        self.players = [
            Player(realName: "Nuha", codeName: "Headshot", id: 1),
            Player(realName: "Tilly", codeName: "CookingKing", id: 2),
            Player(realName: "Louis", codeName: "PuppyLover", id: 3),
            Player(realName: "David", codeName: "Weab", id: 4),
            Player(realName: "Tom", codeName: "Nunu", id: 5),
            Player(realName: "Steve", codeName: "Dave", id: 6),
            Player(realName: "Dave", codeName: "Steve", id: 7)
        ]
        self.players[0].nearby = true
        self.players[0].zone = 1
        self.players[0].evidence = 80
        self.players[1].nearby = true
        self.players[1].zone = 1
        self.players[1].evidence = 20
        self.players[2].nearby = true
        self.players[2].zone = 1
        self.players[3].zone = 0
        self.players[4].zone = 2
        self.players[5].zone = 3
        self.players[6].zone = 3
    }

    func setupPlayerTable() {
        playerTableView.register(PlayerTableCell.self, forCellReuseIdentifier: "playerTableCell")
        playerTableView.isScrollEnabled = false
        playerTableView.rowHeight = 65
        playerTableView.delegate = self
        playerTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTableView.dequeueReusableCell(withIdentifier: "playerTableCell") as! PlayerTableCell

        cell.player = self.players[indexPath.section]
        cell.isTarget = (cell.player.codeName == self.target)
        cell.exchangeBtn.addTarget(self, action: #selector(exchangeButtonAction), for: .touchUpInside)
        cell.interceptBtn.addTarget(self, action: #selector(interceptButtonAction), for: .touchUpInside)
        cell.exposeBtn.addTarget(self, action: #selector(exposeButtonAction), for: .touchUpInside)
        cell.initialiseButtons(interactionButtons)
        cell.cellY = playerTableView.frame.origin.y + cell.frame.origin.y // set global Y pos for moving the buttons around
        cell.greyOut()
        cell.layoutSubviews()
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.players.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5.0)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
}
