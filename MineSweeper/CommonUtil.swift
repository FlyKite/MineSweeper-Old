//
//  CommonUtil.swift
//  MineSweeper
//
//  Created by 风筝 on 2017/10/10.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

extension Int {
    
    var rgbColor: UIColor {
        return self.rgbColor(alpha: 1)
    }
    
    func rgbColor(alpha: CGFloat) -> UIColor {
        let red = CGFloat(self >> 16) / 255.0
        let green = CGFloat((self >> 8) & 0xFF) / 255.0
        let blue = CGFloat(self & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
