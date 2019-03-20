//
//  LeaderboardViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 24/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var gameState: GameState!
    
    var dummyScores = [ 15, 13, 9, 8, 2 ]
    
    @IBOutlet weak var leaderboardTable: UITableView!
    
    var alertVC : AlertViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeaderboardTable()

    }
    
    /* tableView setup */
    
    func setupLeaderboardTable() {
        leaderboardTable.register(LeaderBoardTableCell.self, forCellReuseIdentifier: "leaderboardTableCell")
        leaderboardTable.rowHeight = 60
        leaderboardTable.delegate = self
        leaderboardTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTable.dequeueReusableCell(withIdentifier: "leaderboardTableCell") as! LeaderBoardTableCell
        cell.position = indexPath.section + 1
        cell.name = gameState.allPlayers[indexPath.section].realName
        cell.score = gameState.allPlayers[indexPath.section].score
        cell.isCurrentPlayer = (gameState.allPlayers[indexPath.section].id == gameState.player!.id)
        cell.layoutSubviews()
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameState!.allPlayers.count
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
    
    func showAlert() {
        self.addChild(alertVC)
        self.view.addSubview(alertVC.view)
        alertVC.didMove(toParent: self)
        alertVC.showAnimate()
        alertVC.isShowing = true
    }
    
    @IBAction func exitGame() {
        self.performSegue(withIdentifier:"transitionToStart", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let startViewController = segue.destination as? StartViewController {
            let gameState = GameState()
            let beaconListener = BeaconListener(withState: gameState)
            
            startViewController.gameState = gameState
            startViewController.beaconListener = beaconListener
        }
    }
}
