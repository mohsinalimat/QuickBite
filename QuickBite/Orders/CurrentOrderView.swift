//
//  CurrentOrderView.swift
//  QuickBite
//
//  Created by Griffin Smalley on 9/23/19.
//  Copyright © 2019 GriffSoft. All rights reserved.
//

import UIKit
import BEMCheckBox
import GTProgressBar

protocol CurrentOrderViewDelegate {
    func viewPastOrdersTapped()
    func contactUsTapped()
}

class CurrentOrderView: UIView {
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var progressView: GTProgressBar!
    @IBOutlet weak var checkboxStackView: UIStackView!
    
    // Progress Titles & Subtitles
    @IBOutlet weak var orderSubmittedTitle: UILabel!
    @IBOutlet weak var orderSubmittedSubtitle: UILabel!
    @IBOutlet weak var beingPreparedByStoreTitle: UILabel!
    @IBOutlet weak var beingPreparedByStoreSubtitle: UILabel!
    @IBOutlet weak var orderOnItsWayTitle: UILabel!
    @IBOutlet weak var orderOnItsWaySubtitle: UILabel!
    @IBOutlet weak var foodDeliveredTitle: UILabel!
    @IBOutlet weak var foodDeliveredSubtitle: UILabel!
    
    private var titles: [UILabel]!
    private var subtitles: [UILabel]!
    
    private var animationDuration: Double = 0.3
    
    let startFontSize: CGFloat = 19
    let endFontSize: CGFloat = 24
    
//    var textLayer: VerticallyCenteredTextLayer!
    
    enum OrderProgressStage: Int {
        case orderSubmitted
        case beingPreparedByStore
        case onItsWay
        case delivered
    }
    
    private var currentStage: OrderProgressStage = .orderSubmitted
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CurrentOrderView", owner: self, options: nil)
        addSubviewAndFill(masterView)
        
