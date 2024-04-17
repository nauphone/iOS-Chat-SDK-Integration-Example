//
//  ImageTitleView.swift
//  iOS Chat SDK Integration Example
//
//  Created by Ilya Sokolov on 02.12.2022.
//

import UIKit

class ImageTitleView: UIView {
    
    var title: String? {
        set {
            if titleLabel.text != newValue {
                titleLabel.text = newValue
                updateLayouts()
            }
        }
        get {
            return titleLabel.text
        }
    }
    var detail: String? {
        set {
            if detailLabel.text != newValue {
                detailLabel.text = newValue
                updateLayouts()
            }
        }
        get {
            return detailLabel.text
        }
    }
    
    var operatorTyping: String? {
        set {
            if detailLabel.text != newValue {
                detailLabel.text = newValue
                updateLayouts()
            }
        }
        get {
            return operatorTypingLabel.text
        }
    }
    
    var operatorTextColor: UIColor? {
        set {
            if detailLabel.textColor != newValue {
                detailLabel.textColor = newValue
                updateLayouts()
            }
        }
        get {
            return operatorTypingLabel.textColor
        }
    }
    
    var operatorTextFont: UIFont? {
        set {
            if detailLabel.font != newValue {
                operatorTypingLabel.font = newValue
                updateLayouts()
            }
        }
        get {
            return operatorTypingLabel.font
        }
    }
    
    private var titleLabel = UILabel()
    private var detailLabel = UILabel()
    var operatorTypingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.text = ""
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        detailLabel.text = ""
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = .red
        detailLabel.textAlignment = .center
        addSubview(detailLabel)
        
        setupOperatorTypingLabel()
        
        updateLayouts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateLayouts()
    }
    
    private func updateLayouts() {
        if self.traitCollection.verticalSizeClass == .compact {
            setupCompactLayouts()
        } else {
            setupRegularLayouts()
        }
    }
    
    private let unlimitSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    
    private func setupOperatorTypingLabel() {
        operatorTypingLabel.text = " "
        operatorTypingLabel.font = UIFont.systemFont(ofSize: 12)
        operatorTypingLabel.textColor = .red
        operatorTypingLabel.textAlignment = .center
        operatorTypingLabel.sizeToFit()
        addSubview(operatorTypingLabel)
              
        operatorTypingLabel.center.x = self.titleLabel.center.x + 30
        operatorTypingLabel.frame = CGRect(x: operatorTypingLabel.frame.minX, y: self.frame.maxY - 20, width: operatorTypingLabel.frame.width, height: operatorTypingLabel.frame.height)
        
        updateLayouts()
    }
    
    private func setupRegularLayouts() {
        let titleLabelSize = titleLabel.sizeThatFits(unlimitSize)
        let detailLabelSize = detailLabel.sizeThatFits(unlimitSize)
        
        let titleViewWidth = min(UIDevice.isOldIPhoneSE ? 150 : 200, max(titleLabelSize.width, detailLabelSize.width))
        let titleViewHeight = CGFloat(44)
        frame = CGRect(x: 0, y: 0, width: titleViewWidth, height: titleViewHeight)
        
        let titleLabelY = CGFloat(4)
        titleLabel.frame = CGRect(x: 0, y: titleLabelY, width: titleViewWidth, height: titleLabelSize.height)
        
        let detailLabelY = titleViewHeight - 4 - detailLabelSize.height
        detailLabel.frame = CGRect(x: 0, y: detailLabelY, width: titleViewWidth, height: detailLabelSize.height)
    }
    
    private func setupCompactLayouts() {
        let titleLabelSize = titleLabel.sizeThatFits(unlimitSize)
        let detailLabelSize = detailLabel.sizeThatFits(unlimitSize)
        
        let titleViewWidth = min(UIDevice.isOldIPhoneSE ? 300 : 350, titleLabelSize.width + 8 + detailLabelSize.width)
        let titleViewHeight = CGFloat(40)
        frame = CGRect(x: 0, y: 0, width: titleViewWidth, height: titleViewHeight)
        
        let titleLabelX = CGFloat(0)
        let titleLabelY = titleViewHeight/2 - titleLabelSize.height/2
        titleLabel.frame = CGRect(x: CGFloat(titleLabelX), y: titleLabelY, width: titleLabelSize.width, height: titleLabelSize.height)
        
        let detailLabelX = titleViewWidth - detailLabelSize.width
        let detailLabelY = titleViewHeight/2 - detailLabelSize.height/2
        detailLabel.frame = CGRect(x: detailLabelX, y: detailLabelY, width: detailLabelSize.width, height: detailLabelSize.height)
    }
}
