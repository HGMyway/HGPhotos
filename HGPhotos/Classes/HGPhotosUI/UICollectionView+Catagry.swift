//
//  UICollectionView+Catagry.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/20.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit

extension UICollectionView {
    func scrollToItemAsync(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
}
