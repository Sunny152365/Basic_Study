//
//  ViewController.swift
//  Map_Search
//
//  Created by 최원일 on 6/16/25.
//

import UIKit

// 1. 프로토콜과 extension 선언 (같은 파일 안에)
protocol NavigationBarHidable {
    func hideNavigationBar()
    func hideBackButton()
}

extension NavigationBarHidable where Self: UIViewController {
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func hideBackButton() {
        navigationItem.hidesBackButton = true
    }
}

// 2. DesignViewController에서 프로토콜 채택 및 사용
class DesignViewController: UIViewController, NavigationBarHidable {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideBackButton()
        hideNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
