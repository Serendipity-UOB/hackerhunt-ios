//
//  WelcomeTutViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 03/04/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class WelcomeTutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var players: [Player] = []
    var target: String = "CookingKing"
    
    @IBOutlet weak var greyOutView: UIView!
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var interactionButtons: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeTestData()
    }
    
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
        self.players[0].evidence = 100
        self.players[1].evidence = 25
        self.players[2].evidence = 100
        self.players[3].evidence = 50
        self.players[4].evidence = 50
        self.players[5].evidence = 50
        self.players[6].evidence = 50
        self.players[0].codeNameDiscovered = true
        self.players[2].codeNameDiscovered = true
    }

    func setupPlayerTable() {
        playerTableView.register(PlayerTableCell.self, forCellReuseIdentifier: "playerTableCell")
        playerTableView.rowHeight = 65
        playerTableView.delegate = self
        playerTableView.dataSource = self
    }

    /* table view functionality */

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTableView.dequeueReusableCell(withIdentifier: "playerTableCell") as! PlayerTableCell

        cell.player = self.players[indexPath.section]
        cell.isTarget = (cell.player.codeName == self.target)

//        cell.exchangeBtn.addTarget(self, action: #selector(exchangeButtonAction), for: .touchUpInside)
//        cell.interceptBtn.addTarget(self, action: #selector(interceptButtonAction), for: .touchUpInside)
//        cell.exposeBtn.addTarget(self, action: #selector(exposeButtonAction), for: .touchUpInside)

        cell.initialiseButtons(interactionButtons)
        cell.cellY = playerTableView.frame.origin.y + cell.frame.origin.y // set global Y pos for moving the buttons around
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

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        let player = gameState!.allPlayers[indexPath.section]
//        if (player.nearby) {
//            let cellToShow = playerTableView.cellForRow(at: indexPath) as! PlayerTableCell
//            greyOutAllCells()
//            cellToShow.ungreyOut()
//            cellToShow.showButtons()
//            self.tapToCloseLabel.alpha = 1.0
//        }
//        else {
//            self.logVC.setMessage(farAwayPlayerSelected: player.realName)
//            self.showLog()
//        }
        return indexPath
    }
}
