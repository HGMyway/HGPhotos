//
//  HGEditPhotosNavCell.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/19.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos
class HGEditPhotosNavCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .red
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        contentView.addSubview(imageView)
        imageView.align(with: contentView)
    }
    func updateCell(_ asset: PHAsset) {
        HGPhotosTool.standard.fetchFastImage(size: CGSize(width: 40, height: 40), asset: asset) { [weak self] (image, result) in
            self?.imageView.image = image
        }
    }
}
