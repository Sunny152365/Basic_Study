//
//  ViewController.swift
//  NavigationController
//
//  Created by 최원일 on 5/23/25.
//

import UIKit


// 프로토콜을 상속받으면 프로토콜에서 정의한 함수를 무조건 만들어야 함.
class ViewController: UIViewController, EditDelegate {
    
    let imgOn = UIImage(named: "lamp_on.png")
    let imgOff = UIImage(named: "lamp_off.png")
    
    // 전구가 켜져 있는지를 나타내는 변수
    var isOn = true

    @IBOutlet weak var txMessage: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 스토리보드에 추가한 이미지 뷰에 imgOn 대입
        imgView.image = imgOn
    }

    // 세그웨이 이용해 홤녀 전환
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editViewController = segue.destination as! EditViewController
        if segue.identifier == "editButton" {
            // 버튼을 클릭한경우
            editViewController.textWayValue = "segue : use button"
        } else if segue.identifier == "editBarButton" {
            // 바 버튼을 클릭한 경우
            editViewController.textWayValue = "segue : use Bar button"
        }
        // 수정홤녀으로 텍스트 메시지와 전구 상태 전달
        // '수정화면'의 textMessage에 '메인화면'의 텍스트 필드 내용이 전달
        editViewController.textMessage = txMessage.text!
        // '수정화면'의 isOn에 '메인화면'의 상태를 전달
        editViewController.isOn = isOn
        editViewController.delegate = self
    }

    // 메시지 값을 텍스트 필드에 표시
    // '수정화면'의 데이터를 '메인화면'에 전달하여 보여 주는 것
    func didMessageEditDone(_ controller: EditViewController, message: String) {
        txMessage.text = message
    }
    
    // 전구 이미지 값 세팅
    // '수정화면'의 스위치 값을 '메인화면'에 전달하여 켜진 전구 또는 꺼진 전구를 보여줌
    func didImageOnOffDone(_ controller: EditViewController, isOn: Bool) {
        if isOn {
            imgView.image = imgOn
            self.isOn = true
        } else {
            imgView.image = imgOff
            self.isOn = false
        }
    }
    
}

