//
//  JoinGameViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class JoinGameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func joinGameClicked(_ sender: Any) {
        self.performSegue(withIdentifier:"transitionToMainGame", sender:self);
    }
}
