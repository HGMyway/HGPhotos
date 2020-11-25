//
//  HGAlbumsViewController.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/18.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos

class HGAlbumsViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(HGAlbumsTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    var collResult: [HGAssetCollection]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        fetchData()
    }
    
    func makeUI() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.align(with: view as Any)
    }
    
    func fetchData() {
        HGPhotosTool.standard.fetchAssetCollections { [weak self] (result) in
            self?.collResult = result.compactMap({ (coll) -> HGAssetCollection in
                return HGAssetCollection(asset: coll, needConver: true)
            })
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension HGAlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let coll = collResult?[indexPath.row] else {
            return
        }
        let photosVC = HGPhotosViewController()
        photosVC.assetColl = coll.assetCollection
        if let pVC = parent as? HGImageViewController {
            photosVC.selectedAssets = pVC.selectedAssets ?? []
            photosVC.maxSelectCount = pVC.maxSelectCount
            photosVC.selectSelectComplateBlock = pVC.selectSelectComplateBlock
        }
        navigationController?.pushViewController(photosVC, animated: true)
    }
}

extension HGAlbumsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HGAlbumsTableViewCell, let coll = collResult?[indexPath.row] else {
            return UITableViewCell()
        }
        cell.updateCell(coll: coll)
        return cell
    }
}
