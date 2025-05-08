//
//  ViewController.swift
//  ImageViewer
//
//  Created by 최원일 on 5/1/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    // 이미지 배열 (Assets에 이미지들을 등록해두세요: image1, image2, image3 ...)
    let images = ["1.jpg", "2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg","8.jpg","9.jpg","10.jpg"]
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateImage()
    }

    // 이미지 업데이트 함수
    func updateImage() {
        let imageName = images[currentIndex]
        imageView.image = UIImage(named: imageName)
    }

    // 다음 이미지
    @IBAction func nextImage(_ sender: UIButton) {
        currentIndex = (currentIndex + 1) % images.count
        updateImage()
    }

    // 이전 이미지
    @IBAction func previousImage(_ sender: UIButton) {
        currentIndex = (currentIndex - 1 + images.count) % images.count
        updateImage()
    }
}

