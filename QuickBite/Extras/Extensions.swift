//
//  Extensions.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import UIKit

//MARK:- UIFont
extension UIFont {
    func smallCaps() -> UIFont {
        let upperCaseFeature = [
            UIFontDescriptor.FeatureKey.featureIdentifier : kUpperCaseType,
            UIFontDescriptor.FeatureKey.typeIdentifier : kUpperCaseType
         ]

        let lowerCaseFeature = [
            UIFontDescriptor.FeatureKey.featureIdentifier : kLowerCaseType,
            UIFontDescriptor.FeatureKey.typeIdentifier : kLowerCaseSmallCapsSelector
        ]

        let features = [upperCaseFeature, lowerCaseFeature]
        let additions = fontDescriptor.addingAttributes([.featureSettings: features])
        
        return UIFont(descriptor: additions, size: pointSize)
    }
}

@IBDesignable
class SmallCapsLabel: UILabel {}

//MARK:- UILabel

struct LabelAnimateAnchorPoint {
  static let leadingCenterY         = CGPoint(x: 0, y: 0.5)
  static let trailingCenterY        = CGPoint(x: 1, y: 0.5)
  static let centerXCenterY         = CGPoint(x: 0.5, y: 0.5)
  static let leadingTop             = CGPoint(x: 0, y: 0)
}

extension UILabel {
    @IBInspectable var smallCaps: Bool {
        get {
            return true
        }
        set {
            if newValue {
                self.font = self.font.smallCaps()
            }
        }
    }
    @IBInspectable var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            } else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
        
        get {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            } else {
                return 0
            }
        }
    }
    
    func setFontSize(_ fontSize: CGFloat, animated: Bool = false, duration: Double = 0.3, animateAnchorPoint: CGPoint = LabelAnimateAnchorPoint.leadingCenterY) {
        guard animated else {
            self.font = self.font.withSize(fontSize)
            return
        }
        
        self.setAnchorPoint(anchorPoint: animateAnchorPoint)
        
        let startTransform = transform
        let oldFrame = frame
        var newFrame = oldFrame
        let scaleRatio = fontSize / font.pointSize
        
        newFrame.size.width *= scaleRatio
        newFrame.size.height *= scaleRatio
        newFrame.origin.x = oldFrame.origin.x - (newFrame.size.width - oldFrame.size.width) * animateAnchorPoint.x
        newFrame.origin.y = oldFrame.origin.y - (newFrame.size.height - oldFrame.size.height) * animateAnchorPoint.y
        frame = newFrame
        
        font = font.withSize(fontSize)
        
        transform = CGAffineTransform.init(scaleX: 1 / scaleRatio, y: 1 / scaleRatio);
        layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.transform = startTransform
            newFrame = self.frame
        }) { _ in
            self.frame = newFrame
        }
    }
}

//MARK:- UIImage
public extension UIImage {
    convenience init? (color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//MARK:- UIColor
extension UIColor {
    static var systemBackgroundCompat: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    
    static var labelCompat: UIColor {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }
}

//MARK:- Double
extension Double {
    var asPriceString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return "₱\(numberFormatter.string(from: NSNumber(value: self))!)"
    }
}

//MARK:- CGFloat
extension CGFloat {
    
    func normalize(min: CGFloat, max: CGFloat, from a: CGFloat = 0, to b: CGFloat = 1) -> CGFloat {
        return (b - a) * ((self - min) / (max - min)) + a
    }
    
}

//MARK:- String
extension String {
    func stripPrice() -> String {
        if let range = self.range(of: " ₱") {
            return String(self[..<range.lowerBound])
        }
        return self
    }
    
    func getPrice() -> Double? {
        if let range = self.range(of: "₱") {
            return Double(self[range.upperBound...])!
        }
        return nil
    }
    
    func chompLast(_ charactersToChomp: Int = 1) -> String {
        let endIndex = self.index(self.endIndex, offsetBy: -charactersToChomp)
        return String(self[..<endIndex])
    }
    
    func chompAt(_ characterToChompAt: String) -> String {
        if let range = self.range(of: characterToChompAt) {
            return String(self[..<range.lowerBound])
        } else {
            return self
        }
    }
}

@IBDesignable
class DesignableView: UIView {
}
//MARK:- UIView
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    func setAnchorPoint(anchorPoint: CGPoint) {
        self.translatesAutoresizingMaskIntoConstraints = true
        let oldOrigin = self.frame.origin
        self.layer.anchorPoint = anchorPoint
        let newOrigin = self.frame.origin
        
        let transition = CGPoint(x: newOrigin.x - oldOrigin.x, y: newOrigin.y - oldOrigin.y)
        self.center = CGPoint(x: self.center.x - transition.x, y: self.center.y - transition.y)
    }
    
    func addSubviewAndFill(_ subView: UIView) {
        self.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subView.topAnchor.constraint(equalTo: self.topAnchor),
            subView.leftAnchor.constraint(equalTo: self.leftAnchor),
            subView.rightAnchor.constraint(equalTo: self.rightAnchor),
            subView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    enum UIViewFadeStyle {
        case bottom
        case top
        case left
        case right
        
        case vertical
        case horizontal
    }
    
    func fadeView(style: UIViewFadeStyle = .bottom, percentage: Double = 0.07) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        
        let startLocation = percentage
        let endLocation = 1 - percentage
        
        switch style {
        case .bottom:
            gradient.startPoint = CGPoint(x: 0.5, y: endLocation)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .top:
            gradient.startPoint = CGPoint(x: 0.5, y: startLocation)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        case .vertical:
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, startLocation, endLocation, 1.0] as [NSNumber]
            
        case .left:
            gradient.startPoint = CGPoint(x: startLocation, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
        case .right:
            gradient.startPoint = CGPoint(x: endLocation, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, startLocation, endLocation, 1.0] as [NSNumber]
        }
        
        layer.mask = gradient
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
