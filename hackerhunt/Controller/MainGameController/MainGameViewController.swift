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
    var interceptTimer = Timer()
    var exchangeRequestTimer = Timer()

    var onMission: Bool = false
    var atUnitedNations: Bool = false
    var exchangeResponse: Int = 0
    var tableCardSelected: Bool = false

    // header
    @IBOutlet weak var pointsValue: UILabel!
    @IBOutlet weak var positionValue: UILabel!
    @IBOutlet weak var countdownValue: UILabel!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var targetName: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    
    // player table
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var greyOutViewTap: UITapGestureRecognizer!
    @IBOutlet weak var tableViewTap: UITapGestureRecognizer!
    @IBOutlet weak var greyOutView: UIView!
    @IBOutlet weak var interactionButtons: UIView!
    @IBOutlet weak var tapToCloseLabel: UILabel!
    
    // requested exchange
    @IBOutlet weak var exchangeRequestedBackground: UIImageView!
    @IBOutlet weak var exchangeRequestedAcceptButton: UIButton!
    @IBOutlet weak var exchangeRequestedRejectButton: UIButton!
    @IBOutlet weak var exchangeRequestedText: UILabel!
    
    
    var alertVC : AlertViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
    
    var logVC : LogViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "logViewController") as! LogViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStartInfo()
        
        hideExchangeRequested()
        setCurrentPoints(0)
        setupPlayerTable()
        playerName.text = gameState.player!.realName
        alertVC.setHomeBeacon(homeBeaconName: self.gameState.homeBeacon!)
    }
    
    // MARK: startInfo
    
    func startCheckingForHomeBeacon(withCallback callback: @escaping () -> Void) {
        homeBeaconTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MainGameViewController.checkForHomeBeacon), userInfo: callback, repeats: true)
        homeBeaconTimer.fire()
        homeBeaconTimer.tolerance = 0.4
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
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "home beacon")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
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
                            self.alertVC.setTapToClose(true)
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
        print("prepared data")
        let request = ServerUtils.post(to: "/startInfo", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "start info")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {

                print("getStartInfo failed, trying again in 2 seconds")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.getStartInfo()
                }
                return
            }
            
            let statusCode: Int = httpResponse.statusCode

            if (statusCode == 200) {
                
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let bodyDict = bodyJson as? [String:Any] else {
                        print("allPlayers dict parse failed")
                        return
                    }
                    
                    guard let allPlayersList = bodyDict["all_players"] as? [[String:Any]] else {
                        print("all_players cast to list of dicts failed")
                        return
                    }
                    self.gameState.initialisePlayerList(allPlayers: allPlayersList)
                    
                    guard let firstTargetId = bodyDict["first_target_id"] as? Int else {
                        print("first_target_id cast to int failed")
                        return
                    }
                    let success = self.gameState.setFirstTarget(firstTargetId)
                    if success {
                        self.targetName.text = self.gameState.currentTarget?.codeName
                    } else {
                        print("ERROR target player not found in player list")
                    }
                    
                    
                    guard let endTime: String = bodyDict["end_time"] as? String else {
                        print("end_time missing")
                        return
                    }
                    self.gameState.endTime = timeStringToInt(time: endTime)
                    
                    DispatchQueue.main.async {
                        self.startGameOverCountdown()
                        self.startPollingForUpdates()
                    }
                    self.reloadTable()
                } catch {}
            } else {
                print("/startInfo failed")
            }
        }.resume()
    }
    
    func startPollingForUpdates() {
        updatesTimer.invalidate()
        updatesTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(MainGameViewController.pollForUpdates), userInfo: nil, repeats: true)
        updatesTimer.fire()
        updatesTimer.tolerance = 0.5
    }
    
    @objc func pollForUpdates() {
//        print("Nearest major: \(gameState.getNearestBeaconMajor())\n")
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

                if (error != nil) {
                    DispatchQueue.main.async {
                        self.logVC.setMessage(networkError: "player update")
                        self.showLog()
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                let statusCode: Int = httpResponse.statusCode
                if (statusCode == 200) {
                    
                    guard let data = data else { return }
                    
                    do {
                        let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        guard let bodyDict = bodyJson as? [String: Any] else { return }
                        
                        guard let location: Int = bodyDict["location"] as? Int else {
                            print("location zone missing")
                            return
                        }
                        guard let takenDown: Int = bodyDict["exposed_by"] as? Int else {
                            print("exposed_by missing")
                            return
                        }
                        guard let nearbyPlayers: [[String:Int]] = bodyDict["nearby_players"] as? [[String:Int]] else {
                            print("nearbyPlayers missing")
                            return
                        }
                        guard let farPlayers: [[String:Int]] = bodyDict["far_players"] as? [[String:Int]] else {
                            print("farPlayers missing")
                            return
                        }
                        guard let points: Int = bodyDict["reputation"] as? Int else {
                            print("reputation missing")
                            return
                        }
//                        guard let requestNewTarget: Int = bodyDict["req_new_target"] as? Int else {
//                            print("req_new_target missing")
//                            return
//                        }
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
                        guard let exchangeRequested: Int = bodyDict["exchange_pending"] as? Int else {
                            print("exchange_pending missing")
                            return
                        }
                        self.handleLocation(location)
                        self.handleExchangeRequested(exchangeRequested)
                        self.handleTakenDown(takenDown)
                        self.handlePlayers(nearbyPlayers, farPlayers)
                        self.setCurrentPoints(points)
                        //self.handleRequestNewTarget(requestNewTarget)
                        self.handlePosition(position)
                        self.handleMission(missionDescription, bodyDict)
                        if (ServerUtils.testing) {
                            self.updatesTimer.invalidate()
                        }
                        if (gameOver == 1) {
                            self.gameOver()
                        }
                        
                        self.reloadTable() // this calls main thread
                    } catch {}
                } else {
                    print("/playerUpdate failed with status code \(statusCode)")
                }
            }.resume()
        }
    }
    
    func handleLocation(_ location: Int) {
        DispatchQueue.main.async {
            switch location {
            case 0:
                self.locationIcon.image = UIImage(named: "unitedNations")
            case 1:
                self.locationIcon.image = UIImage(named: "italyFlag")
            case 2:
                self.locationIcon.image = UIImage(named: "swedenFlag")
            case 3:
                self.locationIcon.image = UIImage(named: "switzerlandFlag")
            case 4:
                self.locationIcon.image = UIImage(named: "czechRepublicFlag")
            default:
                print("zone \(location) not recognised")
            }
            if location == 0 {
                self.atUnitedNations = true
            } else {
                self.atUnitedNations = false
            }
        }
    }
    
    func handleExchangeRequested(_ exchangeRequested: Int) {
        if (exchangeRequested != 0) {
            DispatchQueue.main.async {
                let sender = self.gameState.getPlayerById(exchangeRequested)!.realName
                self.exchangeRequestedText.text = "\(sender) wants to exchange evidence with you."
                self.showExchangeRequested()
                self.exchangeResponse(exchangeRequested)
            }
            self.exchangeResponse = 0
        }
    }
    
    func handleMission(_ missionDescription: String, _ bodyDict: [String: Any]) {
        if (missionDescription != "" && !onMission) {
            self.onMission = true
            if (tableCardSelected) { // deselect selected player if a mission is popping up
                tableCardSelected = false
                ungreyOutAllCells()
            }
            guard let missionType: Int = bodyDict["mission_type"] as? Int else {
                print("mission_type missing")
                return
            }
            if missionType == 0 {        // start
                self.alertVC.tapToClose = false
            } else if missionType == 1 { // evidence
                self.alertVC.tapToClose = false
            } else if missionType == 2 { // hint
                self.alertVC.tapToClose = true
                self.onMission = false
            }
            DispatchQueue.main.async {
                self.alertVC.setMessage(newMission: missionDescription, hint: missionType == 2)
                self.showAlert()
                if missionType != 2 {
                    self.startMissionUpdates()
                }
            }
        }
    }
    
    func handleTakenDown(_ takenDown: Int) {
        if (takenDown != 0) {
            self.gameState.deleteHalfOfIntel()
            DispatchQueue.main.async {
                self.alertVC.setMessage(takenDown: true, exposedBy: self.gameState.getPlayerById(takenDown)!.realName)
                self.showAlert()
                self.startCheckingForHomeBeacon(withCallback: { return })
            }
        }
    }
    
    func handlePlayers(_ nearbyPlayers: [[String:Int]], _ farPlayers: [[String:Int]]) {
        for p in self.gameState.allPlayers {
            for dict in nearbyPlayers {
                guard let id: Int = dict["id"] else {
                    print("no player id for a player in nearbyPlayers")
                    return
                }
                if (p.id == id) {
                    guard let location: Int = dict["location"] else {
                        print("location missing for player \(id)")
                        return
                    }
                    p.zone = location
                    p.nearby = true
                    break
                }
            }
            for dict in farPlayers {
                guard let id: Int = dict["id"] else {
                    print("no player id for a player in nearbyPlayers")
                    return
                }
                if (p.id == id) {
                    guard let location: Int = dict["location"] else {
                        print("location missing for player \(id)")
                        return
                    }
                    p.zone = location
                    p.nearby = false
                    break
                }
            }
        }
        if (!tableCardSelected) {
            self.gameState.prioritiseNearbyPlayers()
        }
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
                self.alertVC.setMessage(requestNewTarget: true)
                self.showAlert()
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
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "new target")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
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
                        self.alertVC.setMessage(newTarget: self.gameState.currentTarget?.codeName ?? "error")
                        self.showAlert()
                    }
                    self.reloadTable()
                    
                } catch {}
            }
            else {
                print("couldn't retrieve new target")
            }
        }.resume()
    }
    
    
    @IBAction func exchangeAcceptPressed(_ sender: Any) {
        print("accepted pressed")
        self.exchangeResponse = 1
    }
    
    @IBAction func exchangeRejectPressed(_ sender: Any) {
        print("reject pressed")
        self.exchangeResponse = 2
    }
    
}
