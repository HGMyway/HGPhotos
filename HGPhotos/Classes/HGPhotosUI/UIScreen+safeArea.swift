//
//  UIScreen.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/18.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit

extension UIScreen {
    static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            var safeAreaInsets = window?.safeAreaInsets ?? .zero
            // iOS11 safeAreaInsets 非刘海屏 (0,0,0,0)
            // iOS12 及以上，非刘海屏(20,0,0,0)
            // 统一修正为(20,0,0,0)
            if safeAreaInsets.top == 0 {
                safeAreaInsets.top = 20
            }
            return safeAreaInsets
        }
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}
