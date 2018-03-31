//
//  MineMap.swift
//  MineSweeper
//
//  Created by 风筝 on 2018/3/31.
//  Copyright © 2018年 Doge Studio. All rights reserved.
//

import UIKit

class MineMap: NSObject {
    
    @objc dynamic var rows = 30
    @objc dynamic var columns = 16
    @objc dynamic var mines = 99
    @objc dynamic var mineBlockJson: String = ""
    
    var mineGrids: [[Int8]] = []
    
    func generateMine(_ firstRow: Int, _ firstColumn: Int) {
        self.mineGrids = []
        for _ in 0 ..< self.rows {
            var mineRow: [Int8] = []
            for _ in 0 ..< self.columns {
                mineRow.append(0)
            }
            self.mineGrids.append(mineRow)
        }
        for _ in 0 ..< self.mines {
            var set = false
            while !set {
                let row = Int(arc4random()) % rows
                let col = Int(arc4random()) % columns
                if self.mineGrids[row][col] != -1 {
                    let shouldSkip = row - firstRow <= 1
                        && row - firstRow >= -1
                        && col - firstColumn <= 1
                        && col - firstColumn >= -1
                    if !shouldSkip {
                        self.mineGrids[row][col] = -1
                        set = true
                    }
                }
            }
        }
        self.generateNumbers()
    }
    
    private func generateNumbers() {
        for row in 0 ..< self.mineGrids.count {
            for col in 0 ..< self.mineGrids[row].count {
                if self.mineGrids[row][col] != -1 {
                    self.mineGrids[row][col] = self.countOfMineArround(row, col)
                }
            }
        }
    }
    
    private func countOfMineArround(_ row: Int, _ col: Int) -> Int8 {
        var count: Int8 = 0
        if row > 0 && col > 0 && self.mineGrids[row - 1][col - 1] == -1 {
            count += 1
        }
        if row > 0 && self.mineGrids[row - 1][col] == -1 {
            count += 1
        }
        if row > 0 && col < columns - 1 && self.mineGrids[row - 1][col + 1] == -1 {
            count += 1
        }
        if col > 0 && self.mineGrids[row][col - 1] == -1 {
            count += 1
        }
        if col < columns - 1 && self.mineGrids[row][col + 1] == -1 {
            count += 1
        }
        if row < rows - 1 && col > 0 && self.mineGrids[row + 1][col - 1] == -1 {
            count += 1
        }
        if row < rows - 1 && self.mineGrids[row + 1][col] == -1 {
            count += 1
        }
        if row < rows - 1 && col < columns - 1 && self.mineGrids[row + 1][col + 1] == -1 {
            count += 1
        }
        return count
    }
    
}
