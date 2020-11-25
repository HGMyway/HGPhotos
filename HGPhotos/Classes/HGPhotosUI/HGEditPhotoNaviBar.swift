//
//  HGEditPhotoNaviBar.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/19.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos

class HGEditPhotoNaviBar: UIView {
    typealias HGEditPhotoNaviBarBlock = () -> Void
    typealias HGEditPhotoNaviBarCellBlock = (_ index: Int) -> Void
    
    var backButtonBlock: HGEditPhotoNaviBarBlock?
    var okButtonBlock: HGEditPhotoNaviBarBlock?
    var clickCellBlock: HGEditPhotoNaviBarCellBlock?
    var assetsArr: [PHAsset]?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = backgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HGEditPhotosNavCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        addSubview(view)
        view.align(with: self, inset: UIEdgeInsets(top: UIScreen.safeAreaInsets.top, left: 0, bottom: 0, right: 0))
        return view
    }()
    
    weak open var delegate: UICollectionViewDelegate?
    weak open var dataSource: UICollectionViewDataSource?
    
    var okBtn: UIButton = {
        let okBtn = UIButton(type: .custom)
        okBtn.backgroundColor = .orange
        okBtn.layer.cornerRadius = 3
        okBtn.setTitle("确定", for: .normal)
        okBtn.addTarget(self, action: #selector(okButtonAction(_:)), for: .touchUpInside)
        return okBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        contentView.addSubview(okBtn)
        okBtn.alignRight(with: contentView, constant: -18)
        okBtn.alignTop(with: contentView, constant: 9)
        okBtn.alignBottom(with: contentView, constant: -9)
        okBtn.constraintWidth(60)
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        contentView.addSubview(backBtn)
        backBtn.alignLeft(with: contentView, constant: 18)
        backBtn.alignTop(with: contentView)
        backBtn.alignBottom(with: contentView)
        backBtn.constraintWidth(40)
        backBtn.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
        
        contentView.addSubview(collectionView)
        collectionView.alignLeftWithRight(of: backBtn, constant: 9)
        collectionView.alignTop(with: contentView)
        collectionView.alignBottom(with: contentView)
        collectionView.alignRightWithLeft(of: okBtn, constant: -9)
    }
    
    @objc
    func backButtonAction(_ sender: UIButton) {
        backButtonBlock?()
    }
    
    @objc
    func okButtonAction(_ sender: UIButton) {
        okButtonBlock?()
    }
}

extension HGEditPhotoNaviBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return !(collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        clickCellBlock?(indexPath.item)
    }
}

extension HGEditPhotoNaviBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HGEditPhotosNavCell, let asset = assetsArr?[indexPath.item] else {
            return UICollectionViewCell()
        }
        cell.updateCell(asset)
        return cell
    }
}
