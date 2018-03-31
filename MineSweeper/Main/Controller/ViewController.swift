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
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var leftMineCountLabel: UILabel!
    @IBOutlet private weak var usedTimeLabel: UILabel!
    @IBOutlet private weak var tipsAlertView: UIView!
    private let mineContainer: UIView = UIView()
    private var mineGrids: [[MineGrid]] = []
    
    private let margin: CGFloat = 80
    private let gridSize: CGFloat = 42
    
    private var mineMap: MineMap = MineMap()
    
    private var gameStarted: Bool = false
    private var timer: CADisplayLink?
    private var timeStep: Int = 0
    private var openedCount: Int = 0
    private var countOfMarks = 0 {
        didSet {
            self.leftMineCountLabel.text = "\(self.mineMap.mines - self.countOfMarks)"
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
                                          width: gridSize * CGFloat(self.mineMap.columns),
                                          height: gridSize * CGFloat(self.mineMap.rows))
        self.scrollView.addSubview(self.mineContainer)
        let width = self.mineContainer.bounds.width + margin * 2
        let height = self.mineContainer.bounds.height + margin * 2
        self.scrollView.contentSize = CGSize(width: width, height: height)
        self.scrollView.contentOffset = CGPoint(x: (width - UIScreen.main.bounds.width) / 2, y: (height - UIScreen.main.bounds.height) / 2)
        let x = (self.scrollView.contentSize.width - UIScreen.main.bounds.width) / 2
        let y = (self.scrollView.contentSize.height - UIScreen.main.bounds.height) / 2
        self.scrollView.contentOffset = CGPoint(x: x, y: y)
        
        self.generateMineGrids()
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.scrollView.setZoomScale(0.75, animated: false)
            let x = (self.scrollView.contentSize.width - UIScreen.main.bounds.width) / 2
            let y = (self.scrollView.contentSize.height - UIScreen.main.bounds.height) / 2
            self.scrollView.contentOffset = CGPoint(x: x, y: y)
        }, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutMineContainer()
    }
    
    private func layoutMineContainer() {
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
        if height > UIScreen.main.bounds.height - 20 - margin * 2 {
            height += margin * 2
        } else {
            var frame = self.mineContainer.frame
            frame.origin.y = (UIScreen.main.bounds.height - 20 - frame.size.height) / 2 + 20
            self.mineContainer.frame = frame
        }
        self.scrollView.contentSize = CGSize(width: width, height: height)
    }
    
    private func generateMineGrids() {
        for subview in self.mineContainer.subviews {
            subview.removeFromSuperview()
        }
        self.mineGrids = []
        for row in 0 ..< self.mineMap.rows {
            var mineGridsRow: [MineGrid] = []
            for column in 0 ..< self.mineMap.columns {
                let grid = MineGrid(rowIndex: row, columnIndex: column)
                grid.delegate = self
                grid.frame = CGRect(x: gridSize * CGFloat(column),
                                    y: gridSize * CGFloat(row),
                                    width: gridSize,
                                    height: gridSize)
                self.mineContainer.addSubview(grid)
                mineGridsRow.append(grid)
            }
            self.mineGrids.append(mineGridsRow)
        }
    }
    
    @IBAction func restartClicked(_ sender: UIButton) {
        self.resetGame()
    }
    @IBAction func dontShowAgainClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.tipsAlertView.alpha = 0
        }) { (finished) in
            self.tipsAlertView.isHidden = true
        }
    }
    @IBAction func closeTipsClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.tipsAlertView.alpha = 0
        }) { (finished) in
            self.tipsAlertView.isHidden = true
        }
    }
    
    private func startGame(with grid: MineGrid) {
        self.mineMap = MineMap()
        self.mineMap.generateMine(grid.rowIndex, grid.columnIndex)
        self.gameStarted = true
        self.timer?.invalidate()
        self.timer = CADisplayLink(target: self, selector: #selector(timeStep(_:)))
        self.timer?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    @objc private func timeStep(_ timer: CADisplayLink) {
        self.timeStep += 1
        if #available(iOS 10.3, *) {
            self.usedTimeLabel.text = "\(self.timeStep / UIScreen.main.maximumFramesPerSecond)"
        } else {
            self.usedTimeLabel.text = "\(self.timeStep / 60)"
        }
    }
    
    private func resetGame() {
        self.gameStarted = false
        self.timer?.invalidate()
        self.timeStep = 0
        self.openedCount = 0
        self.countOfMarks = 0
        self.leftMineCountLabel.text = "\(self.mineMap.mines)"
        self.usedTimeLabel.text = "0"
        for row in 0 ..< self.mineGrids.count {
            for col in 0 ..< self.mineGrids[row].count {
                self.mineGrids[row][col].reset()
            }
        }
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
        self.layoutMineContainer()
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
    
    private func open(grid: MineGrid) {
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
        } else if self.openedCount == self.mineMap.rows * self.mineMap.columns - self.mineMap.mines {
            self.gameWin()
        } else if grid.mineNumber == 0 {
            self.openArround(grid: grid)
        }
    }
    
    private func gameWin() {
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
    
    private func gameOver() {
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
    
    private func openArround(grid: MineGrid) {
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
    
    private func getGridsArround(grid: MineGrid) -> [MineGrid] {
        let row = grid.rowIndex
        let column = grid.columnIndex
        var grids: [MineGrid] = []
        if row > 0 && column > 0 {
            grids.append(self.mineGrids[row - 1][column - 1])
        }
        if row > 0 {
            grids.append(self.mineGrids[row - 1][column])
        }
        if row > 0 && column < self.mineMap.columns - 1 {
            grids.append(self.mineGrids[row - 1][column + 1])
        }
        if column > 0 {
            grids.append(self.mineGrids[row][column - 1])
        }
        if column < self.mineMap.columns - 1 {
            grids.append(self.mineGrids[row][column + 1])
        }
        if row < self.mineMap.rows - 1 && column > 0 {
            grids.append(self.mineGrids[row + 1][column - 1])
        }
        if row < self.mineMap.rows - 1 {
            grids.append(self.mineGrids[row + 1][column])
        }
        if row < self.mineMap.rows - 1 && column < self.mineMap.columns - 1 {
            grids.append(self.mineGrids[row + 1][column + 1])
        }
        return grids
    }
    
}
