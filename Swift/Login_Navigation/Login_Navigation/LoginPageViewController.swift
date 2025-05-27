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

// Apple 로그인 관련 프레임워크
import AuthenticationServices
// 네이버 로그인 SDK
import NaverThirdPartyLogin

class LoginViewController: UIViewController {
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    /// 기본적으로 생기는 네비게이션 왼쪽 아이템 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var appleLoginContainerView: UIView!
    @IBOutlet weak var naverLoginButton: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginButton()
        /*
        // 네이버 로그인 버튼 커스터마이징 예시
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNaverLogin))
        naverLoginButton.addGestureRecognizer(tapGesture)
        
        // 네이버 로그인 인스턴스 초기화
        naverLoginInstance.delegate = self
        
        // 뷰 스타일도 원하면 추가
        naverLoginButton.backgroundColor = UIColor(red: 3/255, green: 199/255, blue: 90/255, alpha: 1) // 네이버 그린
        naverLoginButton.layer.cornerRadius = 5
        */
    }
    /*
    // 네이버 로그인 파트
    @objc func handleNaverLogin() {
        print("네이버 로그인 뷰 탭됨")
        naverLoginInstance.requestThirdPartyLogin()
    }

    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("네이버 로그인 성공")
        // 토큰 받아서 처리
    }

    func oauth20ConnectionDidFailWithError(_ error: Error) {
        print("네이버 로그인 실패: \(error.localizedDescription)")
    }
     */
    // 애플 로그인 파트
    private func setupAppleLoginButton() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.frame = appleLoginContainerView.bounds
        appleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        appleButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        appleLoginContainerView.addSubview(appleButton)
    }

    @objc private func handleAppleLogin() {
        let alert = UIAlertController(title: "애플 로그인", message: "선택되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)

        // 유료 계정 없어도 여기까지는 OK
        // 이후 인증 요청은 유료 계정 있어야 작동함
    }

    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let id = idTextField.text ?? ""
        let pw = pwTextField.text ?? ""
        
        if id == "test" && pw == "1234" {
            // 250527 현재 여기서 디버그 발생
            // performSegue(withIdentifier: "MyPageAfterLoginViewController", sender: self)
            // 코드로 직접 뷰컨트롤러 인스턴스 생성 후 push (스토리보드 segue는 별개로 작동)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                self.navigationController?.pushViewController(myPageVC, animated: true)
                }
            
            } else {
                let alert = UIAlertController(title: "로그인 실패", message: "아이디 또는 비밀번호가 틀렸습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    @IBAction func BackButton(_ sender: UIButton) {
        print("Button tapped!")
        // 현재 뷰에서, 이전 뷰로 돌아가고 싶을 때
        self.navigationController?.popViewController(animated: true)
    }
        
}