        titles = [orderSubmittedTitle, beingPreparedByStoreTitle, orderOnItsWayTitle, foodDeliveredTitle]
        subtitles = [orderSubmittedSubtitle, beingPreparedByStoreSubtitle, orderOnItsWaySubtitle, foodDeliveredSubtitle]
        
//        textLayer = VerticallyCenteredTextLayer()
//        textLayer.string = "Order Submitted"
//        textLayer.font = UIFont.systemFont(ofSize: startFontSize, weight: .semibold)
//        textLayer.fontSize = startFontSize
//        textLayer.foregroundColor = UIColor.black.cgColor
//        textLayer.contentsScale = UIScreen.main.scale //for some reason CATextLayer by default only works for 1x screen resolution and needs this line to work properly on 2x, 3x, etc. ...
//        textLayer.frame = orderSubmittedTitleContainer.bounds
//        orderSubmittedTitleContainer.layer.addSublayer(textLayer)
    }
    
    func setProgressStage(_ newStage: OrderProgressStage) {
        if (newStage.rawValue - currentStage.rawValue) > 1 {
            // We're jumping multiple stages. Set all enabled except for the last,
            // which will be animated
            catchUpCheckboxes(newStage)
            catchUpTitlesAndSubtitles(newStage)
            
        }
        advanceProgressBar(newStage)
    }
    
    private func advanceProgressBar(_ newStage: OrderProgressStage) {
        var progress: CGFloat = 0.0
        switch newStage {
        case .orderSubmitted:
            break // Never reached
        case .beingPreparedByStore:
            progress = 0.33
        case .onItsWay:
            progress = 0.66
        case .delivered:
            progress = 1
        }
        
        let previousTitle = titles[newStage.rawValue - 1]
        previousTitle.setFontSize(19.0, animated: true)
        previousTitle.textColor = .labelCompat
        
        let previousSubtitle = subtitles[newStage.rawValue - 1]
        UIView.animate(withDuration: animationDuration) {
            previousSubtitle.alpha = 0
        }
        
        progressView.animateTo(progress: progress) {
            self.animateCurrentStage(stage: newStage)
        }
    }
    
    // Called if we're advancing more than 1 stage
    private func catchUpCheckboxes(_ newStage: OrderProgressStage) {
        // If we're jumping multiple stages, quickly set all but the new current stage
        // (forStage), then wait until the progress bar animation completes before
        // enabling the last checkbox
        // We're jumping multiple stages
        for tag in currentStage.rawValue...newStage.rawValue - 1 {
            let checkbox = checkboxStackView.viewWithTag(tag)! as! BEMCheckBox
            checkbox.setOn(true, animated: false)
        }
    }
    
    // Called if we're advancing more than 1 stage
    private func catchUpTitlesAndSubtitles(_ newStage: OrderProgressStage) {
        for index in currentStage.rawValue...newStage.rawValue - 2 {
            // All titles in this loop are completed, so mark them as such
            let title = titles[index]
            title.textColor = .labelCompat
            title.setFontSize(19.0, animated: true)
            
            let subtitle = subtitles[index]
            showSubtitle(subtitle, show: false, duration: 0.1)
        }
    }
    
    
    // FIXME: The current method of animating the stage titles results in a constraint error
    // when a title is shrunk back to normal size (19 points). This occurs because, in order for
    // a title view to shrink and grow from the left side (as opposed to shrinking and growing
    // from the center), the title layer's anchorPoint property must be changed to the left side.
    // By default, doing this will cause the whole view to be pushed to the right. To prevent this,
    // the title's translatesAutoResizingMaskIntoConstraints poperty must be set to true. This property
    // being set to true is what causes the constraint error. Should replace with a CAText thing animation.
    
    // Called after the progress bar is done animating
    private func animateCurrentStage(stage: OrderProgressStage) {
        // set checkbox to true for newStage
        let checkbox = checkboxStackView.viewWithTag(stage.rawValue)! as! BEMCheckBox
        checkbox.setOn(true, animated: true)
        
        let title = titles[stage.rawValue]
        title.setFontSize(24.0, animated: true)
        title.textColor = .labelCompat
        
        let subtitle = subtitles[stage.rawValue]
        showSubtitle(subtitle)
    }
    
    private func showSubtitle(_ subtitle: UILabel, show: Bool = true, duration: Double = 0.3) {
        UIView.animate(withDuration: animationDuration, delay: 0.3, options: [.curveEaseInOut], animations: {
            subtitle.alpha = show ? 1 : 0
        })
    }
    
    @IBAction func contactUsTapped(_ sender: Any) {
//        setProgressStage(.onItsWay)
        
        
        //animation:
//        let duration: TimeInterval = 0.3
//        textLayer.fontSize = endFontSize //because upon completion of the animation CABasicAnimation resets the animated CALayer to its original state (as opposed to changing its properties to the end state of the animation), setting fontSize to endFontSize right BEFORE the animation starts ensures the fontSize doesn't jump back right after the animation.
//        let fontSizeAnimation = CABasicAnimation(keyPath: "fontSize")
//        fontSizeAnimation.fromValue = startFontSize
//        fontSizeAnimation.toValue = endFontSize
//        fontSizeAnimation.duration = duration
//        fontSizeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        textLayer.add(fontSizeAnimation, forKey: nil)
    }
}

//class VerticallyCenteredTextLayer: CATextLayer {
//
//    // REF: http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
//    // CREDIT: David Hoerl - https://github.com/dhoerl
//    // USAGE: To fix the vertical alignment issue that currently exists within the CATextLayer class. Change made to the yDiff calculation.
//
//
//    override func draw(in context: CGContext) {
//        let height = self.bounds.size.height
//        let fontSize = self.fontSize
//        let yDiff = (height-fontSize)/2 - fontSize/10
//
//        context.saveGState()
//        context.translateBy(x: 0, y: yDiff) // Use -yDiff when in non-flipped coordinates (like macOS's default)
//        super.draw(in: context)
//        context.restoreGState()
//    }
//}
