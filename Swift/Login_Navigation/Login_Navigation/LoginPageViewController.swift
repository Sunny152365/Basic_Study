//
//  ViewController.swift
//  Login_basic_id_pw
//
//  Created by 최원일 on 5/7/25.
//

import UIKit

// Firebase
import FirebaseAuth
// Apple 로그인 관련 프레임워크
import AuthenticationServices
// 네이버 로그인 SDK
import NaverThirdPartyLogin

class LoginViewController: UIViewController, NaverThirdPartyLoginConnectionDelegate {
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    /// 기본적으로 생기는 네비게이션 왼쪽 아이템 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 뒤로가기 버튼 숨기기
        self.navigationItem.hidesBackButton = true
        // 네비게이션 바 숨기기
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var appleLoginContainerView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginButton()
        naverLoginInstance?.delegate = self
        naverLoginInstance?.isInAppOauthEnable = true
    }

        //  백엔드에서 custom token 받아와 로그인
        func loginWithNaverAccessToken(_ accessToken: String) {
            let url = URL(string: "https://your-backend.com/naver/token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = ["accessToken": accessToken]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("백엔드 통신 오류: \(error.localizedDescription)")
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let token = json["token"] as? String else {
                    print("잘못된 응답")
                    return
                }

                // 같은 클래스 내의 메서드 호출
                DispatchQueue.main.async {
                    self.loginWithCustomToken(token)
                }
            }.resume()
        }

        // Firebase에 custom token으로 로그인
        func loginWithCustomToken(_ customToken: String) {
            Auth.auth().signIn(withCustomToken: customToken) { result, error in
                if let error = error {
                    print("Firebase 로그인 실패: \(error.localizedDescription)")
                    return
                }

                if let user = result?.user {
                    print("로그인 성공 - UID: \(user.uid)")
                }
            }
        }
    

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
    
    // 네이버 로그인 파트
    @IBAction func naverLoginButtonTapped(_ sender: UIButton) {
            naverLoginInstance?.requestThirdPartyLogin()
        }

        // 로그인 성공 시 호출
        func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
            if let accessToken = naverLoginInstance?.accessToken {
                print("네이버 액세스 토큰:", accessToken)
                // 이 토큰으로 백엔드에 커스텀 토큰 요청 보내기
                loginWithNaverAccessToken(accessToken)
            }
        }

        func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {}
        func oauth20ConnectionDidFinishDeleteToken() {}
        func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
            print("네이버 로그인 실패: \(error.localizedDescription)")
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
    @IBAction func BackButton2(_ sender: UIButton) {
        // 현재 뷰에서, 이전 뷰로 돌아가고 싶을 때
        self.navigationController?.popViewController(animated: true)
    }
        
}

