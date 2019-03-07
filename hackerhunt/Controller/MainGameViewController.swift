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
    
    var exchange: Bool = false
    var takedown: Bool = false
    var exchangeMessage: Bool = false
    
    @IBOutlet weak var pointsValue: UILabel!
    @IBOutlet weak var positionValue: UILabel!
    @IBOutlet weak var countdownValue: UILabel!
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var targetName: UILabel!
    
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var takeDownBtn: UIButton!
    @IBOutlet weak var exchangeBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var takeDownBtnWidth: NSLayoutConstraint!
    
    var terminalVC : TerminalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminalViewController") as! TerminalViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCurrentPoints(0)
        startGameOverCountdown()
        setupPlayerTable()
        playerName.text = gameState.player!.realName
        
        letTheChallengeBegin()
    }
    
    // MARK: startInfo
    
    func letTheChallengeBegin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.terminalVC.setHomeBeacon(homeBeaconName: self.gameState.homeBeacon!.name)
            self.terminalVC.setMessage(gameStart: true, tapToClose: ServerUtils.testing)
            self.showTerminal()
            self.startCheckingForHomeBeacon(withCallback: self.getStartInfo)
        })
    }
    
    func startCheckingForHomeBeacon(withCallback callback: @escaping () -> Void) {
        homeBeaconTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MainGameViewController.checkForHomeBeacon), userInfo: callback, repeats: true)
        homeBeaconTimer.fire()
    }
    
    @objc func checkForHomeBeacon() {
        let data: [String:Any] = [
            "player_id": self.gameState.player!.id as Int,
            "beacons": self.gameState.createBeaconList()
        ]
        
        let request = ServerUtils.post(to: "/atHomeBeacon", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (!self.homeBeaconTimer.isValid) {
                return;
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let body = bodyJson as? [String:Any] else { return }
                    guard let home = body["home"] as? Bool else { return }
                    
                    if (home) {
                        guard let callback = self.homeBeaconTimer.userInfo as! (() -> Void)? else {
                            print("no callback to use at home beacon")
                            return
                        }
                        callback()
                        
                        self.homeBeaconTimer.invalidate()
                        DispatchQueue.main.async {
                            self.terminalVC.setTapToClose(true)
                        }
                    }
                } catch {}
            }
        }.resume()
    }
    
    func getStartInfo() -> Void {
        print("Getting start info\n")
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
        print("Nearest major: \(gameState.getNearestBeaconMajor())\n")
        if (self.gameState.isGameOver()) {
            print("game over\n")
            gameOver()
            
        } else {
            let data: [String:Any] = [
                "player_id": self.gameState.player!.id as Int,
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
                        
                        // TODO: tidy this away
                        guard let takenDown: Int = bodyDict["taken_down"] as? Int else { return }
                        guard let nearbyPlayers: [Int] = bodyDict["nearby_players"] as? [Int] else { return }
                        guard let points: Int = bodyDict["points"] as? Int else { return }
                        guard let requestNewTarget: Int = bodyDict["req_new_target"] as? Int else { return }
                        guard let position: Int = bodyDict["position"] as? Int else { return }
                        guard let gameOver: Int = bodyDict["game_over"] as? Int else { return }
                        self.handleTakenDown(takenDown)
                        self.handleNearbyPlayers(nearbyPlayers)
                        self.setCurrentPoints(points)
                        self.handleRequestNewTarget(requestNewTarget)
                        self.handlePosition(position)
                        
                        if (gameOver == 1) {
                            self.gameOver()
                        }
                        
                        DispatchQueue.main.async {
                            self.playerTableView.reloadData()
                        }
                    } catch {}
                } else {
                    print("/playerUpdate failed")
                }
            }.resume()
        }
    }
    
    func handleTakenDown(_ takenDown: Int) {
        if (takenDown == 1) {
            self.gameState.deleteHalfOfIntel()
            DispatchQueue.main.async {
                self.terminalVC.setMessage(takenDown: true)
                self.showTerminal()
                self.startCheckingForHomeBeacon(withCallback: { return })
            }
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
                        
                        self.targetName.text = self.gameState.currentTarget?.codeName
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
        self.exchange = !self.exchange
        
        if (self.exchange) {
            self.gameState.hideFarAway()
            expandExchangeButton()
        } else {
            self.gameState.unhideAll()
            contractExchangeButton()
        }
        
        DispatchQueue.main.async {
            self.playerTableView.reloadData()
        }
    }
    
    func exchange(withPlayerAtIndex tableIndex: Int) {
        let interacteeId = self.gameState.allPlayers[tableIndex].id
        
        if (gameState.playerIsNearby(interacteeId)) {
            let validContacts: [[String: Int]] = self.gameState.allPlayers
                .filter({ $0.intel > 0.0 })
                .map({ return ["contact_id": $0.id] })
            
            let data: [String:Any] = [
                "interacter_id": self.gameState.player!.id,
                "interactee_id": interacteeId,
                "contact_ids": validContacts
            ]
            
            // send request
            exchangeTimer.invalidate()
            exchangeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.exchangeRequest), userInfo: data, repeats: true)
            exchangeTimer.fire()
        } else {
            DispatchQueue.main.async {
                self.terminalVC.setMessage(message: "EXCHANGE_FAIL\n\nPlayer not nearby", tapToClose: true)
            }
        }
    }
    
    @objc func exchangeRequest() {
        let data: [String:Any] = exchangeTimer.userInfo as! [String:Any]
        let interactee: Int = data["interactee_id"] as! Int
        let request = ServerUtils.post(to: "/exchange", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            print("exchange code " + String(statusCode))
            
            switch statusCode {
            case 200:
                guard let responseData = data else { return }
                do {
                    self.exchangeTimer.invalidate()
                    
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let secondaryId = bodyDict["secondary_id"] as? Int else { return }
                    
                    self.gameState.incrementIntelFor(playerOne: interactee, playerTwo: secondaryId)
                    self.gameState.unhideAll()
                    self.exchange = false
                    
                    DispatchQueue.main.async {
                        self.contractExchangeButton()
                        self.playerTableView.reloadData()
                        self.terminalVC.setMessage(message: "EXCHANGE_SUCCESS\n\nIntel gained", tapToClose: true)
                        if (self.exchangeMessage) { // don't do showTerminal if it's already up
                            print("updating terminal text")
                            self.terminalVC.viewWillAppear(false)
                        } else {
                            print("showing terminal")
                            self.showTerminal()
                        }
                        self.exchangeMessage = false
                    }
                } catch {}
            case 201, 202:
                if (!self.exchangeMessage) { // don't do show terminal if it's already up
                    DispatchQueue.main.async {
                        print("showing terminal")
                        self.exchangeMessage = true
                        self.terminalVC.setMessage(message: "EXCHANGE_REQUESTED\n\nWaiting for handshake", tapToClose: false)
                        self.showTerminal()
                    }
                }
            case 400:
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    print("exchange failed")
                    self.exchange = false
                    self.contractExchangeButton()
                    
                    self.terminalVC.setMessage(message: "EXCHANGE_FAIL\n\nHandshake incomplete", tapToClose: true)
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
        self.takedown = !self.takedown
        
        if (takedown) {
            self.gameState.hideFarAway()
            expandTakeDownButton()
        } else {
            self.gameState.unhideAll()
            contractTakeDownButton()
        }
        
        DispatchQueue.main.async {
            self.playerTableView.reloadData()
        }
    }
    
    func takeDown(target: Int) {
        // attempt to takedown far away person
        if (self.gameState.allPlayers[target].nearby == false) {
            DispatchQueue.main.async {
                self.gameState.unhideAll()
                self.playerTableView.reloadData()
                self.terminalVC.setMessage(message: "TAKEDOWN_FAILURE\n\nGet closer to your target", tapToClose: true)
                self.showTerminal()
                self.takedown = false
                self.contractTakeDownButton()
            }
            return
        }
        // attempt to takedown with insufficient intel
        if (self.gameState.allPlayers[target].intel < 1.0) {
            DispatchQueue.main.async {
                self.gameState.unhideAll()
                self.playerTableView.reloadData()
                self.terminalVC.setMessage(message: "TAKEDOWN_FAILURE\n\nInsufficient intel", tapToClose: true)
                self.showTerminal()
                self.takedown = false
                self.contractTakeDownButton()
            }
            return
        }
        // attempt to take down wrong person
        if (self.gameState.allPlayers[target].codeName != self.gameState.currentTarget!.codeName) {
            DispatchQueue.main.async {
                self.gameState.unhideAll()
                self.playerTableView.reloadData()
                self.terminalVC.setMessage(message: "TAKEDOWN_FAILURE\n\nNot your target", tapToClose: true)
                self.showTerminal()
                self.takedown = false
                self.contractTakeDownButton()
            }
            return
        }

        DispatchQueue.main.async {
            self.terminalVC.setMessage(message: "TAKEDOWN_INIT\n\nExecuting attack...", tapToClose: true)
            self.showTerminal()
        }
        
        // create data
        let data: [String: Int] = [
            "player_id": self.gameState.player!.id,
            "target_id": self.gameState.allPlayers[target].id
        ]
        print("taking down with data:\n\t\(data)\n")
        
        let request = ServerUtils.post(to: "/takeDown", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            print("taken down status code " + String(statusCode))
            
            if (statusCode == 200) {
                DispatchQueue.main.async {
                    self.terminalVC.setMessage(message: "TAKEDOWN_SUCCESS\n\nReturn to Beacon \"\(self.terminalVC.homeBeacon)\" for a new target", tapToClose: false)
                    self.terminalVC.viewWillAppear(false)
                    self.playerTableView.reloadData()
                    self.startCheckingForHomeBeacon(withCallback: self.requestNewTarget)
                    
                    self.gameState.unhideAll()
                    self.takedown = false
                    self.contractTakeDownButton()
                }
            } else {
                print("take down failed\n\(String(describing: response))")
            }
        }.resume()
    }
    
    // MARK: endInfo
    
    func gameOver() {
        updatesTimer.invalidate()
        countdownTimer.invalidate()
        // TODO check if we are currently interacting and clean up
        exchangeTimer.invalidate()
        homeBeaconTimer.invalidate()
        
        let request = ServerUtils.get(from: "/endInfo")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String:[[String: Any]]] else { return }
                    
                    self.gameState.assignScores(scoreList: bodyDict["leaderboard"]!)
                    self.goToLeaderboard()
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
        if (exchange) {
            exchange(withPlayerAtIndex: indexPath.section)
        } else if (takedown) {
            takeDown(target: indexPath.section)
        }
    }
    
    // MARK: countdown
    
    func startGameOverCountdown() {
        self.countdownTimer.invalidate()
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.updateGameTimer), userInfo: nil, repeats: true)
        self.countdownTimer.fire()
    }
    
    @objc func updateGameTimer() {
        let timeRemaining = self.gameState.endTime! - Int(now())
        if (timeRemaining >= 0) {
            countdownValue.text = prettyTimeFrom(seconds: timeRemaining)
        }
    }
    
    // MARK: leaderboard
    
    func goToLeaderboard() {
        self.performSegue(withIdentifier:"transitionToLeaderboard", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let leaderboardViewController = segue.destination as? LeaderboardViewController {
            self.gameState.prepareLeaderboard()
            leaderboardViewController.gameState = gameState
        }
    }
    
    // MARK: animations
    
    func expandExchangeButton() {
        takeDownBtn.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            // these constants are the offset - i.e. relative to the  
            self.exchangeBtnWidth.constant = self.view.frame.width / 2 - 20
            self.takeDownBtnWidth.constant = -1 * self.view.frame.width / 2
            self.exchangeBtn.setTitle("cancel(EXCHANGE);", for: .normal)
        })
    }
    
    func contractExchangeButton() {
        takeDownBtn.isEnabled = true
        self.exchangeBtn.setTitle("exchange();", for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.exchangeBtnWidth.constant = -15
            self.takeDownBtnWidth.constant = -15
        })
    }
    
    func expandTakeDownButton() {
        exchangeBtn.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.takeDownBtnWidth.constant = self.view.frame.width / 2 - 20
            self.exchangeBtn.alpha = 0
            self.takeDownBtn.setTitle("cancel(TAKEDOWN);", for: .normal)
        })
    }
    
    func contractTakeDownButton() {
        exchangeBtn.isEnabled = true
        self.takeDownBtn.setTitle("take_down();", for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.takeDownBtnWidth.constant = -15
            self.exchangeBtn.alpha = 1
        })
    }
}
