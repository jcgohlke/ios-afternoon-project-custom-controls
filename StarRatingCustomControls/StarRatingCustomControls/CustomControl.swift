//
//  CustomControl.swift
//  StarRatingCustomControls
//
//  Created by denis cedeno on 11/21/19.
//  Copyright © 2019 DenCedeno Co. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  // "Flare view" animation sequence
  func performFlare() {
    func flare()   { transform = CGAffineTransform(scaleX: 1.6, y: 1.6) }
    func unflare() { transform = .identity }
    
    UIView.animate(withDuration: 0.3,
                   animations: { flare() },
                   completion: { _ in UIView.animate(withDuration: 0.1) { unflare() }})
  }
}
class CustomControl: UIControl {
    var value: Int = 1
    //Component characteristics:
    private let componentDimension: CGFloat = 40.0
    private let componentCount = 5
    private let componentActiveColor = UIColor.black
    private let componentInactiveColor = UIColor.gray
    private var components: [UILabel] = []
    //Auto Layout:
    override var intrinsicContentSize: CGSize {
        let componentsWidth = CGFloat(componentCount) * componentDimension
        let componentsSpacing = CGFloat(componentCount + 1) * 8.0
        let width = componentsWidth + componentsSpacing
        return CGSize(width: width, height: componentDimension)
    }
    //Initialization:
    //Custom control view set up:
    func setup() {
        backgroundColor = .clear
        frame = CGRect(origin: .zero, size: intrinsicContentSize)
        for index in 1 ... componentCount {
            //Creating label:
            let label = UILabel()
            addSubview(label)
            components.append(label)
            //Lay out label:
            let offset = CGFloat(index - 1) * componentDimension + CGFloat(index) * 8.0
            let origin = CGPoint(x: offset, y: 0)
            let componentSize = CGSize(width: componentDimension, height: componentDimension)
            label.frame = CGRect(origin: origin, size: componentSize)
            label.tag = index
            //Set Up Label:
            label.font = UIFont.boldSystemFont(ofSize: 32)
            label.text = "✮"
            label.textAlignment = .center
            switch index {
            case 1:
                label.textColor = componentActiveColor
            default:
                label.textColor = componentInactiveColor
            }
        }
    }
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        setup()
    }
    func updateValue(at touch: UITouch) {
        let oldValue = value
        let touchPoint = touch.location(in: self)
        for component in components {
            if component.frame.contains(touchPoint) && component.tag != value {
                value = component.tag
                for index in 1 ... componentCount {
                    switch index <= value {
                    case true:
                        components[index - 1].textColor = componentActiveColor
                    case false:
                        components[index - 1].textColor = componentInactiveColor
                    }
                }
                component.performFlare()
            }
        }
        if value != oldValue {
            sendActions(for: .valueChanged)
        }
    }
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(at: touch)
        return true
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        if bounds.contains(touchPoint) {
            updateValue(at: touch)
            sendActions(for: .touchDragInside)
        }else {
            sendActions(for: .touchDragOutside)
        }
        return true
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else {
            NSLog("Unable to track touch")
            return
        }
        let touchPoint = touch.location(in: self)
        if bounds.contains(touchPoint) {
            updateValue(at: touch)
            sendActions(for: .touchUpInside)
        }else {
            sendActions(for: .touchUpOutside)
        }
    }
    override func cancelTracking(with event: UIEvent?) {
        sendActions(for: .touchCancel)
    }
}
