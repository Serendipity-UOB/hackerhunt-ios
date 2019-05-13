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
    @IBOutlet weak var tapToContinue: UILabel!
    
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
            ungreyOutCell(withName: "Nuha")
            changeMessageText("This is another agent. The flag shows their current location.")
            moveMessage(newY: 190, newHeight: 90)
            tapToContinue.alpha = 1
        } else if tutorialStage == 1 {
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.player.evidence = 100
            nuhaCell.player.codeNameDiscovered = true
            nuhaCell.layoutSubviews()
            changeMessageText("If you have full evidence on the agent's activities their codename will be revealed.")
        } else if tutorialStage == 2 {
            ungreyOutCell(withName: "Louis")
            ungreyOutCell(withName: "Tilly")
            changeMessageText("These agents are nearby.\nTap Tilly to interact.")
            moveMessage(newY: 330, newHeight: 80)
            tapToContinue.alpha = 0
        } else if tutorialStage == 3 {
            greyOutCell(withName: "Nuha")
            greyOutCell(withName: "Louis")
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.card.isGreyedOut = false
            tillyCell.cellY = playerTableView.frame.origin.y + tillyCell.frame.origin.y
            tillyCell.showButtons()
            tillyCell.interceptBtn.isHidden = true
            tillyCell.exposeBtn.isHidden = true
            tillyCell.layoutSubviews()
            changeMessageText("Press exchange to exchange evidence with this agent.")
        } else if tutorialStage == 5 {
            scoreAndRep.text = "#1 / 1 rep /"
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence += 25
            tillyCell.hideButtons()
            tillyCell.player.exchangeRequested = false
            tillyCell.player.interactionResult = 1
            tillyCell.layoutSubviews()
            let louisCell = getPlayerCell("Louis")
            louisCell.player.card.isGreyedOut = false
            louisCell.player.evidence += 10
            louisCell.layoutSubviews()
            changeMessageText("You gained evidence on Tilly from your exchange. Tilly also gave you evidence on Louis.")
            moveMessage(newY: 330, newHeight: 100)
        } else if tutorialStage == 6 {
            getPlayerCell("Tilly").player.interactionResult = 0
            showExchangeRequested()
            exchangeRequestedLabel.text = "Tilly wants to exchange evidence with you."
            changeMessageText("Tilly has requested an exchange with you! Accept it!")
            moveMessage(newY: 330, newHeight: 80)
            tapToContinue.alpha = 0
        } else if tutorialStage == 8 {
            let louisCell = getPlayerCell("Louis")
            louisCell.player.card.isGreyedOut = true
            louisCell.layoutSubviews()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.cellY = playerTableView.frame.origin.y + tillyCell.frame.origin.y
            tillyCell.showButtons()
            tillyCell.exchangeBtn.isHidden = true
            tillyCell.exposeBtn.isHidden = true
            changeMessageText("Tap to intercept.")
            moveMessage(newY: 330, newHeight: 70)
        } else if tutorialStage == 10 {
            scoreAndRep.text = "#1 / 4 rep /"
            let louisCell = getPlayerCell("Louis")
            louisCell.player.card.isGreyedOut = false
            louisCell.player.evidence += 10
            louisCell.layoutSubviews()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence += 30
            tillyCell.player.codeNameDiscovered = true
            tillyCell.hideButtons()
            tillyCell.player.interceptRequested = false
            tillyCell.player.interactionResult = 1
            tillyCell.layoutSubviews()
            changeMessageText("Your intercept was successful. You gained evidence on Tilly and Louis.")
            moveMessage(newY: 330, newHeight: 90)
        } else if tutorialStage == 11 {
            getPlayerCell("Tilly").player.interactionResult = 0
            changeMessageText("You have discovered Tilly's codename, and she is your target!\nTap on Tilly to expose her identity.")
            moveMessage(newY: 330, newHeight: 130)
            tapToContinue.alpha = 0
        } else if tutorialStage == 12 {
            let louisCell = getPlayerCell("Louis")
            louisCell.player.card.isGreyedOut = true
            louisCell.layoutSubviews()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.cellY = playerTableView.frame.origin.y + tillyCell.frame.origin.y
            tillyCell.showButtons()
            tillyCell.exchangeBtn.isHidden = true
            tillyCell.interceptBtn.isHidden = true
            changeMessageText("Tap to expose.")
            moveMessage(newY: 330, newHeight: 70)
        } else if tutorialStage == 14 {
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.player.card.isGreyedOut = true
            nuhaCell.layoutSubviews()
            let louisCell = getPlayerCell("Louis")
            louisCell.player.card.isGreyedOut = true
            louisCell.layoutSubviews()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.card.isGreyedOut = true
            tillyCell.layoutSubviews()
            changeMessageText("The safety of the world is in your hands. Good luck!")
            moveMessage(newY: 250, newHeight: 80)
            tapToContinue.alpha = 1
        } else if tutorialStage == 15 {
            // leave tutorial
            exitTutorial()
            tutorialStage = 0
            return
        } else { return }
        tutorialStage += 1
    }
    
    func greyOutCell(withName name: String) {
        let cell = getPlayerCell(name)
        cell.player.card.isGreyedOut = true
        cell.greyOut()
        cell.layoutSubviews()
    }
    
    func ungreyOutCell(withName name: String) {
        let cell = getPlayerCell(name)
        cell.player.card.isGreyedOut = false
        cell.ungreyOut()
        cell.layoutSubviews()
    }
    
    @objc func exchangeButtonAction(sender: UIButton!) {
        if tutorialStage == 4 {
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.disableExchange()
            tillyCell.player.exchangeRequested = true
            tillyCell.layoutSubviews()
            changeMessageText("Note: You can only have one exchange at a time!")
            tutorialStage += 1
            tapToContinue.alpha = 1
        }
    }
    
    @objc func interceptButtonAction(sender: UIButton!) {
        if tutorialStage == 9 {
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.disableIntercept()
            tillyCell.player.interceptRequested = true
            tillyCell.layoutSubviews()
            changeMessageText("If evidence is shared during your intercept you will also receive it.")
            moveMessage(newY: 330, newHeight: 90)
            tutorialStage += 1
            tapToContinue.alpha = 1
        }
    }
    
    @objc func exposeButtonAction(sender: UIButton!) {
        if tutorialStage == 13 {
            scoreAndRep.text = "#1 / 14 rep /"
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.player.card.isGreyedOut = false
            nuhaCell.layoutSubviews()
            let louisCell = getPlayerCell("Louis")
            louisCell.player.card.isGreyedOut = false
            louisCell.layoutSubviews()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence = 0
            tillyCell.isTarget = false
            tillyCell.hideButtons()
            tillyCell.layoutSubviews()
            changeMessageText("Congratulations, your expose was successful.\nYou’ve used up your evidence and will get a new target.")
            moveMessage(newY: 330, newHeight: 110)
            tutorialStage += 1
            tapToContinue.alpha = 1
        }
    }
    
    @IBAction func acceptRequestedExchange(_ sender: Any) {
        if tutorialStage == 7 {
            scoreAndRep.text = "#1 / 2 rep /"
            hideExchangeRequested()
            let tillyCell = getPlayerCell("Tilly")
            tillyCell.player.evidence += 25
            tillyCell.layoutSubviews()
            let louisCell = getPlayerCell("Louis")
            louisCell.player.evidence += 10
            louisCell.layoutSubviews()
            changeMessageText("Tilly is exchanging with Louis. Tap Tilly again to intercept the exchange!")
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
        self.players[0].card = CardState(isGreyedOut: true)
        self.players[1].card = CardState(isGreyedOut: true)
        self.players[2].card = CardState(isGreyedOut: true)
        self.players[3].card = CardState(isGreyedOut: true)
        self.players[4].card = CardState(isGreyedOut: true)
        self.players[5].card = CardState(isGreyedOut: true)
        self.players[6].card = CardState(isGreyedOut: true)
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
