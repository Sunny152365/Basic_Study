//
//  ViewController.swift
//  PageControl
//
//  Created by 최원일 on 5/21/25.
//

import UIKit

var images = ["01.png","02.png","03.png","04.png","05.png","06.png"]

class ViewController: UIViewController {
    // 이미지 출력용 아웃렛 변수
    @IBOutlet weak var imgView: UIImageView!
    // 페이지 컨트롤용 아웃렛 변수
    @IBOutlet weak var pageControl: UIPageControl!
    
    // 뷰가 로드되었을 때 호출됨
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 페이지 컨트롤의 전체 페이지 수
        pageControl.numberOfPages = images.count
        // 현재 페이지
        pageControl.currentPage = 0
        // 페이지 컨트롤의 페이지를 표시하는 부분의 색상(전체 동그라미)
        pageControl.pageIndicatorTintColor = UIColor.green
        // 페이지 컨트롤의 현재 페이지를 표시하는 색상(현재 동그라미)
        pageControl.currentPageIndicatorTintColor = UIColor.red
        imgView.image = UIImage(named: images[0])
    }

    // 페이지가 변하면 호출됨
    @IBAction func pageChange(_ sender: UIPageControl) {
        // images라는 배열에서 pageControl이 가리키는 현재 페이지에 해당하는 이미지를 imgView에 할당
        imgView.image = UIImage(named: images[sender.currentPage])
    }
    
}

