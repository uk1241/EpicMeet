//
//  Extensions.swift
//  EpicMeet
//
//  Created by R.Unnikrishnan on 18/07/23.
//

import Foundation
import UIKit

class ShadowImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        addShadow()
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        
        // Add a background color to show the shadow
        let shadowBackgroundView = UIView(frame: bounds)
        shadowBackgroundView.backgroundColor = .white
        insertSubview(shadowBackgroundView, at: 0)
    }
}

@IBDesignable
class ShadowedImageView: UIImageView {
    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            updateShadow()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            updateShadow()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            updateShadow()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 5.0 {
        didSet {
            updateShadow()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShadow()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow()
    }
    
    private func setupShadow() {
        layer.masksToBounds = false
    }
    
    private func updateShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

@IBDesignable
class ShadowButton: UIButton {
    @IBInspectable
    var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 8 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0.5 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupButton()
    }
    
    private func setupButton() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = 2.0
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
}


@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
}


@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
}
@IBDesignable
class TopBorderView: UIView {
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Drawing code
        let path = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: rect.width, y: 0)
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.lineWidth = borderWidth
        borderColor.setStroke()
        path.stroke()
    }
}
