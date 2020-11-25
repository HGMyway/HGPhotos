//
//  HGAlbumsTableViewCell.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/19.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos

class HGAlbumsTableViewCell: UITableViewCell {
    let converImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        contentView.addSubview(converImageView)
        converImageView.alignTop(with: contentView, constant: 10)
        converImageView.alignLeft(with: contentView, constant: 10)
        converImageView.alignBottom(with: contentView, constant: -10)
        converImageView.constraintWidth(100)
        
        contentView.addSubview(label)
        label.alignLeftWithRight(of: converImageView, constant: 10)
        label.alignCenterY(with: converImageView)
    }
    
    func updateCell(coll: HGAssetCollection) {
        coll.observeInfoBlock = { [weak self] (collection) in
            DispatchQueue.main.async {
                self?.converImageView.image = collection?.coverImage
                self?.label.text = collection?.title
            }
        }
        converImageView.image = coll.coverImage
        label.text = coll.title
    }
    
}
