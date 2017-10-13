//
//  SettingItem.swift
//  MineSweeper
//
//  Created by FlyKite on 2017/10/14.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

class SettingItem: NSObject {
    
    enum ItemType {
        case selection
        case withSwitch
        case subTitle
        case normal
    }
    
    let type: ItemType
    var title: String
    var subTitle: String
    var rightText: String
    var switchOn: Bool
    
    static func selectionType(_ title: String, subTitle: String, rightText: String) -> SettingItem {
        return SettingItem(title, type: .selection, subTitle: subTitle, rightText: rightText)
    }
    
    static func switchType(_ title: String, subTitle: String, switchOn: Bool = false) -> SettingItem {
        return SettingItem(title, type: .withSwitch, subTitle: subTitle, switchOn: switchOn)
    }
    
    static func subTitleType(_ title: String, subTitle: String) -> SettingItem {
        return SettingItem(title, type: .subTitle, subTitle: subTitle)
    }
    
    static func normalType(_ title: String) -> SettingItem {
        return SettingItem(title, type: .normal)
    }
    
    fileprivate init(_ title: String, type: ItemType, subTitle: String = "", rightText: String = "", switchOn: Bool = false) {
        self.title = title
        self.type = type
        self.subTitle = subTitle
        self.rightText = rightText
        self.switchOn = switchOn
    }
    
}
