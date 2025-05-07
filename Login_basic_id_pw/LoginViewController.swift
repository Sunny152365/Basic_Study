//
//  ViewController.swift
//  Login_basic_id_pw
//
//  Created by 최원일 on 5/7/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let id = idTextField.text ?? ""
        let pw = pwTextField.text ?? ""

        if id == "test" && pw == "1234" {
            performSegue(withIdentifier: "toMain", sender: self)
        } else {
            let alert = UIAlertController(title: "로그인 실패", message: "아이디 또는 비밀번호가 틀렸습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
