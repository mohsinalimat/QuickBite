//
//  Extensions.swift
//  QuickBite
//
//  Created by Griffin Smalley on 8/27/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import PMSuperButton

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
extension UIImage {
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

//MARK:- PMSuperButton
extension PMSuperButton {
    func setEnabled(_ enable: Bool, actuallyEnableOrDisable: Bool = false) {
        if enable {
            self.gradientEnabled = true
            self.gradientStartColor = #colorLiteral(red: 0.9361338615, green: 0.3251743913, blue: 0.3114004433, alpha: 1)
            self.gradientEndColor = #colorLiteral(red: 1, green: 0.3441041454, blue: 0.3272007855, alpha: 0.8)
            self.setTitleColor(.white, for: .normal)
            self.shadowOpacity = 0.25
            
            if let _ = self.imageView {
                self.tintColor = .white
            }
        } else {
            self.gradientStartColor = .tertiarySystemFillCompat
            self.gradientEndColor = .tertiarySystemFillCompat
            self.setTitleColor(.tertiaryLabelCompat, for: .normal)
            self.shadowOpacity = 0
            
            if let _ = self.imageView {
                self.tintColor = .tertiaryLabelCompat
            }
        }
        
        if actuallyEnableOrDisable {
            self.isEnabled = enable
        }
    }
}

//MARK:- UIColor
extension UIColor {
    
    func imageWithColor(width: Int = 1, height: Int = 1) -> UIImage {
        let size = CGSize(width: width, height: height)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
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
    
    static var secondaryLabelCompat: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        } else {
            return UIColor(red: 60.0, green: 60.0, blue: 67.0, alpha: 0.6)
        }
    }
    
    static var secondarySystemBackgoundCompat: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemBackground
        } else {
            return UIColor(red: 242.0, green: 242.0, blue: 247.0, alpha: 1.0)
        }
    }
    
    static var tertiaryLabelCompat: UIColor {
        if #available(iOS 13, *) {
            return .tertiaryLabel
        } else {
            return UIColor(red: 60.0, green: 60.0, blue: 67.0, alpha: 0.3)
        }
    }
    
    static var tertiarySystemFillCompat: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemFill
        } else {
            return UIColor(red: 118.0, green: 118.0, blue: 128.0, alpha: 0.12)
        }
    }
    
    static var tertiarySystemGroupedBackgroundCompat: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemGroupedBackground
        } else {
            return UIColor(red: 242.0, green: 242.0, blue: 247.0, alpha: 1.0)
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
        }
        return self
    }
    
    func chompAfter(_ characterToChompAt: String) -> String {
        if let range = self.range(of: characterToChompAt) {
            return String(self[range.upperBound...])
        }
        return self
    }
    
    var isNotEmpty: Bool {
        return self != ""
    }
    
    var gmsStreet: String? {
        if let range = self.range(of: ", Cag") {
            return String(self[..<range.lowerBound])
        }
        DDLogError("Unable to extract gmsStreet from address")
        return nil
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
    
    func hide(_ shouldHide: Bool) {
        UIView.animate(withDuration: 0.12, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.alpha = shouldHide ? 0.0 : 1.0
        })
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

// MARK: - UINavigationController
extension UINavigationController {
    func popBack(_ count: Int) {
        guard count > 0 else {
            return assertionFailure("Count can not be a negative value.")
        }
        let index = viewControllers.count - count - 1
        guard index >= 0 else {
            return assertionFailure("Not enough View Controllers on the navigation stack.")
        }
        popToViewController(viewControllers[index], animated: true)
    }
}


// MARK: - UIViewController
extension UIViewController {
    func presentInSeparateNavController(_ viewController: UIViewController, animated: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reusableNavController = storyboard.instantiateViewController(withIdentifier: "ReusableTDNavController") as! TDNavigationController
        
        reusableNavController.pushViewController(viewController, animated: false)
        
        present(reusableNavController, animated: animated, completion: nil)
    }
    
    @objc func closeSelf() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIBarButtonItem
extension UIBarButtonItem {
    static func barButton(_ target: Any?,
                           action: Selector,
                           imageName: String,
                           size: CGSize = CGSize(width: 32, height: 32),
                           tintColor: UIColor? = nil) -> UIBarButtonItem
    {
        let button = UIButton(type: .system)
//        button.tintColor = tintColor
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: size.width).isActive = true

        return menuBarItem
    }
}
