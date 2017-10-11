//
//  ViewController.swift
//  MineSweeper
//
//  Created by 风筝 on 2017/10/10.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    fileprivate let mineContainer: UIView = UIView()
    fileprivate var mineGrids: [[MineGrid]] = []
    @IBOutlet fileprivate weak var leftMineCountLabel: UILabel!
    @IBOutlet fileprivate weak var usedTimeLabel: UILabel!
    
    fileprivate let margin: CGFloat = 80
    fileprivate let gridSize: CGFloat = 42
    
    fileprivate let rows = 30
    fileprivate let columns = 16
    fileprivate let mines = 99
    
    fileprivate var gameStarted: Bool = false
    fileprivate var timer: CADisplayLink?
    fileprivate var timeStep: Int = 0
    fileprivate var openedCount: Int = 0
    fileprivate var countOfMarks = 0 {
        didSet {
            self.leftMineCountLabel.text = "\(self.mines - self.countOfMarks)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.scrollView.delegate = self
        self.scrollView.scrollsToTop = false
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.minimumZoomScale = 0.5
        
        self.mineContainer.frame = CGRect(x: margin,
                                          y: margin,
                                          width: gridSize * CGFloat(columns),
                                          height: gridSize * CGFloat(rows))
        self.scrollView.addSubview(self.mineContainer)
        let width = self.mineContainer.bounds.width + margin * 2
        let height = self.mineContainer.bounds.height + margin * 2
        self.scrollView.contentSize = CGSize(width: width, height: height)
        self.scrollView.contentOffset = CGPoint(x: (width - UIScreen.main.bounds.width) / 2, y: (height - UIScreen.main.bounds.height) / 2)
        
        self.generateMineGrids()
        self.transitionTips()
    }
    
    fileprivate func generateMineGrids() {
        for row in 0 ..< rows {
            var mineGrids: [MineGrid] = []
            for column in 0 ..< columns {
                let grid = MineGrid(rowIndex: row, columnIndex: column)
                grid.delegate = self
                grid.frame = CGRect(x: gridSize * CGFloat(column),
                                    y: gridSize * CGFloat(row),
                                    width: gridSize,
                                    height: gridSize)
                self.mineContainer.addSubview(grid)
                mineGrids.append(grid)
            }
            self.mineGrids.append(mineGrids)
        }
    }
    
    fileprivate func transitionTips() {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.scrollView.zoomScale = 0.75
        }) { (finished) in
            let alert = UIAlertController(title: "操作说明", message: " \n点击：标记为地雷\n用力按：挖开这个格子\n \n点击已经挖开的格子会检查附近的标记，比如点击了已经挖开的格子，这个格子显示数字2，如果这个格子的周围刚好有2个标记则挖开周围所有未标记的格子，否则不执行任何操作。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "开始", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func restartClicked(_ sender: UIButton) {
        self.resetGame()
    }
    
    fileprivate func startGame(with grid: MineGrid) {
        self.generateMine(grid.rowIndex, grid.columnIndex)
        self.gameStarted = true
        self.timer?.invalidate()
        self.timer = CADisplayLink(target: self, selector: #selector(timeStep(_:)))
        self.timer?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    @objc fileprivate func timeStep(_ timer: CADisplayLink) {
        self.timeStep += 1
        if #available(iOS 10.3, *) {
            self.usedTimeLabel.text = "\(self.timeStep / UIScreen.main.maximumFramesPerSecond)"
        } else {
            self.usedTimeLabel.text = "\(self.timeStep / 60)"
        }
    }
    
    fileprivate func resetGame() {
        self.gameStarted = false
        self.timer?.invalidate()
        self.timeStep = 0
        self.openedCount = 0
        self.countOfMarks = 0
        self.leftMineCountLabel.text = "\(mines)"
        self.usedTimeLabel.text = "0"
        for row in 0 ..< self.mineGrids.count {
            for col in 0 ..< self.mineGrids[row].count {
                self.mineGrids[row][col].reset()
            }
        }
    }
    
    fileprivate func generateMine(_ firstRow: Int, _ firstColumn: Int) {
        for _ in 0 ..< mines {
            var set = false
            while !set {
                let row = Int(arc4random()) % rows
                let col = Int(arc4random()) % columns
                let grid = self.mineGrids[row][col]
                if grid.mineNumber != -1 {
                    let shouldSkip = row - firstRow <= 1
                        && row - firstRow >= -1
                        && col - firstColumn <= 1
                        && col - firstColumn >= -1
                    if !shouldSkip {
                        grid.mineNumber = -1
                        set = true
                    }
                }
            }
        }
        self.generateNumbers()
    }
    
    fileprivate func generateNumbers() {
        for row in 0 ..< self.mineGrids.count {
            let gridRow = self.mineGrids[row]
            for col in 0 ..< gridRow.count {
                let grid = gridRow[col]
                if grid.mineNumber != -1 {
                    grid.mineNumber = self.countOfMineArround(row, col)
                }
            }
        }
    }
    
    fileprivate func countOfMineArround(_ row: Int, _ col: Int) -> Int {
        var count = 0
        if row > 0 && col > 0 && self.mineGrids[row - 1][col - 1].mineNumber == -1 {
            count += 1
        }
        if row > 0 && self.mineGrids[row - 1][col].mineNumber == -1 {
            count += 1
        }
        if row > 0 && col < columns - 1 && self.mineGrids[row - 1][col + 1].mineNumber == -1 {
            count += 1
        }
        if col > 0 && self.mineGrids[row][col - 1].mineNumber == -1 {
            count += 1
        }
        if col < columns - 1 && self.mineGrids[row][col + 1].mineNumber == -1 {
            count += 1
        }
        if row < rows - 1 && col > 0 && self.mineGrids[row + 1][col - 1].mineNumber == -1 {
            count += 1
        }
        if row < rows - 1 && self.mineGrids[row + 1][col].mineNumber == -1 {
            count += 1
        }
        if row < rows - 1 && col < columns - 1 && self.mineGrids[row + 1][col + 1].mineNumber == -1 {
            count += 1
        }
        return count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mineContainer
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var width = self.mineContainer.bounds.width * scrollView.zoomScale
        if width > UIScreen.main.bounds.width {
            width += margin * 2
            var frame = self.mineContainer.frame
            frame.origin.x = margin
            self.mineContainer.frame = frame
        } else {
            var frame = self.mineContainer.frame
            frame.origin.x = (UIScreen.main.bounds.width - frame.size.width) / 2
            self.mineContainer.frame = frame
        }
        var height = self.mineContainer.bounds.height * scrollView.zoomScale
        if height > UIScreen.main.bounds.height - 20 {
            height += margin * 2
        }
        self.scrollView.contentSize = CGSize(width: width, height: height)
    }
}

extension ViewController: MineGridDelegate {
    
    func gridClicked(grid: MineGrid) {
        if grid.isOpened {
            if grid.mineNumber > 0 {
                self.openArround(grid: grid)
            }
        } else {
            grid.isMarked = !grid.isMarked
            self.countOfMarks += grid.isMarked ? 1 : -1
        }
    }
    
    func gridDeepPressed(grid: MineGrid) {
        if #available(iOS 10.0, *) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.prepare()
            impact.impactOccurred()
        }
        self.open(grid: grid)
    }
    
    fileprivate func open(grid: MineGrid) {
        if !self.gameStarted {
            self.startGame(with: grid)
        }
        if grid.isOpened || grid.isMarked {
            return
        }
        grid.open()
        self.openedCount += 1
        if grid.mineNumber == -1 {
            self.gameOver()
        } else if self.openedCount == rows * columns - mines {
            self.gameWin()
        } else if grid.mineNumber == 0 {
            self.openArround(grid: grid)
        }
    }
    
    fileprivate func gameWin() {
        self.timer?.invalidate()
        AudioServicesPlaySystemSound(1521)
        var time = 0
        if #available(iOS 10.3, *) {
            time = Int((Double(self.timeStep) / Double(UIScreen.main.maximumFramesPerSecond)) * 100)
        } else {
            time = Int((Double(self.timeStep) / 60) * 100)
        }
        let alert = UIAlertController(title: "大吉大利今晚吃鸡", message: "总耗时：\(Double(time) / 100.0)秒", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "稍后", style: .cancel, handler: { (action) in
            self.gameStarted = false
            for row in 0 ..< self.mineGrids.count {
                for col in 0 ..< self.mineGrids[row].count {
                    self.mineGrids[row][col].isEnabled = false
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "开新一局", style: .default, handler: { (action) in
            self.gameStarted = false
            self.resetGame()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func gameOver() {
        self.timer?.invalidate()
        for row in 0 ..< self.mineGrids.count {
            for col in 0 ..< self.mineGrids[row].count {
                self.mineGrids[row][col].gameFailed()
            }
        }
        AudioServicesPlaySystemSound(1521)
        let alert = UIAlertController(title: "游戏结束", message: "踩到炸弹啦笨蛋！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "稍后", style: .cancel, handler: { (action) in
            self.gameStarted = false
            for row in 0 ..< self.mineGrids.count {
                for col in 0 ..< self.mineGrids[row].count {
                    self.mineGrids[row][col].isEnabled = false
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "重新开始", style: .default, handler: { (action) in
            self.gameStarted = false
            self.resetGame()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func openArround(grid: MineGrid) {
        let gridsArround = self.getGridsArround(grid: grid)
        var markCount = 0
        for grid in gridsArround {
            markCount += grid.isMarked ? 1 : 0
        }
        if markCount != grid.mineNumber {
            return
        }
        for grid in gridsArround {
            self.open(grid: grid)
        }
    }
    
    fileprivate func getGridsArround(grid: MineGrid) -> [MineGrid] {
        let row = grid.rowIndex
        let column = grid.columnIndex
        var grids: [MineGrid] = []
        if row > 0 && column > 0 {
            grids.append(self.mineGrids[row - 1][column - 1])
        }
        if row > 0 {
            grids.append(self.mineGrids[row - 1][column])
        }
        if row > 0 && column < columns - 1 {
            grids.append(self.mineGrids[row - 1][column + 1])
        }
        if column > 0 {
            grids.append(self.mineGrids[row][column - 1])
        }
        if column < columns - 1 {
            grids.append(self.mineGrids[row][column + 1])
        }
        if row < rows - 1 && column > 0 {
            grids.append(self.mineGrids[row + 1][column - 1])
        }
        if row < rows - 1 {
            grids.append(self.mineGrids[row + 1][column])
        }
        if row < rows - 1 && column < columns - 1 {
            grids.append(self.mineGrids[row + 1][column + 1])
        }
        return grids
    }
    
}
