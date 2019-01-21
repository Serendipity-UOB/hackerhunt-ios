//
//  RegisterViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/11/2018.
//  Copyright © 2018 Louis Heath. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var hackerNameTextField: UITextField!
    @IBOutlet weak var nfcIdTextField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realNameTextField.delegate = self
        hackerNameTextField.delegate = self
        nfcIdTextField.delegate = self
    }
    
    @IBAction func goButtonClicked(_ sender: Any) {
        let userInfo : [String: String] = [
            "real_name": realNameTextField.text!,
            "hacker_name": hackerNameTextField.text!,
            "nfc_id": nfcIdTextField.text!
        ]
        
        print("Registering: \(userInfo)");
        
        goButton.isEnabled = false
        
        guard let url = URL(string: "http://serendipity-game-controller.herokuapp.com/registerPlayer") else { return }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // make async request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let bodyDict = bodyJson as? [String: Any] {
                        if let statusCode = bodyDict["status"] as? Int {
                            
                            switch statusCode {
                            case 200:
                                self.progressToJoinGame()
                            case 400:
                                self.reattemptInput(withMessage: "Hacker name already in use")
                            case 404:
                                print("Endpoint not implemented")
                                self.progressToJoinGame()
                            default:
                                self.reattemptInput(withMessage: "Server response \(statusCode). Report to base")
                            }
                        }
                    } else {
                        self.reattemptInput(withMessage: "JSON parse error. Report to base")
                    }
                } catch {
                    self.reattemptInput(withMessage: "Error. Report to base")
                }
            } else {
                self.reattemptInput(withMessage: "No server response. Report to base")
            }
        }.resume()
        

        return
    }
    
    func reattemptInput(withMessage message: String) {
        // make UI changes on main thread
        DispatchQueue.main.async {
            self.goButton.isEnabled = true
            self.goButton.setTitle("go();", for: .normal)
            self.errorMessage.text = message
        }
    }
    
    func progressToJoinGame() {
        self.performSegue(withIdentifier:"transitionToJoinGame", sender:self);
    }

    // UITextFieldDelegate method to control the keyboard behaviour
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
