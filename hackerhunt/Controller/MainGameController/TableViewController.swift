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
    
    func reloadTable() {
        let contentOffset = playerTableView.contentOffset
        DispatchQueue.main.async {
            self.playerTableView.reloadData()
            self.playerTableView.layoutIfNeeded()
            self.playerTableView.setContentOffset(contentOffset, animated: false)
        }
    }
    
    func reloadTableSync() {
        let contentOffset = playerTableView.contentOffset
        self.playerTableView.reloadData()
        self.playerTableView.layoutIfNeeded()
        self.playerTableView.setContentOffset(contentOffset, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTableView.dequeueReusableCell(withIdentifier: "playerTableCell") as! PlayerTableCell
        while (gameState.sorting) {
            print("waiting for sort")
        }
        cell.player = gameState!.allPlayers[indexPath.section]
        cell.isTarget = (gameState!.currentTarget?.codeName == cell.player.codeName)
        cell.exchangeBtn.addTarget(self, action: #selector(exchangeButtonAction), for: .touchUpInside)
        cell.interceptBtn.addTarget(self, action: #selector(interceptButtonAction), for: .touchUpInside)
        cell.exposeBtn.addTarget(self, action: #selector(exposeButtonAction), for: .touchUpInside)
        cell.initialiseButtons(interactionButtons)
        if (cell.player.exchangeDisabled || atUnitedNations) {
            cell.disableExchange()
        } else {
            cell.enableExchange()
        }
        if (cell.player.interceptDisabled || atUnitedNations) {
            cell.disableIntercept()
        } else {
            cell.enableIntercept()
        }
        if (atUnitedNations) {
            cell.disableExpose()
        } else {
            cell.enableExpose()
        }
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
        return CGFloat(5.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        while (gameState.sorting) {
            print("waiting for sort")
        }
        let player = gameState!.allPlayers[indexPath.section]
        if (player.nearby) {
            let cellToShow = self.playerTableView.cellForRow(at: indexPath) as! PlayerTableCell
            cellToShow.cellY = playerTableView.convert(playerTableView.rectForRow(at: indexPath), to: playerTableView.superview).origin.y
            greyOutAllCellsBut(cellToShow)
        }
        else {
            self.logVC.setMessage(farAwayPlayerSelected: player.realName)
            self.showLog()
        }
        return indexPath
    }
    
    @IBAction func greyOutViewTapped() {
        ungreyOutAllCells()
    }
    
    func ungreyOutAllCells() {
        tableCardSelected = false
        playerTableView.isScrollEnabled = true
        tapToCloseLabel.alpha = 0.0
        greyOutView.alpha = 0
        greyOutViewTap.isEnabled = false
        tableViewTap.isEnabled = false
        for p in self.gameState.allPlayers {
            p.card.isGreyedOut = false
        }
        for c in self.playerTableView.visibleCells {
            let cell = c as! PlayerTableCell
            cell.hideButtons() // not every cell needs to call this
        }
        reloadTableSync()
    }
    
    func greyOutAllCellsBut(_ cellToShow: PlayerTableCell) {
        tableCardSelected = true
        playerTableView.isScrollEnabled = false
        tapToCloseLabel.alpha = 1.0
        greyOutView.alpha = 0.8
        greyOutViewTap.isEnabled = true
        tableViewTap.isEnabled = true
        for p in self.gameState.allPlayers {
            p.card.isGreyedOut = p.id != cellToShow.player.id
        }
        cellToShow.showButtons()
        reloadTableSync()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
