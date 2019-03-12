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
    var missionTimer = Timer()
    
    var exchange: Bool = false
    var takedown: Bool = false
    var exchangeMessage: Bool = false
    var onMission: Bool = false
    
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
            self.terminalVC.setHomeBeacon(homeBeaconName: self.gameState.homeBeacon!)
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
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let body = bodyJson as? [String:Any] else { return }
                    guard let home = body["home"] as? Bool else {
                        print("home missing")
                        return
                    }
                    
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
        let data: [String:Any] = [
            "player_id": self.gameState.player!.id as Int
        ]
        
        let request = ServerUtils.post(to: "/startInfo", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode

            if (statusCode == 200) {
                
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let bodyDict = bodyJson as? [String:Any] else {
                        print("allPlayers dict parse failed")
                        return
                    }
                    
                    guard let allPlayersString = bodyDict["all_players"] as? String else {
                        print("all_players missing")
                        return
                    }
                    
                    let allPlayersJson = try JSONSerialization.jsonObject(with: allPlayersString.data(using: .utf8)!, options: [])
                    
                    guard let allPlayersList = allPlayersJson as? [[String:Any]] else {
                        print("all_players cast to list of dicts failed")
                        return
                    }
                    
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
                        guard let takenDown: Int = bodyDict["exposed_by"] as? Int else {
                            print("exposed_by missing")
                            return
                        }
                        guard let nearbyPlayers: [Int] = bodyDict["nearby_players"] as? [Int] else {
                            print("nearbyPlayers missing")
                            return
                        }
                        guard let points: Int = bodyDict["reputation"] as? Int else {
                            print("reputation missing")
                            return
                        }
                        guard let requestNewTarget: Int = bodyDict["req_new_target"] as? Int else {
                            print("req_new_target missing")
                            return
                        }
                        guard let position: Int = bodyDict["position"] as? Int else {
                            print("position missing")
                            return
                        }
                        guard let gameOver: Int = bodyDict["game_over"] as? Int else {
                            print("game_over missing")
                            return
                        }
                        guard let missionDescription: String = bodyDict["mission_description"] as? String else {
                            print("mission_description missing")
                            return
                        }
                        self.handleTakenDown(takenDown)
                        self.handleNearbyPlayers(nearbyPlayers)
                        self.setCurrentPoints(points)
                        self.handleRequestNewTarget(requestNewTarget)
                        self.handlePosition(position)
                        self.handleMission(missionDescription)
                        self.updatesTimer.invalidate()
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
    
    func handleMission(_ missionDescription: String) {
        if (missionDescription != "" && !onMission) {
            DispatchQueue.main.async {
                self.terminalVC.setMessage(newMission: missionDescription)
                self.showTerminal()
                self.startMissionUpdates()
            }
            self.onMission = true
        }
    }
    
    func handleTakenDown(_ takenDown: Int) {
        if (takenDown != 0) {
            self.gameState.deleteHalfOfIntel()
            DispatchQueue.main.async {
                self.terminalVC.setMessage(takenDown: true, exposedBy: self.gameState.getPlayerById(takenDown)!.realName)
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
            self.pointsValue.text = String(self.gameState.points) + " rep /"
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
            self.positionValue.text = "#" + String(self.gameState.position) + " / "
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
                    guard let newTarget = bodyDict["target_player_id"] as? Int else {
                        print("target_player_id missing")
                        return
                    }
                    
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

}
