//
//  ViewController.swift
//  Map_Search
//
//  Created by 최원일 on 6/16/25.
//

import UIKit

class MainSearchViewController: UIViewController, NavigationBarHidable {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideBackButton()       // 뒤로가기 버튼 숨기기
        hideNavigationBar()    // 네비게이션 바 숨기기
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 추가 설정 있으면 여기에 작성
    }
}


