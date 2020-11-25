//
//  HGPhotosTool.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/18.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit
import Photos
 open class HGPhotosTool: NSObject {
    
    @objc open class func shared() -> HGPhotosTool {
        return standard
    }
     
    static let standard: HGPhotosTool = {
        let standard = HGPhotosTool()
        PHPhotoLibrary.shared().register(standard)
        return standard
    }()
    
    private override init() {
        super.init()   
    }
    
    @discardableResult
    @objc func checkAuth() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        if #available(iOS 14, *) {
            return status == .authorized || status == .limited
        } else {
            return status == .authorized
        }
    }
    
    func fetchAssetCollections(complate: @escaping ([PHAssetCollection]) -> Void) {
        
        DispatchQueue.global().async {
            let result1 = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            let result2 = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            var collArray: [PHAssetCollection] = []
            result1.enumerateObjects { (collection, index, stop) in
                collArray.append(collection)
            }
            result2.enumerateObjects { (collection, index, stop) in
                collArray.append(collection)
            }
            complate(collArray)
        }
    }
    
    func fetchFirstCollectionIfExsit(_ name: String, complate: @escaping (PHAssetCollection?) -> Void) {
        guard name.count > 0 else {
            complate(nil)
            return
        }
        fetchAssetCollections { (collArray) in
            let firstResult = collArray.first { (coll) -> Bool in
                coll.localizedTitle == name
            }
            if let result = firstResult  {
                complate(result)
            } else {
                self.createAssetsClollection(name: name, complate: complate)
            }
        }
    }
    
    //新建相册
    func createAssetsClollection(name: String, complate: @escaping (PHAssetCollection?) -> Void) {
        
        var placeholder: String?
        
        PHPhotoLibrary.shared().performChanges {
            let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            placeholder = changeRequest.placeholderForCreatedAssetCollection.localIdentifier
        } completionHandler: { (success, error) in
            if success, let indenti = placeholder {
                let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [indenti], options: nil)
                complate(result.firstObject)
            } else {
                complate(nil)
            }
        }
    }
    
    func fetchAssets(collection: PHAssetCollection?, complate: @escaping (_ result: PHFetchResult<PHAsset>?, _ collection: PHAssetCollection?) -> Void)  {
        DispatchQueue.global().async {
            var result: PHFetchResult<PHAsset>?
            if let coll = collection {
                result = PHAsset.fetchAssets(in: coll, options: nil)
            } else {
                result = PHAsset.fetchAssets(with: .image, options: nil)
            }
            complate(result, collection)
        }
    }
    
    @discardableResult
   @objc func fetchFastImage(size: CGSize, asset: PHAsset, block: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .opportunistic
        options.normalizedCropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        return PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, result) in
            block(image, result)
        }
    }
    
    @discardableResult
    @objc func fetchHighQualityImage(size: CGSize, asset: PHAsset, block: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.deliveryMode = .highQualityFormat
        return PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, result) in    
            block(image, result)
        }
    }
    
    @objc func save(image: UIImage, complate: @escaping (PHAsset?) -> (Void)) {
        var identifier: String?
        PHPhotoLibrary.shared().performChanges {
            // Request creating an asset from the image.

            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = creationRequest.placeholderForCreatedAsset
            //保存标志符
            identifier = assetPlaceholder?.localIdentifier
        } completionHandler: { (success, error) in
            if success, let identi = identifier, let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identi], options: nil).firstObject {
                complate(asset)
            } else {
                complate(nil)
            }
        }
    }
}


class HGAssetCollection: NSObject {
    var coverImage: UIImage?
    var countAsset: Int?
    var info: [AnyHashable : Any]?
    var assetCollection: PHAssetCollection
    
    var observeInfoBlock: ((HGAssetCollection?) -> ())?
    
    
    init(asset: PHAssetCollection, needConver: Bool = false) {
        assetCollection = asset
        super.init()
        if needConver {
            fetchInfo()
        }
    }
    
    var title: String? {
        get {
            return (assetCollection.localizedTitle ?? "") + "(\(countAsset ?? 0))"
        }
    }
    
    
    func fetchInfo() {
        HGPhotosTool.standard.fetchAssets(collection: assetCollection) { [weak self] (result, coll) in
            self?.countAsset = result?.count
            if let firstA = result?.firstObject {
                HGPhotosTool.standard.fetchFastImage(size: CGSize(width: 100, height: 100), asset: firstA) { (image, info) in
                    self?.coverImage = image
                    self?.info = info
                    self?.observeInfoBlock?(self)
                }
            }
        }
    }
    
}

extension HGPhotosTool: PHPhotoLibraryChangeObserver {
    open func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("photoLibraryDidChange")
    }
}

extension HGPhotosTool: PHPhotoLibraryAvailabilityObserver {
    open func photoLibraryDidBecomeUnavailable(_ photoLibrary: PHPhotoLibrary) {
        print("photoLibraryDidBecomeUnavailable")
    }
}
