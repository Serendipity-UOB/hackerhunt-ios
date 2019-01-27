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
    var countdownTimer = Timer()
    var selectedCell: IndexPath?
    var exchange: Bool = false
    @IBOutlet weak var pointsValue: UILabel!
    @IBOutlet weak var positionValue: UILabel!
    @IBOutlet weak var countdownValue: UILabel!
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var targetName: UILabel!
    
    var terminalVC : TerminalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminalViewController") as! TerminalViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePointsValue(0)
        updatePositionValue(0)
        startTiming()
        setupPlayerTable()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.terminalVC.setMessage(homeBeacon: self.gameState.homeBeacon!.name)
            self.showTerminal()
        })
        
        startCheckingForHomeBeacon()
        
    }
    
    func startCheckingForHomeBeacon() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MainGameViewController.checkForHomeBeacon), userInfo: nil, repeats: true)
    }
    
    @objc func checkForHomeBeacon() {
        if (self.gameState.getNearestBeacon() == "A") { // needs to be changed to homeBeacon
            
            let request = ServerUtils.get(from: "/startInfo")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else { return }
                
                let statusCode: Int = httpResponse.statusCode
                
                if (statusCode == 200) {
                    
                    
                    guard let data = data else { return }
                    
                    do {
                        
                        let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        guard let allPlayers = bodyJson as? [String:[Any]] else { return }
                        guard let listAllPlayers = allPlayers["all_players"] as? [[String: Any]] else { return }
                        
                        // add players but yourself to allPlayers
                        for player in listAllPlayers {
                            let hackerName: String = player["hackerName"] as! String
                            if (hackerName != self.gameState.player?.hackerName) {
                                let realName: String = player["realName"] as! String
                                let id: Int = player["id"] as! Int
                                let player: Player = Player(realName: realName, hackerName: hackerName, id: id)
                                player.intel = 0.6
                                self.gameState.allPlayers.append(player)
                            }
                        }
                        // load players into table view
                        DispatchQueue.main.async {
                            self.playerTableView.reloadData()
                            self.startPollingForUpdates()
                        }
                        
                        // request first target
                        self.requestNewTarget()

                    } catch {}
                    
                }
                
            }.resume()
            // failure:
            //  display error message on terminal popup
            
        }
    }
    
    func startPollingForUpdates() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(MainGameViewController.pollForUpdates), userInfo: nil, repeats: true)
    }
    
    @objc func pollForUpdates() {
        if (isGameOver()) {
            print("Game over")
            enableSwipeForLeaderboard()
            gameOver()
        }
        else {
            print("polling for updates")
            
            var data: [String:Any] = [:]
            data["player_id"] = self.gameState.player?.id
            data["beacons"] = createBeaconList()
            
            let request = ServerUtils.post(to: "/playerUpdate", with: data)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard let httpResponse = response as? HTTPURLResponse else { return }
                
                let statusCode: Int = httpResponse.statusCode
                
                if (statusCode == 200) {
                    guard let data = data else { return }
                    
                    do {
                        let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        guard let bodyDict = bodyJson as? [String: Any] else { return }
                        
                        guard let takenDown: Int = bodyDict["taken_down"] as? Int else { return }
                        guard let nearbyPlayers: [Int] = bodyDict["nearby_players"] as? [Int] else { return }
                        guard let points: Int = bodyDict["points"] as? Int else { return }
                        guard let requestNewTarget: Int = bodyDict["req_new_target"] as? Int else { return }
                        guard let position: Int = bodyDict["position"] as? Int else { return }
                        self.handleTakenDown(takenDown)
                        self.handleNearbyPlayers(nearbyPlayers)
                        self.handlePoints(points)
                        self.handleRequestNewTarget(requestNewTarget)
                        self.handlePosition(position)
                        
                        DispatchQueue.main.async {
                            self.playerTableView.reloadData()
                        }
                        
                        
                    } catch {}
                }
                
                
            }.resume()
            
        }
        
        // failure:
        //  ignore? or count failures and alert after x amount
    }
    
    func handleTakenDown(_ takenDown: Int) {
        if (takenDown == 1) {
            self.gameState.deleteHalfOfIntel()
        }
    }
    
    func handleNearbyPlayers(_ nearbyPlayers: [Int]) {
        for p in self.gameState.allPlayers {
            if nearbyPlayers.contains(p.id) {
                p.nearby = true
            }
        }
        self.gameState.allPlayers = self.gameState.prioritiseNearbyPlayers()
    }
    
    func handlePoints(_ points: Int) {
        updatePointsValue(points)
    }
    
    func handleRequestNewTarget(_ requestNewTarget: Int) {
        if (requestNewTarget == 1) {
            DispatchQueue.main.async {
                self.requestNewTarget()
            }
            
        }
    }
    
    func handlePosition(_ position: Int) {
        updatePositionValue(position)
    }
    
    func createBeaconList() -> [[String:Any]] {
        var beacons_list : [[String:Any]] = []
        for beacon in self.gameState!.nearbyBeacons! {
            var temp: [String:Any] = [:]
            temp["beacon_minor"] = beacon.minor
            temp["rssi"] = beacon.rssi
            beacons_list.append(temp)
        }
        return beacons_list
    }
    
    func requestNewTarget() {
        
        var data: [String:Int] = [:]
        data["player_id"] = self.gameState.player?.id
        
        let request = ServerUtils.post(to: "/newTarget", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                guard let responsedata = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let newTarget = bodyDict["target_player_id"] as? Int else { return }
                    self.gameState.currentTarget = self.gameState.getPlayerById(newTarget)
                    
                    DispatchQueue.main.async {
                        self.targetName.text = self.gameState.currentTarget?.hackerName
                    }
                    
                } catch {}
            }
            
        }.resume()
        
        //  wait until player has gone to homeBeacon
        //  close terminal message
        
        // failure:
        //  try again x amount of times
    }
    
    @IBAction func exchangePressed() {
        print("exchanging")
        // stretch button
        // hide not nearby
        for p in self.gameState.allPlayers {
            if (!p.nearby) {
                p.hide = true
            }
        }
        DispatchQueue.main.async {
            self.playerTableView.reloadData()
        }
        
        self.exchange = true
    }
    
    func doExchange() {
        // create data
        let interacteeId = self.selectedCell!.section
        var data: [String:Any] = [:]
        data["interacter_id"] = self.gameState.player!.id
        data["interactee_id"] = interacteeId
        
        var contacts: [Int] = []
        for p in self.gameState.allPlayers {
            if (p.intel > 0.0) {
                contacts.append(p.id)
            }
        }
        data["contacts"] = contacts
        
        // send request
        exchangeRequest(data: data, interactee: interacteeId)
        
        // wait for completion
        // increment primary and secondary intel
        // turn off variable
        self.exchange = false
    }
    
    func exchangeRequest(data: [String:Any], interactee: Int) {
        let request = ServerUtils.post(to: "/exchange", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 200:
                guard let responsedata = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let secondaryId = bodyDict["secondary_id"] as? Int else { return }
                    self.gameState.incrementIntelFor(playerOne: interactee, playerTwo: secondaryId)
                    
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                    }
                    
                } catch {}
            default:
                print("something's gone wrong")
            }
            
        }.resume()
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
    
    func isGameOver() -> Bool {
        if (self.gameState.countdown! <= 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func gameOver() {
        // GET /endInfo
        
        // response { leaderboard[{player_id, player_name, score}] }
        
        // segue to leaderboard page
    }
    
    /* Terminal View */
    
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
        playerTableView.rowHeight = 45
        playerTableView.delegate = self
        playerTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTableView.dequeueReusableCell(withIdentifier: "playerTableCell") as! PlayerTableCell
        cell.player = gameState!.allPlayers[indexPath.section]
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
        return CGFloat(10.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // deselect row if it is currently selected
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
            indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            return nil
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCell = indexPath
        if (exchange) {
            doExchange()
        }
    }
    
    /* pointsValue setup */
    
    func updatePointsValue(_ value: Int) {
        gameState.points = value
        DispatchQueue.main.async {
            self.pointsValue.text = String(self.gameState.points)
        }
    }
    
    /* positionValue setup */
    
    func updatePositionValue(_ value: Int) {
        gameState.position = value
        DispatchQueue.main.async {
            self.positionValue.text = String(self.gameState.position)
        }
    }
    
    /* countdownValue setup */
    
    func startTiming() {
        let currentTotal = Int(now())
        self.gameState.countdown = self.gameState.endTime! - currentTotal
        self.countdownTimer.invalidate()
        self.countdownValue.text = prettyTimeFrom(seconds: self.gameState.countdown!)
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JoinGameViewController.decrementTimer), userInfo: nil, repeats: true)
    }
    
    @objc func decrementTimer() {
        self.gameState.countdown! -= 1
        if (self.gameState.countdown! >= 0) {
            countdownValue.text = prettyTimeFrom(seconds: self.gameState.countdown!)
        }
    }
    
    /* transition */
    
    
    func enableSwipeForLeaderboard() {
        // TODO this will be replaced by gameOver
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(goToLeaderboard))
        swipeUp.direction = .up
        self.playerTableView.isScrollEnabled = false
        self.playerTableView.addGestureRecognizer(swipeUp)
//        self.view.addGestureRecognizer(swipeUp)
    }
    
    @objc func goToLeaderboard(_ sender: UITapGestureRecognizer) {
        timer.invalidate()
        countdownTimer.invalidate()
        self.performSegue(withIdentifier:"transitionToLeaderboard", sender:self);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let leaderboardViewController = segue.destination as? LeaderboardViewController {
            leaderboardViewController.gameState = gameState
        }
    }
    
}
