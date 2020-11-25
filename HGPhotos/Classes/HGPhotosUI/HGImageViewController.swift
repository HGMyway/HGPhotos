//
//  HGImageViewController.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/18.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos


typealias HGSelectDoneBlock = ([PHAsset]?) -> (Void)

 open class HGImageViewController: UIViewController {

    @objc var selectSelectComplateBlock: HGSelectDoneBlock?
    @objc var maxSelectCount = 1 {
        didSet {
            if let photosVC = vcs.first as? HGPhotosViewController {
                photosVC.maxSelectCount = maxSelectCount
            }
        }
    }
    @objc var selectedAssets: [PHAsset]?
    let contentView = UIView()
    let vcs = [HGPhotosViewController(), HGAlbumsViewController()]
    var currentVC: UIViewController? {
        willSet {
            guard let newVC = newValue, currentVC != newValue else {
                return
            }
            if let current = currentVC {
                transition(from: current, to: newVC, duration: 0, options: .curveEaseInOut, animations: nil, completion: nil)
            }
            contentView.addSubview(newVC.view)
            newVC.view.align(with: contentView)
            newVC.didMove(toParent: self)
        }
    }
    
    let buttons:[UIButton] = {
        func createButton(title: String, tag: Int) -> UIButton {
            let button = UIButton(type: .custom)
            button.tag = tag
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.orange, for: .selected)
            button.addTarget(self, action: #selector(bottomButtonClick(_:)), for: .touchUpInside)
            return button
        }
        let buttons = [createButton(title: "照片", tag: 0), createButton(title: "相册", tag: 1)]
        buttons.first?.isSelected = true
        return buttons
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        makeUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func makeUI() {

        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "fanhui_3.0.3"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonClick(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        let doneBtn = UIButton(type: .custom)
        doneBtn.backgroundColor = .orange
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        doneBtn.layer.cornerRadius = 3
        doneBtn.addTarget(self, action: #selector(doneButtonClick(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)
        
        let buttonsView = UIStackView(arrangedSubviews: buttons)
        buttonsView.distribution = .fillEqually
        view.addSubview(buttonsView)
        buttonsView.alignLeft(with: view as Any)
        buttonsView.alignRight(with: view as Any)
        buttonsView.alignBottom(with: view as Any, constant: -UIScreen.safeAreaInsets.bottom)
        buttonsView.constraintHeight(50)
        
        view.addSubview(contentView)
        contentView.alignTop(with: view as Any)
        contentView.alignLeft(with: view as Any)
        contentView.alignRight(with: view as Any)
        contentView.alignBottomWithTop(of: buttonsView)
        
        vcs.forEach { (vc) in
            addChild(vc)
        }
        currentVC = vcs.first
        if let pVC = currentVC as? HGPhotosViewController {
            pVC.selectedAssets = selectedAssets ?? []
            pVC.selectSelectComplateBlock = selectSelectComplateBlock
        }
    }
    
    @objc
    func backButtonClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func doneButtonClick(_ sender: UIButton) {
        if let photosVC = vcs.first as? HGPhotosViewController {
            photosVC.doneButtonClick(sender)
        }
    }
    
    @objc
    func bottomButtonClick(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        buttons.forEach { (button) in
            button.isSelected = false
        }
        sender.isSelected = true

        changeChildView(index: sender.tag)
    }
    
    func changeChildView(index: Int) {
        currentVC = vcs[index]
    }

}
