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
        // if a selected row already exists, and it is also the row newly selected
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
            indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            unhideAllCells()
            return nil
        } else {
            let shownCell = playerTableView.cellForRow(at: indexPath) as! PlayerTableCell
            if shownCell.isHidden() {
                return nil
            }
            hideAllCells()
            shownCell.unhide()
        }
        return indexPath
    }
    
    func unhideAllCells() {
        greyOutView.alpha = 0
        for i in 0..<gameState.allPlayers.count {
            let cell = playerTableView.cellForRow(at: IndexPath(row: 0, section: i)) as! PlayerTableCell
            cell.unhide()
        }
    }
    
    func hideAllCells() {
        greyOutView.alpha = 0.8
        for i in 0..<gameState!.allPlayers.count {
            let cell = playerTableView.cellForRow(at: IndexPath(row: 0, section: i)) as! PlayerTableCell
            cell.hide()
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
