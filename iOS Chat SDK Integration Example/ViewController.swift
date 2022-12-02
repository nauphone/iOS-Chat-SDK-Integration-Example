//
//  ViewController.swift
//  iOS Chat SDK Integration Example
//
//  Created by Ilya Sokolov on 25.11.2022.
//

import UIKit
import ChatSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let chatView = appDelegate.chatSDKService!.chatView()
        let chatController = ChatContainer(with: chatView)
        
        navigationController?.pushViewController(chatController, animated: true)
    }

}

