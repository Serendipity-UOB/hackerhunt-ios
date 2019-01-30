//
//  MainGameViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class MainGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: attributes
    var gameState: GameState!
    
    var updatesTimer = Timer()
    var countdownTimer = Timer()
    var exchangeTimer = Timer()
    var homeBeaconTimer = Timer()
    
    var selectedCell: IndexPath?
    var exchange: Bool = false
    var takedown: Bool = false
    var exchangeMessage: Bool = false
    
    @IBOutlet weak var pointsValue: UILabel!
    @IBOutlet weak var positionValue: UILabel!
    @IBOutlet weak var countdownValue: UILabel!
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var targetName: UILabel!
    
    var terminalVC : TerminalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminalViewController") as! TerminalViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCurrentPoints(0)
        startGameOverCountdown()
        setupPlayerTable()
        
        letTheChallengeBegin()
    }
    
    // MARK: startInfo
    
    func letTheChallengeBegin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.terminalVC.homeBeacon = self.gameState.homeBeacon!.name
            self.terminalVC.setMessage(gameStart: 1)
            self.showTerminal()
            self.startCheckingForHomeBeacon(withCallback: self.getStartInfo)
        })

    }
    
    func startCheckingForHomeBeacon(withCallback callback: @escaping () -> Void) {
        homeBeaconTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MainGameViewController.checkForHomeBeacon), userInfo: callback, repeats: true)
        homeBeaconTimer.fire()
    }
    
    @objc func checkForHomeBeacon() {
        if (/*self.gameState.getNearestBeaconMinor() == gameState.homeBeacon!.minor*/true) {
            let callback = homeBeaconTimer.userInfo as! (() -> Void)
            callback()
            print("here")
            
            
            let wait = (ServerUtils.testing) ? 4.0 : 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + wait, execute: self.hideTerminal)
            homeBeaconTimer.invalidate()
        }
    }
    
    func getStartInfo() -> Void {
        let request = ServerUtils.get(from: "/startInfo")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            if (statusCode == 200) {
                
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let allPlayers = bodyJson as? [String:[Any]] else { return }
                    guard let allPlayersList = allPlayers["all_players"] as? [[String: Any]] else { return }
                    
                    DispatchQueue.main.async {
                        self.gameState.initialisePlayerList(allPlayers: allPlayersList)
                        
                        self.playerTableView.reloadData()
                        
                        self.startPollingForUpdates()
                        
                        self.requestNewTarget()
                    }
                } catch {}
            } else {
                print("/startInfo failed")
                // do something if this happens a lot ?
            }
            }.resume()
    }
    
    // MARK: playerUpdate
    
    func startPollingForUpdates() {
        updatesTimer.invalidate()
        updatesTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.pollForUpdates), userInfo: nil, repeats: true)
        updatesTimer.fire()
    }
    
    @objc func pollForUpdates() {
        print("polling for updates")
        do {
            print(self.gameState.getNearestBeaconMinor())
        } catch {}
        if (self.gameState.isGameOver()) {
            print("game over")
            gameOver()
            
        } else {
            let data: [String:Any] = [
                "player_id": self.gameState.player?.id as Any,
                "beacons": self.gameState.createBeaconList()
            ]
            
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
                        self.setCurrentPoints(points)
                        self.handleRequestNewTarget(requestNewTarget)
                        self.handlePosition(position)
                        
                        DispatchQueue.main.async {
                            self.playerTableView.reloadData()
                        }
                    } catch {}
                } else {
                    print("/playerUpdate failed")
                    // do something if this happens a lot ?
                }
            }.resume()
        }
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
            } else {
                p.nearby = false
            }
        }
        self.gameState.allPlayers = self.gameState.prioritiseNearbyPlayers()
    }
    
    func setCurrentPoints(_ points: Int) {
        gameState.points = points
        DispatchQueue.main.async {
            self.pointsValue.text = String(self.gameState.points)
        }
    }
    
    func handleRequestNewTarget(_ requestNewTarget: Int) {
        if (requestNewTarget == 1) {
            DispatchQueue.main.async {
                self.terminalVC.setMessage(requestNewTarget: true)
                self.showTerminal()
                self.startCheckingForHomeBeacon(withCallback: self.requestNewTarget)
            }
        }
    }
    
    func handlePosition(_ position: Int) {
        gameState.position = position
        DispatchQueue.main.async {
            self.positionValue.text = String(self.gameState.position)
        }
    }
    
    // MARK: newTarget
    func requestNewTarget() -> Void {
        
        let data: [String:Int] = [
            "player_id": (self.gameState.player?.id)!
        ]
        
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
                    
                    DispatchQueue.main.async {
                        self.gameState.currentTarget = self.gameState.getPlayerById(newTarget)
                        
                        self.targetName.text = self.gameState.currentTarget?.hackerName
                    }
                    
                } catch {}
            } else {
                DispatchQueue.main.async {
                    self.terminalVC.message = "Couldn't retrieve new target"
                }
            }
        }.resume()
    }
    
    // MARK: exchange
    @IBAction func exchangePressed() {
        print("exchange btn pressed")
        // animate button
        
        self.gameState.hideFarAway()
        self.exchange = true
        
        DispatchQueue.main.async {
            self.playerTableView.reloadData()
        }
    }
    
    func doExchange() {
        // create data
        let interacteeIndex = self.selectedCell!.section
        let interacteeId = self.gameState.allPlayers[interacteeIndex].id
        
        
        if (gameState.playerIsNearby(interacteeId)) {
            let contactIds: [Int] = self.gameState.allPlayers.filter({ $0.intel > 0.0 }).map({ return $0.id })
            
            var validContacts: [[String: Int]] = []
            for c in contactIds {
                validContacts.append(["contact_id" : c])
            }
            
            let data: [String:Any] = [
                "interacter_id": self.gameState.player!.id,
                "interactee_id": interacteeId,
                "contact_ids": validContacts
            ]
            
            // send request
            exchangeTimer.invalidate()
            exchangeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.exchangeRequest), userInfo: data, repeats: true)
            // fire the first time to prevent waiting
            exchangeTimer.fire()
        } else {
            DispatchQueue.main.async {
                self.terminalVC.setMessage(tapToClose: true, message: "EXCHANGE_FAIL\n\nPlayer not nearby")
            }
        }
    }
    
    @objc func exchangeRequest() {
        let data: [String:Any] = exchangeTimer.userInfo as! [String:Any]
        print(data)
        let interactee: Int = data["interactee_id"] as! Int
        let request = ServerUtils.post(to: "/exchange", with: data)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 200:
                guard let responsedata = data else { return }
                print("status code 200")
                do {
                    self.exchangeTimer.invalidate()
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let secondaryId = bodyDict["secondary_id"] as? Int else { return }
                    
                    print("secondaryId " + String(secondaryId))
                    
                    self.gameState.incrementIntelFor(playerOne: interactee, playerTwo: secondaryId)
                    self.gameState.unhideAll()
                    self.exchange = false
                    
                    
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                        self.terminalVC.setMessage(tapToClose: true, message: "EXCHANGE_SUCCESS\n\nIntel gained")
                        if (self.exchangeMessage) { // don't do showTerminal if it's already up
                            self.terminalVC.viewWillAppear(false)
                        }
                        else {
                           self.showTerminal()
                        }
                        self.exchangeMessage = false
                    }
                } catch {}
            case 201, 202:
                print("status code " + String(statusCode))
                if (!self.exchangeMessage) { // don't do show terminal if it's already up
                    DispatchQueue.main.async {
                        print("popping up")
                        self.exchangeMessage = true
                        self.terminalVC.setMessage(tapToClose: false, message: "EXCHANGE_REQUESTED\n\nWaiting for handshake")
                        self.showTerminal()
                    }
                }
            case 400:
                print("status code " + String(statusCode))
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    print("failing")
                    self.terminalVC.setMessage(tapToClose: true, message: "EXCHANGE_FAIL\n\nHandshake incomplete")
                    self.terminalVC.viewWillAppear(false)
                    self.exchangeMessage = false
                }
            default:
                print("/exchange unexpected \(statusCode)")
            }
        }.resume()
    }
    
    // MARK: takeDown
    @IBAction func takeDownPressed() {
        // show terminal message
        //  player has option to close terminal message
        print("takedown pressed")
        self.gameState.hideFarAway()
        
        DispatchQueue.main.async {
            self.playerTableView.reloadData()
        }
        
        self.takedown = true
        
    }
    
    func takeDown(target: Int) {
        // create data
        var data: [String: Int] = [:]
        data["player_id"] = self.gameState.player!.id
        data["target_id"] = self.gameState.allPlayers[target].id
        print("taking down sent")
        print(data)
        
        let request = ServerUtils.post(to: "/takeDown", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            print("taken down status code " + String(statusCode))
            
            if (statusCode == 200) {
                self.gameState.unhideAll()
                
                DispatchQueue.main.async {
                    self.playerTableView.reloadData()
                }
                
                self.takedown = false
                // Send player back to beacon for new target
            }
        }.resume()
        // 400 failure:
        //  display TAKEDOWN_FAILURE terminal message, tap to close
    }
    
    // MARK: endInfo
    func gameOver() {
        enableSwipeForLeaderboard()
        
        let request = ServerUtils.get(from: "/endInfo")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            
            if (statusCode == 200) {
                guard let responsedata = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    guard let bodyDict = bodyJson as? [String:[[String: Any]]] else { return }
                    // get scores out
                    self.gameState.assignScores(scoreList: bodyDict["leaderboard"]!)
                    
                } catch {}
                
            }
            
        }.resume()

    }
    
    // MARK: Terminal View
    
    func showTerminal() {
            self.addChild(terminalVC)
            self.view.addSubview(terminalVC.view)
            terminalVC.didMove(toParent: self)
            terminalVC.showAnimate()
            terminalVC.isShowing = true
    }
    
    func hideTerminal() {
        terminalVC.willMove(toParent: nil)
        terminalVC.removeFromParent()
        terminalVC.removeAnimate()
        terminalVC.isShowing = false
    }
    
    // MARK: TableView
    
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
        
        // if cell is greyed out, i.e. 'exchange' or 'takedown' are true
        //  then un-greyout these cells, and disable exchange/takedown
        
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCell = indexPath
        if (exchange) {
            doExchange()
        }
        else if (takedown) {
            takeDown(target: self.selectedCell!.section)
        }
    }
    
    // MARK: countdown
    
    func startGameOverCountdown() {
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
    
    // MARK: leaderboard
    
    func enableSwipeForLeaderboard() {
        // TODO this will be replaced by gameOver
        updatesTimer.invalidate()
        countdownTimer.invalidate()
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(goToLeaderboard))
        swipeUp.direction = .up
        self.playerTableView.isScrollEnabled = false
        self.playerTableView.addGestureRecognizer(swipeUp)
        
    }
    
    @objc func goToLeaderboard(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier:"transitionToLeaderboard", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let leaderboardViewController = segue.destination as? LeaderboardViewController {
            self.gameState.player!.score = self.gameState.points
            self.gameState.allPlayers.append(self.gameState.player!) // add yourself to list of players for leaderboard
            self.gameState.allPlayers.sort(by: { $0.score > $1.score })
            leaderboardViewController.gameState = gameState
        }
    }
    
}
