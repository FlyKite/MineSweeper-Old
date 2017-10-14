//
//  SettingsViewController.swift
//  MineSweeper
//
//  Created by FlyKite on 2017/10/14.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    let items: [SettingItem] = [
        SettingItem.selectionType("界面主题", subTitle: "设置界面的主题色彩", rightText: "蓝色"),
        SettingItem.selectionType("操作模式", subTitle: "设置点击及3D Touch的操作", rightText: "智能模式"),
        SettingItem.selectionType("游戏难度", subTitle: "游戏难度决定雷区大小以及地雷数量", rightText: "高级"),
        SettingItem.switchType("翻牌动画", subTitle: "点击挖开格子时候的翻牌动画"),
        SettingItem.switchType("今晚吃鸡", subTitle: "游戏胜利时显示“大吉大利今晚吃鸡”"),
        SettingItem.subTitleType("操作说明", subTitle: "如果忘记怎么操作可以看一下"),
        SettingItem.subTitleType("历史记录", subTitle: "回顾一下当年的英姿"),
        SettingItem.subTitleType("捐赠", subTitle: "如果觉得满意，您可以向开发者打赏点小费"),
        SettingItem.normalType("关于")
    ]
    
    @IBAction func hideButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        switch item.type {
        case .selection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectionCell", for: indexPath) as! SelectionCell
            cell.titleLabel.text = item.title
            cell.subTitleLabel.text = item.subTitle
            cell.rightLabel.text = item.rightText
            return cell
        case .withSwitch:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchCell
            cell.titleLabel.text = item.title
            cell.subTitleLabel.text = item.subTitle
            cell.statusSwitch.setOn(item.switchOn, animated: true)
            return cell
        case .subTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subTitleCell", for: indexPath) as! SubTitleCell
            cell.titleLabel.text = item.title
            cell.subTitleLabel.text = item.subTitle
            return cell
        case .normal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell", for: indexPath) as! NormalCell
            cell.titleLabel.text = item.title
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
