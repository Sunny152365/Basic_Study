//  ViewController.swift
//  Login_basic_id_pw
//
//  Created by 최원일 on 5/7/25.

import UIKit
// Apple 로그인 관련 프레임워크
import AuthenticationServices
// 네이버 로그인 SDK
import NaverThirdPartyLogin
// 카카오 로그인
import KakaoSDKUser

class LoginViewController: UIViewController, NaverThirdPartyLoginConnectionDelegate {

    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
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

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = idTextField.text ?? ""
        let password = pwTextField.text ?? ""

        let url = URL(string: "http://127.0.0.1:8000/api/login/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("로그인 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool, success == true else {
                print("로그인 실패 또는 응답 파싱 오류")
                return
            }

            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                    self.navigationController?.pushViewController(myPageVC, animated: true)
                }
            }
        }.resume()
    }

    // MARK: - 카카오 로그인
    @IBAction func kakaoLoginButtonTapped(_ sender: UIButton) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 실패: \(error.localizedDescription)")
                } else if let token = oauthToken {
                    print("Access Token: \(token.accessToken)")
                    self.loginWithKakaoAccessToken(token.accessToken)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오계정 로그인 실패: \(error.localizedDescription)")
                } else if let token = oauthToken {
                    print("Access Token: \(token.accessToken)")
                    self.loginWithKakaoAccessToken(token.accessToken)
                }
            }
        }
    }

    func loginWithKakaoAccessToken(_ accessToken: String) {
        let url = URL(string: "http://127.0.0.1:8000/api/kakao/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["accessToken": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("카카오 백엔드 통신 오류: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool, success == true else {
                print("카카오 로그인 실패")
                return
            }

            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                    self.navigationController?.pushViewController(myPageVC, animated: true)
                }
            }
        }.resume()
    }

    // MARK: - 네이버 로그인
    @IBAction func naverLoginButtonTapped(_ sender: UIButton) {
        naverLoginInstance?.requestThirdPartyLogin()
    }

    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        if let accessToken = naverLoginInstance?.accessToken {
            print("네이버 액세스 토큰: \(accessToken)")
            loginWithNaverAccessToken(accessToken)
        }
    }

    func loginWithNaverAccessToken(_ accessToken: String) {
        let url = URL(string: "http://127.0.0.1:8000/api/naver/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["accessToken": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네이버 백엔드 통신 오류: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool, success == true else {
                print("네이버 로그인 실패")
                return
            }

            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                    self.navigationController?.pushViewController(myPageVC, animated: true)
                }
            }
        }.resume()
    }

    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {}
    func oauth20ConnectionDidFinishDeleteToken() {}
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("네이버 로그인 실패: \(error.localizedDescription)")
    }

    // MARK: - Apple 로그인
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
    }

    @IBAction func BackButton2(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
