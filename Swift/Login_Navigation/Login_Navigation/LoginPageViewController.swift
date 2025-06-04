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
    var kakaoImageView: UIImageView?
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var appleLoginContainerView: UIView!
    @IBOutlet weak var kakaoLoginView: UIView!
    @IBOutlet weak var naverLoginView: UIView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginButton()
        naverLoginInstance?.delegate = self
        // 인앱 브라우저에서 로그인 시도
        naverLoginInstance?.isInAppOauthEnable = true
        
        // ✅ 네이버 로그인 이미지 설정
        let naverImageView = UIImageView(image: UIImage(named: "naver_login"))
        naverImageView.contentMode = .scaleAspectFit
        naverImageView.frame = naverLoginView.bounds
        naverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverImageView.clipsToBounds = true
        naverLoginView.addSubview(naverImageView)

        // ✅ naver 탭 제스처 추가
        let naverTapGesture = UITapGestureRecognizer(target: self, action: #selector(naverLoginButtonTapped))
        naverLoginView.addGestureRecognizer(naverTapGesture)
        naverLoginView.isUserInteractionEnabled = true
        // ✅ kakao 탭 제스처 추가
        let kakaoTapGesture = UITapGestureRecognizer(target: self, action: #selector(kakaoLoginButtonTapped))
        kakaoLoginView.addGestureRecognizer(kakaoTapGesture)
        kakaoLoginView.isUserInteractionEnabled = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if kakaoImageView == nil {
            let imageView = UIImageView(image: UIImage(named: "kakao_login"))
            // imageView.contentMode = .scaleAspectFit
            imageView.contentMode = .scaleToFill
            imageView.frame = kakaoLoginView.bounds
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.clipsToBounds = true
            kakaoLoginView.addSubview(imageView)
            kakaoImageView = imageView
        }
    }


    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    @IBAction func loginButtonTapped(_ sender: UIView) {
        let email = idTextField.text ?? ""
        let password = pwTextField.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "이메일과 비밀번호를 모두 입력하세요.")
            return
        }

        // 집
        // let url = URL(string: "http://192.168.219.120:8000/api/login/")!
        // 집 앞 스터디 카페
        let url = URL(string: "http://172.30.1.24:8000/api/login/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "서버에서 데이터를 받지 못했습니다.")
                }
                return
            }

            self.saveResponseToFile(data)
        }.resume()
    }

    @IBAction func kakaoLoginButtonTapped(_ sender: UIButton) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 실패: \(error.localizedDescription)")
                } else if let token = oauthToken {
                    self.loginWithKakaoAccessToken(token.accessToken)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오계정 로그인 실패: \(error.localizedDescription)")
                } else if let token = oauthToken {
                    self.loginWithKakaoAccessToken(token.accessToken)
                }
            }
        }
        
    }

    func loginWithKakaoAccessToken(_ accessToken: String) {
        // 집
        // let url = URL(string: "http://192.168.219.120:8000/api/kakao/token/")!
        // 172.30.1.24 집 앞 스터디 카페
        let url = URL(string: "http://172.30.1.24:8000/api/kakao/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP 상태 코드: \(httpResponse.statusCode)")
            }

            if let error = error {
                print("❌ 백엔드 통신 오류: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ 데이터 없음")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📨 응답: \(responseString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    print("✅ 토큰 획득: \(token)")
                    UserDefaults.standard.set(token, forKey: "jwtToken")

                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                            if let nav = self.navigationController {
                                nav.pushViewController(myPageVC, animated: true)
                            } else {
                                self.present(myPageVC, animated: true)
                            }
                        } else {
                            print("❌ storyboard ID 잘못됨")
                        }
                    }
                } else {
                    print("❌ JSON 파싱 오류 또는 토큰 없음")
                }
            } catch {
                print("❌ JSON 파싱 에러: \(error.localizedDescription)")
            }
        }.resume()
    }


    @IBAction func naverLoginButtonTapped(_ sender: UIView) {
        naverLoginInstance?.delegate = self
        
        naverLoginInstance?.requestThirdPartyLogin()
    }

    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        if let accessToken = naverLoginInstance?.accessToken {
            loginWithNaverAccessToken(accessToken)
        }
    }

    func loginWithNaverAccessToken(_ accessToken: String) {
        // 집
        // let url = URL(string: "http://192.168.219.120:8000/api/naver/token/")!
        // 172.30.1.24 집 앞 스터디 카페
        // let url = URL(string: "http://172.30.1.24:8000/api/naver/token/")!
        let url = URL(string: "https://954f-222-98-221-76.ngrok-free.app/api/naver/token/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ 데이터 없음")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success == true,
                       let token = json["token"] as? String {
                        print("네이버 로그인 성공! 토큰: \(token)")
                        UserDefaults.standard.set(token, forKey: "jwtToken")
                        
                        DispatchQueue.main.async {
                            // 로그인 성공 후 화면 전환 코드
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                                if let nav = self.navigationController {
                                    nav.pushViewController(myPageVC, animated: true)
                                } else {
                                    self.present(myPageVC, animated: true)
                                }
                            }
                        }
                    } else {
                        print("❌ 로그인 실패: \(json["error"] ?? "알 수 없는 오류")")
                        DispatchQueue.main.async {
                            self.showAlert(title: "로그인 실패", message: "\(json["error"] ?? "알 수 없는 오류")")
                        }
                    }
                }
            } catch {
                print("❌ JSON 파싱 실패: \(error.localizedDescription)")
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
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    @IBAction func BackButton2(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func saveResponseToFile(_ data: Data) {
        guard let responseString = String(data: data, encoding: .utf8) else {
            print("데이터 문자열 변환 실패")
            return
        }

        let fileName = "response_\(Int(Date().timeIntervalSince1970)).json"

        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)

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
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let myPageVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController") as? MyPageAfterLoginViewController {
                        if let nav = self.navigationController {
                            nav.pushViewController(myPageVC, animated: true)
                        } else {
                            self.present(myPageVC, animated: true)
                        }
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
                self.saveResponseToFile(data)
            }
        }
    }

}
