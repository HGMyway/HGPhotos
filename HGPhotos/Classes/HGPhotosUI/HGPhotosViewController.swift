//
//  HGPhotosViewController.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/18.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos

class HGPhotosViewController: UIViewController {
    var maxSelectCount = 1
    var assetColl: PHAssetCollection?
    var assetsResult: PHFetchResult<PHAsset>?
    var selectedAssets: [PHAsset] = []
    
    var selectSelectComplateBlock: HGSelectDoneBlock?
    
    lazy var itemSize: CGSize = {
        let itemWidth = floor((view.frame.width - 5 * 5) / 4)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        return itemSize
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = itemSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
        collectionView.align(with: view as Any, inset: UIEdgeInsets(top: 5, left: 5, bottom: UIScreen.safeAreaInsets.bottom, right: 5))
        collectionView.register(HGPhotosCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        makeUI()
        fetchData()
        PHPhotoLibrary.shared().register(self)
    }
    
    func makeUI() {
        let doneBtn = UIButton(type: .custom)
        doneBtn.backgroundColor = .orange
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        doneBtn.layer.cornerRadius = 3
        doneBtn.addTarget(self, action: #selector(doneButtonClick(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneBtn)
    }
    
    @objc
    func doneButtonClick(_ sender: UIButton) {
        guard selectedAssets.count > 0 else {
            showAlert("请选择作品")
            return
        }
        let editVC = HGEditPhotoViewController()
        editVC.assetsArr = selectedAssets
        editVC.selectSelectComplateBlock = selectSelectComplateBlock
        editVC.saveEditBlock = { [weak self] (newAsset, oldAsset) in
            if let index = self?.selectedAssets.firstIndex(of: oldAsset) {
                self?.selectedAssets[index] = newAsset
            }
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func checkMaxCount() -> Bool {
        let currentCount = selectedAssets.count
        if currentCount < maxSelectCount {
            return true
        } else {
            showAlert("最多选择\(maxSelectCount)张照片")
            return false
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        
        parent?.present(alert, animated: true, completion: nil)
    }
    
    func fetchData() {
        HGPhotosTool.standard.fetchAssets(collection: assetColl) { [weak self] (result, coll) in
            self?.assetsResult = result
            self?.selectedAssets = self?.selectedAssets.filter({ (asset) -> Bool in
                return self?.assetsResult?.contains(asset) ?? false
            }) ?? []
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                if let resultCount = result?.count, resultCount > 1 {
                    let lastItem = IndexPath(item: resultCount - 1, section: 0)
                    self?.collectionView.scrollToItemAsync(at: lastItem, at: .bottom, animated: false)
                }
            }
        }
    }
}

extension HGPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let asset = assetsResult?.object(at: indexPath.item), selectedAssets.firstIndex(of: asset) != nil {
            return true
        }
        return checkMaxCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let asset = assetsResult?.object(at: indexPath.item) {
            if let index = selectedAssets.firstIndex(of: asset) {
                selectedAssets.remove(at: index)
            } else {
                selectedAssets.append(asset)
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
}
extension HGPhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HGPhotosCollectionViewCell, let asset = assetsResult?.object(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        cell.updateCell(asset, isSelected: selectedAssets.contains(asset))
        return cell
    }
}

extension HGPhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        fetchData()
    }
}
