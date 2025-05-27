//
//  LoginViewController.swift
//  Login_Navigation
//
//  Created by 최원일 on 5/27/25.
//

//
//  ViewController.swift
//  Login_basic_id_pw
//
//  Created by 최원일 on 5/7/25.
//

import UIKit

class LoginViewController: UIViewController {

    /// 기본적으로 생기는 네비게이션 왼쪽 아이템 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let id = idTextField.text ?? ""
        let pw = pwTextField.text ?? ""

        print("✅ loginButtonTapped 호출됨")
        if id == "test" && pw == "1234" {
            performSegue(withIdentifier: "MyPageAfterLoginViewController", sender: self)
            print("로그인 버튼 눌림")
            print("입력된 ID: \(id), PW: \(pw)")

        } else {
            let alert = UIAlertController(title: "로그인 실패", message: "아이디 또는 비밀번호가 틀렸습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func BackButton(_ sender: UIButton) {
        // 현재 뷰에서, 이전 뷰로 돌아가고 싶을 때
        self.navigationController?.popViewController(animated: true)
    }

}
