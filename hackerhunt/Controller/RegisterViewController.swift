//
//  RegisterViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/11/2018.
//  Copyright © 2018 Louis Heath. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    var gameState: GameState!
    
    var inputs : [String: String] = [:]
    
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var hackerNameTextField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realNameTextField.delegate = self
        hackerNameTextField.delegate = self
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        self.inputs = [
            "real_name": realNameTextField.text!,
            "hacker_name": hackerNameTextField.text!
        ]
        
        if (!validInputs()) {
            return
        }
        
        goButton.isEnabled = false
        
        let request : URLRequest = ServerUtils.post(to: "/registerPlayer", with: self.inputs)

        // make async request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode: Int = httpResponse.statusCode
                
                switch statusCode {
                case 200:
                    // need to get player_id from response
                    guard let data = data else { return }
                    do {
                        let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        guard let allPlayers = bodyJson as? [String:Any] else { return }
                        let playerId = String(describing: allPlayers["player_id"]!)
                        self.inputs["player_id"] = playerId
                        self.progressToJoinGame()
                    } catch {}
                    return
                case 400:
                    self.reattemptInput(with: "Hacker name already in use")
                    return
                default:
                    self.reattemptInput(with: "Server response \(statusCode). Report to base")
                    return
                }
            }
        }.resume()
        
        return
    }
    
    func validInputs() -> Bool {
        if (self.inputs["real_name"]!.count == 0) {
            reattemptInput(with: "Missing Real Name")
            return false
        }
        if (self.inputs["hacker_name"]!.count == 0) {
            reattemptInput(with: "Missing Hacker Name")
            return false
        }
        return true
    }
    
    func reattemptInput(with message: String) {
        // make UI changes on main thread
        DispatchQueue.main.async {
            self.goButton.isEnabled = true
            self.goButton.setTitle("go();", for: .normal)
            self.errorMessage.text = message
        }
    }
    
    /* Transition methods */
    
    func progressToJoinGame() {
        let realName: String = self.inputs["real_name"]!
        let hackerName: String = self.inputs["hacker_name"]!
        let id: Int = Int(self.inputs["player_id"]!)!
        gameState.player = Player(realName: realName, hackerName: hackerName, id: id)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier:"transitionToJoinGame", sender:self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let joinGameViewController = segue.destination as? JoinGameViewController {
            joinGameViewController.gameState = gameState
        }
    }

    /* Override keyboard behaviour */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
