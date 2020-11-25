//
//  HGEditImageView.swift
//  HGPhotos_swift
//
//  Created by 小雨很美 on 2020/11/21.
//  Copyright © 2020 小雨很美. All rights reserved.
//

import UIKit

class HGEditImageView: UIView {
    enum HGEditLocation: Int {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
    }
    
    let minArrow: CGFloat = 60
    var aspectRatio: CGFloat = 1.0
    var curArea: CGRect? {
        didSet {
            maskAlphaView.isHidden = curArea == nil
            clipView.isHidden = curArea == nil
            clipView.frame = curArea ?? .zero
            clipMask()
        }
    }
  
    let editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var maskAlphaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.isHidden = true
        return view
    }()
    
    lazy var clipView: UIView = {
        let view = UIView()
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(clipPanGes(panGes:)))
        view.isHidden = true
        let arrow1 = UIImageView(image: UIImage(named: "arrow1"))
        let arrow2 = UIImageView(image: UIImage(named: "arrow2"))
        let arrow3 = UIImageView(image: UIImage(named: "arrow3"))
        let arrow4 = UIImageView(image: UIImage(named: "arrow4"))
        [arrow1, arrow2, arrow3, arrow4].enumerated().forEach { (index, imageView) in
            view.addSubview(imageView)
            imageView.tag = index
            let panGes1 = UIPanGestureRecognizer(target: self, action: #selector(clipPanGes1(panGes:)))
            imageView.addGestureRecognizer(panGes1)
            imageView.isUserInteractionEnabled = true
            panGes.require(toFail: panGes1)
        }
        arrow1.alignLeft(with: view)
        arrow1.alignTop(with: view)
        
        arrow2.alignRight(with: view)
        arrow2.alignTop(with: view)
        
        arrow3.alignLeft(with: view)
        arrow3.alignBottom(with: view)
        
        arrow4.alignRight(with: view)
        arrow4.alignBottom(with: view)

        view.addGestureRecognizer(panGes)
        addSubview(view)
        return view
    }()
    
    var image: UIImage? {
        didSet {
            editImageView.image = image
            stopClipImage()
        }
    }
    
    var clipImage: UIImage? {
        get {
            if let cArea = curArea {
                let offset = editImageView.contentArea(true) ?? .zero
                return editImageView.subImage(cropRect: cArea.offsetBy(dx: -offset.minX, dy: -offset.minY))
            } else {
                return image
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        addSubview(editImageView)
        editImageView.align(with: self, inset: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        addSubview(maskAlphaView)
        maskAlphaView.align(with: self)
    }
    
    func rotateImage() {
        image = editImageView.image?.rotaion(.right)
    }
    
    func startClipImage(_ ratio: CGFloat = 1) {
        aspectRatio = ratio
        curArea = editImageView.contentArea(true)?.maxSubRect(ratio: ratio)
    }
    
    func stopClipImage() {
        curArea = nil
    }
    
    func clipMask() {
        let path = UIBezierPath.init(rect: maskAlphaView.bounds)
        let clearPath = UIBezierPath.init(rect: clipView.frame).reversing()
        path.append(clearPath)
        let shLayer = maskAlphaView.layer.mask as? CAShapeLayer ??  CAShapeLayer()
        shLayer.path = path.cgPath
        maskAlphaView.layer.mask = shLayer
    }
    
    func checkLocation(in size: CGSize, point: CGPoint) -> HGEditLocation? {
        let maxLength: CGFloat = min(size.width / 2, minArrow)
        
        if point.x < maxLength {
            if point.y < maxLength {
                return .leftTop
            }
            if point.y > size.width - maxLength {
                return .leftBottom
            }
        }  else if point.x > size.width - maxLength {
            if point.y < maxLength {
                return .rightTop
            }
            if point.y > size.width - maxLength {
                return .rightBottom
            }
        }
        return nil
    }
    
    @objc
    func clipPanGes1(panGes: UIPanGestureRecognizer) {
        
        defer {
            panGes.setTranslation(.zero, in: editImageView)
        }
        guard panGes.state == .changed, let panView = panGes.view, let location = HGEditLocation(rawValue: panView.tag), let contentArea = editImageView.contentArea(true) else {
            return
        }
        var tran = panGes.translation(in: editImageView)
        
        
        let code: CGFloat = tran.x * tran.y > 0 ? 1 : -1
        
        let r: CGFloat = aspectRatio * code
        
        if tran.x == 0 {
            tran.x = tran.y * r
        }
        if tran.y == 0 {
            tran.y = tran.x * r
        }
        
        let cr = abs(tran.y / tran.x)
        
        if cr > r * code {
            tran.x = tran.y * r
        } else {
            tran.y = tran.x * r
        }
        
        var curFrame = clipView.frame
        
        var curInset = UIEdgeInsets(top: curFrame.minY - contentArea.minY, left: curFrame.minX - contentArea.minX, bottom: contentArea.maxY - curFrame.maxY, right: contentArea.maxX - curFrame.maxX)

        switch location {
        case .leftTop:
            
            if code == -1 {
                if abs(tran.x) > abs(tran.y) {
                    tran.y = -tran.y
                } else {
                    tran.x = -tran.x
                }
            }
            
            if curInset.left + tran.x < 0 {
                tran.x = -curInset.left
                tran.y = r * tran.x
            }
            if curInset.top + tran.y < 0 {
                tran.y = -curInset.top
                tran.x = tran.y / r
            }
            
            if curFrame.width - tran.x < minArrow * 2 {
                tran.x = curFrame.width - minArrow * 2
                tran.y = r * tran.x
            }
            
            if curFrame.height - tran.y < minArrow * 2 {
                tran.y =  curFrame.height - minArrow * 2
                tran.x = tran.y / r
            }
            
            curInset.left = curInset.left + tran.x
            curInset.top = curInset.top + tran.y
            
            

        case .rightTop:
            
            if code == 1 {
                if abs(tran.x) > abs(tran.y) {
                    tran.y = -tran.y
                } else {
                    tran.x = -tran.x
                }
            }
            
            if curInset.right < tran.x {
                tran.x = curInset.right
                tran.y = r * tran.x
            }
//
            if curInset.top + tran.y < 0 {
                tran.y = -curInset.top
                tran.x = tran.y / r
            }

            if curFrame.width + tran.x < minArrow * 2 {
                tran.x = minArrow * 2 - curFrame.width
                tran.y = r * tran.x
            }
//
            if curFrame.height - tran.y < minArrow * 2 {
                tran.y =  curFrame.height - minArrow * 2
                tran.x = tran.y / r
            }
            
            curInset.right = curInset.right - tran.x
            curInset.top = curInset.top + tran.y
        case .leftBottom:
            if code == 1 {
                if abs(tran.x) > abs(tran.y) {
                    tran.y = -tran.y
                } else {
                    tran.x = -tran.x
                }
            }
            
            if curInset.left + tran.x < 0 {
                tran.x = -curInset.left
                tran.y = r * tran.x
            }

            if curInset.bottom < tran.y {
                tran.y = curInset.bottom
                tran.x = tran.y / r
            }

            if curFrame.width - tran.x < minArrow * 2 {
                tran.x = curFrame.width - minArrow * 2
                tran.y = r * tran.x
            }
            
            if curFrame.height + tran.y < minArrow * 2 {
                tran.y = minArrow * 2 - curFrame.height
                tran.x = tran.y / r
            }
            
            
            curInset.left = curInset.left + tran.x
            curInset.bottom = curInset.bottom - tran.y
        case .rightBottom:
            
            if code == -1 {
                if abs(tran.x) > abs(tran.y) {
                    tran.y = -tran.y
                } else {
                    tran.x = -tran.x
                }
            }
            
            if curInset.right < tran.x {
                tran.x = curInset.right
                tran.y = r * tran.x
            }

            if curInset.bottom < tran.y {
                tran.y = curInset.bottom
                tran.x = tran.y / r
            }

            if curFrame.width + tran.x < minArrow * 2 {
                tran.x = minArrow * 2 - curFrame.width
                tran.y = r * tran.x
            }

            if curFrame.height + tran.y < minArrow * 2 {
                tran.y = minArrow * 2 - curFrame.height
                tran.x = tran.y / r
            }
            curInset.right = curInset.right - tran.x
            curInset.bottom = curInset.bottom - tran.y
        }
        
        curFrame = contentArea.inset(by: curInset)
        if curFrame.height != curFrame.width * r * code {
            curFrame.size.height = curFrame.width * r * code
        }

        curArea = curFrame
    }
    

    
    @objc
    func clipPanGes(panGes: UIPanGestureRecognizer) {
        defer {
            panGes.setTranslation(.zero, in: editImageView)
        }
        guard panGes.state == .changed, let contentArea = editImageView.contentArea(true) else {
            return
        }
        let tran = panGes.translation(in: editImageView)

        
        let canX = (min(contentArea.minX - clipView.frame.minX, 0), max(contentArea.maxX - clipView.frame.maxX, 0))
        let canY = (min(contentArea.minY - clipView.frame.minY, 0), max(contentArea.maxY - clipView.frame.maxY, 0))
        let offset = CGPoint(x: max(canX.0, min(canX.1, tran.x)), y: max(canY.0, min(canY.1, tran.y)))
        let newFram = clipView.frame.offsetBy(dx: offset.x, dy: offset.y)
        curArea = newFram
    }
}

extension CGRect {
    //ratio = h / w
    func maxSubRect(ratio: CGFloat) -> CGRect {
        guard size != .zero else {
            return self
        }
        var nSize = size
        var nOrigin = origin
        if size.height / size.width > ratio {
            nSize.height = size.width * ratio
            nOrigin.y = nOrigin.y + (size.height - nSize.height) / 2
        } else {
            nSize.width = size.height / ratio
            nOrigin.x = nOrigin.x + (size.width - nSize.width) / 2
        }
        return CGRect(origin: nOrigin, size: nSize)
    }
}
