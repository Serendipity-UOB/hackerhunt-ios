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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeTestData()
        setMessageConstraints()
        setupPlayerTable()
    }
    
    func setMessageConstraints() {
        messageView.frame.origin.y = parentView.frame.size.height * 0.5 - 30
        messageView.frame.size.width = parentView.frame.size.width - 20
        
        messageImage.topAnchor.constraint(equalTo: messageView.topAnchor)
        messageImage.frame.size.width = messageView.frame.size.width
        messageImage.frame.size.height = 70
        
        spyIcon.frame.size.width = 56
        spyIcon.frame.size.height = 53
        
        message.frame.size.width = messageView.frame.size.width - 100
        message.frame.size.height = 100
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
            reorderElements(toFront: [agentName, scoreAndRep], toBack: [])
            changeMessageText("This is your state.\nGain the most reputation to win the game")
            moveMessage(newY: 60, newHeight: 90)
        } else if tutorialStage == 1 {
            reorderElements(toFront: [targetBorder, targetName, yourTarget], toBack: [agentName, scoreAndRep])
            changeMessageText("This is your target")
            moveMessage(newY: 115, newHeight: 70)
        } else if tutorialStage == 2 {
            reorderElements(toFront: [timeBorder, time], toBack: [targetBorder, targetName, yourTarget])
            changeMessageText("This is the remaining game time")
            moveMessage(newY: 115, newHeight: 80)
        } else if tutorialStage == 3 {
            reorderElements(toFront: [], toBack: [timeBorder, time])
            changeMessageText("This is another agent. The flag shows their current location")
            moveMessage(newY: 190, newHeight: 90)
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.ungreyOut()
        } else if tutorialStage == 4 {
            changeMessageText("This icon displays how much evidence you've gathered about an agent")
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.greyOut()
            nuhaCell.evidenceCircle.zPosition = 1000
            nuhaCell.bringSubviewToFront(nuhaCell.evidencePercent)
        } else if tutorialStage == 5 {
            changeMessageText("If you have full evidence on the agent's activities their codename will be revealed")
            let nuhaCell = getPlayerCell("Nuha")
            nuhaCell.player.evidence = 100
            nuhaCell.player.codeNameDiscovered = true
            nuhaCell.evidenceCircleBg.zPosition = 1000
            nuhaCell.bringSubviewToFront(nuhaCell.codeName)
        } else if tutorialStage == 6 {
            // nuhaCell.insertSubview(nuhaCell.codeName, aboveSubview: )
            
        } else {
            // leave tutorial
            exitTutorial()
            tutorialStage = -1
        }
        tutorialStage += 1
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
    
    /* table view functionality */
    
    func makeTestData() {
        self.players = [
            Player(realName: "Nuha", codeName: "CookingKing", id: 1),
            Player(realName: "Tilly", codeName: "Vegan", id: 2),
            Player(realName: "Louis", codeName: "PuppyLover", id: 3),
            Player(realName: "David", codeName: "Weab", id: 4),
            Player(realName: "Tom", codeName: "Nunu", id: 5),
            Player(realName: "Steve", codeName: "Dave", id: 6),
            Player(realName: "Dave", codeName: "Steve", id: 7)
        ]
        self.players[0].nearby = true
        self.players[1].nearby = true
        self.players[2].nearby = true
        self.players[0].evidence = 25
        self.players[1].evidence = 25
        self.players[2].evidence = 100
        self.players[3].evidence = 50
        self.players[4].evidence = 50
        self.players[5].evidence = 50
        self.players[6].evidence = 50
        self.players[2].codeNameDiscovered = true
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

//        cell.exchangeBtn.addTarget(self, action: #selector(exchangeButtonAction), for: .touchUpInside)
//        cell.interceptBtn.addTarget(self, action: #selector(interceptButtonAction), for: .touchUpInside)
//        cell.exposeBtn.addTarget(self, action: #selector(exposeButtonAction), for: .touchUpInside)
//        cell.initialiseButtons(interactionButtons)
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
