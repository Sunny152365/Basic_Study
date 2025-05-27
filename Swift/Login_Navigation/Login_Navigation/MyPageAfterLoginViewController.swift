//
//  ViewController.swift
//  Login_Navigation
//
//  Created by 최원일 on 5/27/25.
//

import UIKit

class MyPageAfterLoginViewController: UIViewController {

    /// 기본적으로 생기는 네비게이션 왼쪽 아이템 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }


}

