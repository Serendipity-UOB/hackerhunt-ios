//
//  MainGameViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class MainGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var gameState: GameState!
    var timer = Timer()
    
    @IBOutlet weak var playerTableView: UITableView!
    
    var terminalVC : TerminalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminalViewController") as! TerminalViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerTable()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.terminalVC.setMessage(homeBeacon: self.gameState.homeBeacon!.name)
            self.showTerminal()
        })
        
        // startCheckingForHomeBeacon()
    }
    
    func startCheckingForHomeBeacon() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MainGameViewController.checkForHomeBeacon), userInfo: nil, repeats: true)
    }
    
    @objc func checkForHomeBeacon() {
        if (self.gameState.getNearestBeacon() == "A") {
            // GET /startInfo
            
            // success: { all_players[{id, real_name, hacker_name}] }
            //  get all_players and put in gameState
            //  populate UITableView with players
            //  startPollingForUpdates()
            
            // failure:
            //  display error message on terminal popup
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.hideTerminal()
            })
        }
    }
    
    func startPollingForUpdates() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MainGameViewController.pollForUpdates), userInfo: nil, repeats: true)
    }
    
    @objc func pollForUpdates() {
        // check for game over
        //  gameOver()
        
        // POST /playerUpdate { player_id, beacons[{beacon_minor, rssi}] }
        
        // success: { nearby_players[], state{[points], position}, [update[]] }
        //  process new information
        //  updates:
        //   "taken_down":  deleteHalfOfIntel(), show terminal message. tap to close message
        //   "req_new_target":  clear target in gameState, show terminal message, requestNewTarget()
        
        // failure:
        //  ignore? or count failures and alert after x amount
    }
    
    func requestNewTarget() {
        // POST /newTarget { player_id }
        
        // success: { target_player_id }
        //  update gameState
        //  wait until player has gone to homeBeacon
        //  close terminal message
        
        // failure:
        //  try again x amount of times
    }
    
    @IBAction func exchangePressed() {
        // show terminal message
        //  player has option to close terminal message
        // detect NFC - get player_id
        // update terminal message to say "SCAN_SUCCESS"
        // mutualExchangeWith( player_id )
    }
    
    func mutualExchangeWith(player: Int, attemptNumber: Int) {
        if (attemptNumber > 10) {
            // show error on terminal popup, tap to close
            return
        }
        // POST /exchange { interacter_id, interactee_id }
        
        // 200 success: { secondary_id }
        //  gameState.incrementIntelFor(playerOne: interactee_id, playerTwo: secondary_id )
        //  show success message, tap to close
        
        // 100 continue || error:
        //  every 2 seconds: mutualExchangeWith(player, attemptNumber + 1)
    }
    
    @IBAction func takeDownPressed() {
        // show terminal message
        //  player has option to close terminal message
        // detect NFC - get player_id
        // update terminal message to say "SCAN_SUCCESS"
        // takeDown( player_id )
    }
    
    func takeDown(player: Int) {
        // POST /takeDown { player_id, target_id }
        
        // 200 success:
        //  update message for success, requestNewTarget()
        
        // 400 failure:
        //  display TAKEDOWN_FAILURE terminal message, tap to close
    }
    
    func gameOver() {
        // GET /endInfo
        
        // response { leaderboard[{player_id, player_name, score}] }
        
        // segue to leaderboard page
    }
    
    func showTerminal() {
        self.addChild(terminalVC)
        self.view.addSubview(terminalVC.view)
        terminalVC.didMove(toParent: self)
        terminalVC.showAnimate()
    }
    
    func hideTerminal() {
        terminalVC.willMove(toParent: nil)
        terminalVC.removeFromParent()
        terminalVC.removeAnimate()
    }
    
    /* tableView setup */
    
    func setupPlayerTable() {
        playerTableView.register(PlayerTableCell.self, forCellReuseIdentifier: "playerTableCell")
        playerTableView.rowHeight = 50
        playerTableView.delegate = self
        playerTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTableView.dequeueReusableCell(withIdentifier: "playerTableCell") as! PlayerTableCell
        cell.player = gameState!.allPlayers[indexPath.section]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameState!.allPlayers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(10.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
}
