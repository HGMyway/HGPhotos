//
//  HGEditPhotoViewController.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/19.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos

open class HGEditPhotoViewController: UIViewController {
    
    @objc var saveEditBlock: ((PHAsset, PHAsset) -> (Void))?
    @objc var selectSelectComplateBlock: HGSelectDoneBlock?
    @objc var assetsArr: [PHAsset]?
    let naviBar = HGEditPhotoNaviBar()
    var isChange = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                if let isChange = self?.isChange {
                    self?.naviBar.okBtn.setTitle(isChange ? "保存" : "确定", for: .normal)
                }
            }
        }
    }
    
    let editImageView: HGEditImageView = {
        let imageView = HGEditImageView()
        return imageView
    }()
    
    @objc var currentIndex: Int = 0
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        loadImage(index: currentIndex)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func makeUI() {
        view.backgroundColor = .black
        let toolBar = HGEditPhotoToolBar()
        
        naviBar.assetsArr = assetsArr
        naviBar.backButtonBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        naviBar.okButtonBlock = { [weak self, toolBar] in
            if self?.isChange == true {
                if let index = self?.currentIndex{
                    self?.saveImage(at: index)
                    toolBar.resetButtonState()
                }
            } else {
                self?.selectSelectComplateBlock?(self?.assetsArr)
            }
            
        }
        naviBar.clickCellBlock = { [weak self] (index) in
            self?.editImageView.stopClipImage()
            self?.loadImage(index: index)
        }
        view.addSubview(naviBar)
        naviBar.alignTop(with: view as Any)
        naviBar.alignLeft(with: view as Any)
        naviBar.alignRight(with: view as Any)
        naviBar.constraintHeight(UIScreen.safeAreaInsets.top + 44)
        
        
        
        view.addSubview(toolBar)
        toolBar.toolBarAction = { [weak self] (type, isStart) in
            switch type {
            case .rotate:
                self?.rotateImage()
            default:
                self?.clipImage(type: type, isStart: isStart)
            }
        }
        toolBar.alignLeft(with: view as Any)
        toolBar.alignRight(with: view as Any)
        toolBar.alignBottom(with: view as Any)
        toolBar.constraintHeight(UIScreen.safeAreaInsets.bottom + 70)
        
        view.addSubview(editImageView)
        editImageView.alignLeft(with: view as Any)
        editImageView.alignRight(with: view as Any)
        editImageView.alignTopWithBottom(of: naviBar)
        editImageView.alignBottomWithTop(of: toolBar)
    }
    
    func loadImage(index: Int) {
        guard let asset = assetsArr?[index] else {
            return
        }
        currentIndex = index
        isChange = false
        HGPhotosTool.standard.fetchHighQualityImage(size: editImageView.frame.size, asset: asset) { [weak self] (image, info) in
            guard self?.currentIndex == self?.assetsArr?.firstIndex(of: asset) else { return }
            self?.editImageView.image = image
            self?.editImageView.stopClipImage()
            
        }
    }
    
    func saveImage(at index: Int) {
        guard let sImage = self.editImageView.clipImage else {
            return
        }
        isChange = false
        self.editImageView.image = sImage
        HGPhotosTool.standard.save(image: sImage) { [weak self] (asset) in
            if let newAsset = asset, let oldAsset = self?.assetsArr?[index] {
                self?.assetsArr?[index] = newAsset
                self?.saveEditBlock?(newAsset, oldAsset)
            }
        }
    }
    
    func rotateImage() {
        isChange = true
        editImageView.rotateImage()
    }
    
    func clipImage(type: HGEditPhotoToolBar.HGActionType, isStart: Bool) {
        isChange = isStart
        if isStart {
            editImageView.startClipImage(type.aspectRatio())
        } else {
            editImageView.stopClipImage()
        }
        
    }
}

extension HGEditPhotoViewController: UIGestureRecognizerDelegate {
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
