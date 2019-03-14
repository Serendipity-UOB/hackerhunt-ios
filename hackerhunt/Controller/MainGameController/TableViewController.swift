//
//  TableViewController.swift
//  hackerhunt
//
//  Created by Thomas Walker on 12/03/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation
import UIKit

extension MainGameViewController {
    
    func setupPlayerTable() {
        playerTableView.register(PlayerTableCell.self, forCellReuseIdentifier: "playerTableCell")
        playerTableView.rowHeight = 65
        playerTableView.delegate = self
        playerTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTableView.dequeueReusableCell(withIdentifier: "playerTableCell") as! PlayerTableCell
        cell.player = gameState!.allPlayers[indexPath.section]
        cell.isTarget = (gameState!.currentTarget?.codeName == cell.player.codeName)
        cell.exchangeBtn.addTarget(self, action: #selector(exchangeButtonAction), for: .touchUpInside)
        cell.interceptBtn.addTarget(self, action: #selector(interceptButtonAction), for: .touchUpInside)
        cell.exposeBtn.addTarget(self, action: #selector(exposeButtonAction), for: .touchUpInside)
        cell.initialiseButtons(interactionButtons)
        cell.cellY = playerTableView.frame.origin.y + cell.frame.origin.y // set global Y pos for moving the buttons around
        cell.layoutSubviews()
        return cell
    }
    
    @objc func exchangeButtonAction(sender: UIButton!) {
        print("exchange button tapped")
    }
    
    @objc func interceptButtonAction(sender: UIButton!) {
        print("intercep button tapped")
    }
    @objc func exposeButtonAction(sender: UIButton!) {
        print("expose button tapped")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameState!.allPlayers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellToShow = playerTableView.cellForRow(at: indexPath) as! PlayerTableCell
        greyOutAllCells()
        cellToShow.ungreyOut()
        cellToShow.showButtons()
        return indexPath
    }
    
    @IBAction func doTheThing() {
        ungreyOutAllCells()
    }
    
    func ungreyOutAllCells() {
        greyOutView.alpha = 0
        greyOutViewTap.isEnabled = false
        tableViewTap.isEnabled = false
        for i in 0..<gameState.allPlayers.count {
            let cell = playerTableView.cellForRow(at: IndexPath(row: 0, section: i)) as! PlayerTableCell
            cell.ungreyOut()
            cell.hideButtons()
        }
    }
    
    func greyOutAllCells() {
        greyOutView.alpha = 0.8
        greyOutViewTap.isEnabled = true
        tableViewTap.isEnabled = true
        for i in 0..<gameState!.allPlayers.count {
            let cell = playerTableView.cellForRow(at: IndexPath(row: 0, section: i)) as! PlayerTableCell
            cell.greyOut()
            cell.hideButtons()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (exchange) {
            exchange(withPlayerAtIndex: indexPath.section)
        } else if (takedown) {
            takeDown(target: indexPath.section)
        }
    }
    
}
