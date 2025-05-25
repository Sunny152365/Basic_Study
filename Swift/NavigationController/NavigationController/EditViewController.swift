//
//  EditViewController.swift
//  NavigationController
//
//  Created by 최원일 on 5/25/25.
//

import UIKit

// Protocol
// 특정 객체가 갖추어야 할 기능이나 속성에 대한 설계도 (단순한 선언 형태)
// 실질적인 내용은 프로토콜을 이용하는 객체에서 정의
protocol EditDelegate {
    func didMessageEditDone(_ controller: EditViewController, message: String)
    func didImageOnOffDone(_ controller: EditViewController, isOn: Bool)
}

class EditViewController: UIViewController {

    var textWayValue: String = ""
    var textMessage: String = ""
    // delegate 변수 생성
    var delegate: EditDelegate?
    // '수정화면'에서 스위치 제어하기 위해 변수 생성
    var isOn = false
    
    @IBOutlet weak var lblWay: UILabel!
    @IBOutlet weak var txMessage: UITextField!
    @IBOutlet weak var swIsOn: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        lblWay.text = textWayValue
        txMessage.text = textMessage
        swIsOn.isOn = isOn
    }
    
    @IBAction func btnDone(_ sender: UIButton) {
        // 메인화면으로 텍스트와 전구 이미지 상태 보내기
        // '수정화면'의 텍스트 필드의 내용(데이터)를 '메인화면'으로 전달
        if delegate != nil {
            delegate?.didMessageEditDone(self, message: txMessage.text!)
            // '수정화면'의 스위치 상태를 '메인화면'으로 전달
            delegate?.didImageOnOffDone(self, isOn: isOn)
        }
        // 메인화면으로 이동하기
        // 세그웨이 추가 (Action Segue)를 'Show' 형태로 했기에 되돌아갈 때는 'pop'의 형태
        _ = navigationController?.popViewController(animated: true)
    }
    
    // 전구 제어(켜고 끄기)
    @IBAction func swImageOnOff(_ sender: UISwitch) {
        if sender.isOn {
            isOn = true
        } else {
            isOn = false
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
