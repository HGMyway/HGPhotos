//
//  UIImage+Category.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/20.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit

extension UIImage {
    func rotaion(_ rotation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        defer {
            UIGraphicsEndImageContext()
        }
        var rotate: CGFloat = 0
        var rect = CGRect.zero
        var translateX: CGFloat = 0
        var translateY: CGFloat = 0
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
        
        switch rotation {
        case .right:
            rotate = (CGFloat.pi / 2 ) * 3
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
            translateX = -rect.height
            translateY = 0
            scaleX = rect.height / rect.width
            scaleY = rect.width / rect.height
            
        default:
            rotate = 0
        }
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: rect.height)
        context?.scaleBy(x: 1, y: -1)
        context?.rotate(by: rotate)
        context?.translateBy(x: translateX, y: translateY)
        context?.scaleBy(x: scaleX, y: scaleY)
        context?.draw(cgImage, in: rect)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        return image
    }
    
    func subImage(cropRect: CGRect, scale: CGFloat = 1.0) -> UIImage? {
        guard let imageRef = cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: imageRef, scale: scale, orientation: .up)
    }
    
}

extension UIImageView {
    func subImage(cropRect: CGRect) -> UIImage? {

        if let iWidth = image?.size.width, let cWidth = contentArea()?.size.width, cWidth != 0{
            let scale = iWidth / cWidth
            let scaleRect = CGRect(x: cropRect.minX * scale, y: cropRect.minY * scale, width: cropRect.width * scale, height: cropRect.height * scale)
            return image?.subImage(cropRect: scaleRect)
        }
        return image?.subImage(cropRect: cropRect)
    }
    func contentArea(_ frameBase: Bool = false) -> CGRect? {
        guard let image = image, image.size != .zero, bounds != .zero else {
            return nil
        }
        var area = bounds
        if contentMode == .scaleAspectFit {
            let dd =  image.size.height / image.size.width
            if dd < bounds.height /  bounds.width {
                let imageH = bounds.width * dd
                area = CGRect(x: 0, y: (bounds.height - imageH) / 2, width: bounds.width, height: imageH)
            } else {
                let imageW = bounds.height / dd
                area =  CGRect(x: ( bounds.width - imageW) / 2, y: 0, width: imageW, height: bounds.height)
            }
        }
        return frameBase ? area.offsetBy(dx: frame.minX, dy: frame.minY) : area
    }
}

