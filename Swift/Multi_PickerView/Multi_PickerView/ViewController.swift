//
//  ViewController.swift
//  Multi_PickerView
//
//  Created by 최원일 on 5/11/25.
//

import UIKit

// 클래스 상속 : 이후 내용은 상속
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // 배열의 최대 크기 지정
    let MAX_ARRAY_NUM = 10
    // 피커 뷰의 열의 개수
    // 라이브러리 피커 뷰를 2개를 설정할 필요 없고 개수만 2개로 설정하면 된다.
    let PICKER_VIEW_COLUMN = 2
    // 피커 뷰의 높이를 지정할 상수
    let PICKER_VIEW_HEIGHT:CGFloat = 80
    // UIImage 타입의 배열 imageArray 선언
    var imageArray = [UIImage?]()
    var imageFileName = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg", "9.jpg", "10.jpg"]

    @IBOutlet weak var pickerImage: UIPickerView!
    @IBOutlet weak var lblImageFileName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // i 값을 0에서 MAX_ARRAY_NUM보다 작을 때까지 반복
        for i in 0..<MAX_ARRAY_NUM {
            // 각 파일명에 해당하는 이미지를 생성
            let image = UIImage(named: imageFileName[i])
            // 생성된 이미지를 imageArray에 추가
            imageArray.append(image)
        }
        
        // 뷰가 로드 되었을 때 첫 번째 파일명 출력
        lblImageFileName.text = imageFileName[0]
        // 뷰가 로드되었을 때 첫 번째 이미지 출력
        imageView.image = imageArray[0]
    }
    
    // 피커 뷰의 컴포넌트 수 설정
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return PICKER_VIEW_COLUMN
    }

    // 피커 뷰의 높이 설정
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return PICKER_VIEW_HEIGHT
    }

    // 피커 뷰의 개수 설정
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return imageFileName.count
    }
    
    // 피커 뷰의 각 Row의 타이틀 설정
    //func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //    return imageFileName[row]
    //}
    
    // 피커 뷰의 각 Row의 view 설정
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let imageView = UIImageView(image: imageArray[row])
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        return imageView
    }
    
    // 피커 뷰가 선택되었을 때 실행
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // lblImageFileName.text = imageFileName[row]
        // imageView.image = imageArray[row]
        if (component == 0) {
            lblImageFileName.text = imageFileName[row]
        }
        else {
            imageView.image = imageArray[row]
        }
    }
}

// Delegate(델리게이트)
// 대리자, 누군가 해야 할 일을 대신 해주는 역할
// 특정 객체와 상호 작용할 때 메시지를 넘기면 그 메시지에 대한 책임은 델리게이트로 위임
// 사용자가 객체를 터치했을때 해야 할 일을 델리게이트 메서드에 구현하고 해당 객체가 터치되었을 때 델리게이트가 호출되어 위임받은 일을 하게 되는 것
