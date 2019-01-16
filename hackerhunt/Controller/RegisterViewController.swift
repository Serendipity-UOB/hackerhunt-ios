//
//  ViewController.swift
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
    
    @IBAction func goButtonClicked(_ sender: Any) {
        let params : [String: String] = [
            "real_name": realNameTextField.text!,
            "hacker_name": hackerNameTextField.text!,
            "nfc_id": nfcIdTextField.text!
        ]
        
        print("Registering: \(params)");
        
        guard let url = URL(string: "http://serendipity-game-controller.herokuapp.com/registerPlayer") else { return }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("response:\n\t\(response)")
            }

            if let data = data {
                // decode json response
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("body:\n\t\(String(describing: json))")
                } catch {
                    print("JSON error")
                }
            }
        }.resume()

        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realNameTextField.delegate = self
        hackerNameTextField.delegate = self
        nfcIdTextField.delegate = self
    }

    // UITextFieldDelegate methods - we have to control the keyboard behaviour
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
