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
        if (greyout && !cell.player.selected) {
            cell.greyOut()
            cell.hideButtons()
        }
        else if (greyout && cell.player.selected) {
            cell.ungreyOut()
            cell.showButtons()
            view.bringSubviewToFront(cell)
        }
        else {
            cell.ungreyOut()
            cell.hideButtons()
        }
        return cell
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
        let player = gameState!.allPlayers[indexPath.section]
        if (player.nearby) {
//            let cellToShow = playerTableView.cellForRow(at: indexPath) as! PlayerTableCell
            player.selected = true
            greyOutAllCells()
//            cellToShow.ungreyOut()
//            cellToShow.showButtons()
        }
        else {
            self.logVC.setMessage(farAwayPlayerSelected: player.realName)
            self.showLog()
        }
        return indexPath
    }
    
    @IBAction func doTheThing() {
        ungreyOutAllCells()
    }
    
    func ungreyOutAllCells() {
        for p in self.gameState.allPlayers {
            p.selected = false
        }
        DispatchQueue.main.async {
            self.greyout = false
            self.playerTableView.reloadData()
            self.playerTableView.isScrollEnabled = true
            self.tapToCloseLabel.alpha = 0.0
            self.greyOutView.alpha = 0
            self.greyOutViewTap.isEnabled = false
            self.tableViewTap.isEnabled = false
        }

//        for cell in playerTableView!.visibleCells {
//            let c = cell as! PlayerTableCell
//            c.ungreyOut()
//            c.hideButtons()
//        }
    }
    
    func greyOutAllCells() {
        DispatchQueue.main.async {
            self.greyout = true
            self.playerTableView.reloadData()
            self.playerTableView.isScrollEnabled = false
            self.greyOutView.alpha = 0.8
            self.greyOutViewTap.isEnabled = true
            self.tableViewTap.isEnabled = true
            self.tapToCloseLabel.alpha = 1.0
        }

//        for cell in playerTableView!.visibleCells {
//            let c = cell as! PlayerTableCell
//            c.greyOut()
//            c.hideButtons()
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (exchange) {
//            exchange(withPlayerAtIndex: indexPath.section)
//        } else if (takedown) {
//            takeDown(target: indexPath.section)
//        }
    }
    
}
