//
//  AvatarButton.swift
//  iOS Chat SDK Integration Example
//
//  Created by Ilya Sokolov on 02.12.2022.
//

import UIKit

class AvatarButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        regularLayout()
        
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.verticalSizeClass == .compact {
            compactLayout()
        } else {
            regularLayout()
        }
    }
    
    private func regularLayout() {
        widthAnchor.constraint(equalToConstant: 37).isActive = true
        heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        layer.cornerRadius = 37 / 2
    }
    
    private func compactLayout() {
        widthAnchor.constraint(equalToConstant: 28).isActive = true
        heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        layer.cornerRadius = 28 / 2
    }
    
}
