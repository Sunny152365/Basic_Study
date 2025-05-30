//
//  ViewController.swift
//  Login_basic_id_pw
//
//  Created by 최원일 on 5/7/25.
//

import UIKit
import AuthenticationServices
import NaverThirdPartyLogin
import KakaoSDKUser


struct LoginResponse: Decodable {
    let success: Bool
    let token: String
    let refresh: String
}

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
    @IBOutlet weak var kakaoLoginButton: UIButton!
    @IBOutlet weak var naverLoginButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginButton()
        naverLoginInstance?.delegate = self
        naverLoginInstance?.isInAppOauthEnable = true
        
        kakaoLoginButton.setImage(UIImage(named: "kakao_login"), for: .normal)
        naverLoginButton.setImage(UIImage(named: "naver_login"), for: .normal)
        
        // 이미지가 버튼 크기에 맞게 조정되도록 설정
        kakaoLoginButton.imageView?.contentMode = .scaleAspectFit
        naverLoginButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = idTextField.text ?? ""
        let password = pwTextField.text ?? ""
        
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "이메일과 비밀번호를 모두 입력하세요.")
            return
        }
        
        // 기존
        // let url = URL(string: "http://127.0.0.1:8000/api/login/")!
        // 변경 (예: PC IP가 192.168.0.15라면)
        // 집(경기도 평택시)
        // let url = URL(string: "http://192.168.0.16:8000/api/login/")!
        // 이디야 두정역 172.30.1.91
        let url = URL(string: "http://172.30.1.91:8000/api/login/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Not an HTTP response")
                    return
                }

                print("🔁 HTTP Status Code: \(httpResponse.statusCode)")

                guard let data = data else {
                    print("❌ No data received")
                    return
                }

                // 👇 응답을 문자열로 출력
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📨 Raw response: \(responseString)")
                }

                do {
                    let result = try JSONDecoder().decode(LoginResponse.self, from: data)
                    print("✅ Login success: \(result.token)")
                } catch {
                    print("❌ JSON decoding error: \(error)")
                }

            }.resume()

            /*
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "네트워크 오류: \(error.localizedDescription)")
                }
                return
            }
            */
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "서버에서 데이터를 받지 못했습니다.")
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    print("로그인 성공! 토큰: \(token)")
                    
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                            self.navigationController?.pushViewController(myPageVC, animated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "로그인 실패", message: "이메일 또는 비밀번호가 올바르지 않습니다.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "응답 파싱 오류")
                }
            }
        }.resume()
    }
    
    
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
        let url = URL(string: "http://172.30.1.29:8000/api/kakao/token/")!
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
            
            // 로그인 토큰 받는 곳
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let token = json["token"] as? String else {
                print("카카오 로그인 실패")
                return
            }
            
            print("카카오 로그인 성공! 토큰: \(token)")
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                    self.navigationController?.pushViewController(myPageVC, animated: true)
                }
            }
        }.resume()
    }
    
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
        let url = URL(string: "http://172.30.1.29:8000/api/naver/token/")!
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
                  let token = json["token"] as? String else {
                print("네이버 로그인 실패")
                return
            }
            
            print("네이버 로그인 성공! 토큰: \(token)")
            
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
    
    // json 파일 저장
    func saveResponseToFile(_ data: Data) {
        
        // 1. Data를 문자열로 변환
        guard let responseString = String(data: data, encoding: .utf8) else {
            print("데이터 문자열 변환 실패")
            return
        }

        // 2. 저장할 파일 이름 만들기 (시간값 포함)
        let fileName = "response_\(Int(Date().timeIntervalSince1970)).json"

        // 3. 앱의 Documents 폴더 경로 찾기
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)

            // 4. 문자열을 파일로 저장
            do {
                try responseString.write(to: fileURL, atomically: true, encoding: .utf8)
                print("✅ 응답이 파일로 저장되었습니다: \(fileURL.path)")
            } catch {
                print("❌ 응답 파일 저장 실패: \(error.localizedDescription)")
            }
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["token"] as? String {
                print("로그인 성공! 토큰: \(token)")
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(token, forKey: "jwtToken") // ✅ 실제 사용
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                        self.navigationController?.pushViewController(myPageVC, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "이메일 또는 비밀번호가 올바르지 않습니다.")
                }
            }
        } catch {
            // ❌ 자기 자신 재호출 → 무한 루프 발생 가능
            // self.saveResponseToFile(data) // ✅ 응답 저장
            DispatchQueue.main.async {
                self.showAlert(title: "로그인 실패", message: "응답 파싱 오류")
                
                // 파싱 오류 때도 서버 응답 데이터 저장 시도
                    self.saveResponseToFile(data)
            }
        }

    }

    
}
