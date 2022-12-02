//
//  ChatContainer.swift
//  iOS Chat SDK Integration Example
//
//  Created by Ilya Sokolov on 02.12.2022.
//

import UIKit
import ChatSDK

class ChatContainer: UIViewController, NChatSDKToolbar {

    var chatViewController: UIViewController!
    
    var titleView = ImageTitleView()
    
    var avatarButton = AvatarButton()
    
    init(with controller: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.chatViewController = controller
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    fileprivate func setupView() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        
        addChild(chatViewController)
        view.addSubview(chatViewController.view)
        
        setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        chatViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chatViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            chatViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    public func setOperatorName(name: String?) {
        titleView.title = name
        navigationItem.titleView = titleView
    }
    
    public func setOperatorType(type: String?) {
        titleView.detail = ""
        navigationItem.titleView = titleView
    }
    
    public func setOperatorTypingText(_ text: String?) {
        titleView.detail = text
        navigationItem.titleView = titleView
    }
    
    public func hidenOperatorTypingLabel(_ value: Bool) {
        titleView.operatorTypingLabel.isHidden = value
        navigationItem.titleView = titleView
    }
    
    public func setOperatorTypingTheme(textColor: UIColor, font: UIFont?) {
        titleView.operatorTextColor = textColor
        titleView.operatorTextFont = font
        navigationItem.titleView = titleView
    }
    
    public func setOperatorAvatar(avatar: UIImage?) {
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerItem.width = -12
        
        let avatarItem = UIBarButtonItem(customView: avatarButton)
        
        navigationItem.leftBarButtonItems = [spacerItem, avatarItem]
        
        self.avatarButton.setImage(avatar, for: .normal)
    }
    
    public func showRouteToOperatorButton(with text: String) {}
    
    public func hideRouteToOperatorButton() {}
    
    public func routeToOperatorButton() -> UIView { return UIButton() }

}
