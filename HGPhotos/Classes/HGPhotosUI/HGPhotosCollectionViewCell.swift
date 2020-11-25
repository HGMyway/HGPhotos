//
//  HGPhotosCollectionViewCell.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/19.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos

class HGPhotosCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    var currentAsset: PHAsset?
    
    lazy var selectIcon: UIView = {
        let view = UIView()
        contentView.addSubview(view)
        view.alignTop(with: contentView, constant: 5)
        view.alignRight(with: contentView, constant: -5)
        view.constraintWidth(16)
        view.constraintHeight(16)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = .orange
        view.isHidden = false
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func makeUI() {
        contentView.addSubview(imageView)
        imageView.align(with: contentView)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    func updateCell(_ asset: PHAsset, isSelected: Bool) {
        selectIcon.isHidden = !isSelected
        currentAsset = asset
        HGPhotosTool.standard.fetchFastImage(size: frame.size, asset: asset) { [weak self] (image, result) in
            DispatchQueue.main.async {
                if self?.currentAsset == asset {
                    self?.imageView.image = image
                }
            }
        }
    }
}
