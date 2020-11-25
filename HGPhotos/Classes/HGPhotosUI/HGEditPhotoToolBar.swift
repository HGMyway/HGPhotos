//
//  HGEditPhotoToolBar.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/19.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit

class HGEditPhotoToolBar: UIView {
    enum HGActionType: Int {
        case rotate = 0
        case clip43 = 2
        case clip34 = 3
        case clip11 = 4
        
        func aspectRatio() -> CGFloat {
            switch self {
            case .clip34:
                return 3 / 4
            case .clip43:
                return 4 / 3
            default:
                return 1
            }
        }
    }
    
    typealias HGEditPhotoToolBarAction = (_ type: HGActionType, _ isStart: Bool) -> Void
    var toolBarAction: HGEditPhotoToolBarAction?
    
    lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = 0
        addSubview(view)
        view.align(with: self, inset: UIEdgeInsets(top: 0, left: 0, bottom: UIScreen.safeAreaInsets.bottom, right: 0))
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
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        let labelText = "请保证照片朝向正确"
        let infoArr = [("ic_90_n", "ic_90_h"), (labelText, nil), ("ic_4_3_n", "ic_4_3_h"), ("ic_3_4_n", "ic_3_4_h"), ("ic_1_1_n", "ic_1_1_h")]
        infoArr.enumerated().forEach { (index, item) in
            if let hight = item.1 {
                let button = createButton(normal: item.0, highlighted: hight, tag: index)
                contentView.addArrangedSubview(button)
            } else {
                let label = createLabel(text: item.0)
                contentView.addArrangedSubview(label)
            }
        }
    }
    
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }
    
    func createButton(normal: String, highlighted: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(toolAction(_:)), for: .touchUpInside)
        button.tag = tag
        button.setImage(UIImage(named: normal), for: .normal)
        button.setImage(UIImage(named: highlighted), for: .highlighted)
        button.setImage(UIImage(named: highlighted), for: .selected)
        return button
    }
    
    @objc
    func toolAction(_ sender: UIButton) {
        guard let type = HGActionType.init(rawValue: sender.tag) else {
            return
        }
        
        if sender.isSelected {
            sender.isSelected = false
        } else {
            resetButtonState()
            sender.isSelected = true
        }
        toolBarAction?(type, sender.isSelected)
    }
    
    func resetButtonState() {
        contentView.arrangedSubviews.forEach { (view) in
            if let button = view as? UIButton {
                button.isSelected = false
            }
        }
    }
}
