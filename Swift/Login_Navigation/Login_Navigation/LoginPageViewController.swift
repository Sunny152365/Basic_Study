//
//  LoginViewController.swift
//  Login_basic_id_pw
//
//  Created by 최원일 on 5/7/25.
//

import UIKit
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser

struct LoginResponse: Decodable {
    let success: Bool
    let token: String
    let refresh: String
}

class LoginPageViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var appleLoginContainerView: UIView!
    @IBOutlet weak var kakaoLoginView: UIView!
    @IBOutlet weak var naverLoginView: UIView!

    private var kakaoImageView: UIImageView?
    private var naverAuthSession: ASWebAuthenticationSession?
    private var isNaverLoginInProgress = false

    private let naverClientID = "_3lM5JlNiGaw3TTgWDa3"
    // ngrok 주소 사용해야함
    private let naverRedirectURI = "https://9fe0-182-224-45-138.ngrok-free.app/api/naver/callback/"
    private let naverCallbackScheme = "naver_3lM5JlNiGaw3TTgWDa3"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginButton()
        setupNaverLoginView()
        setupKakaoLoginView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupKakaoImageIfNeeded()
    }

    private func setupNaverLoginView() {
        let naverImageView = UIImageView(image: UIImage(named: "naver_login"))
        naverImageView.contentMode = .scaleAspectFit
        naverImageView.frame = naverLoginView.bounds
        naverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverImageView.isUserInteractionEnabled = true
        naverLoginView.addSubview(naverImageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(naverLoginViewTapped))
        naverImageView.addGestureRecognizer(tapGesture)
    }

    private func setupKakaoLoginView() {
        let kakaoTapGesture = UITapGestureRecognizer(target: self, action: #selector(kakaoLoginViewTapped))
        kakaoLoginView.addGestureRecognizer(kakaoTapGesture)
        kakaoLoginView.isUserInteractionEnabled = true
    }

    private func setupKakaoImageIfNeeded() {
        if kakaoImageView == nil {
            let imageView = UIImageView(image: UIImage(named: "kakao_login"))
            imageView.contentMode = .scaleToFill
            imageView.frame = kakaoLoginView.bounds
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.clipsToBounds = true
            kakaoLoginView.addSubview(imageView)
            kakaoImageView = imageView
        }
    }

    private func setupAppleLoginButton() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.frame = appleLoginContainerView.bounds
        appleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        appleButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        appleLoginContainerView.addSubview(appleButton)
    }

    @IBAction func loginButtonTapped(_ sender: UIView) {
        let email = idTextField.text ?? ""
        let password = pwTextField.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "이메일과 비밀번호를 모두 입력하세요.")
            return
        }

        let url = URL(string: "http://192.168.0.16:8000/api/login/")!
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

    @objc func kakaoLoginViewTapped() {
        let completion: (OAuthToken?, Error?) -> Void = { token, error in
            if let error = error {
                print("카카오 로그인 실패: \(error.localizedDescription)")
            } else if let token = token {
                self.loginWithKakaoAccessToken(token.accessToken)
            }
        }

        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk(completion: completion)
        } else {
            UserApi.shared.loginWithKakaoAccount(completion: completion)
        }
    }

    func loginWithKakaoAccessToken(_ accessToken: String) {
        let url = URL(string: "http://192.168.0.16:8000/api/login/kakao/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("❌ 카카오 로그인 응답 없음")
                return
            }
            
            // 🧪 서버 응답 확인
               print("📦 서버 응답: ", String(data: data, encoding: .utf8) ?? "응답 디코딩 실패")
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(LoginResponse.self, from: data)
                UserDefaults.standard.set(response.token, forKey: "access_token")
                UserDefaults.standard.set(response.refresh, forKey: "refresh_token")
                DispatchQueue.main.async {
                    self.navigateToMainScreen()
                }
            } catch {
                print("❌ 카카오 로그인 JSON 파싱 오류: \(error.localizedDescription)")
            }
        }.resume()
    }

    @objc func naverLoginViewTapped() {
        guard !isNaverLoginInProgress else { return }
        isNaverLoginInProgress = true

        let state = UUID().uuidString
        let authURLString = "https://nid.naver.com/oauth2.0/authorize" +
            "?response_type=code" +
            "&client_id=\(naverClientID)" +
            "&redirect_uri=\(naverRedirectURI)" +
            "&state=\(state)"

        guard let authURL = URL(string: authURLString) else {
            isNaverLoginInProgress = false
            return
        }

        naverAuthSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: naverCallbackScheme) { [weak self] callbackURL, error in
            guard let self = self else { return }
            self.isNaverLoginInProgress = false

            if let error = error {
                print("❌ 네이버 로그인 에러:", error.localizedDescription)
                self.showAlert(title: "로그인 실패", message: "네이버 로그인 중 오류가 발생했습니다.")
                return
            }

            guard let callbackURL = callbackURL else {
                print("❌ 콜백 URL이 없습니다.")
                self.showAlert(title: "로그인 실패", message: "콜백 URL이 없습니다.")
                return
            }

            print("🟢 네이버 로그인 콜백 URL: \(callbackURL.absoluteString)")

            if let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) {
                print("쿼리 파라미터:")
                components.queryItems?.forEach { item in
                    print(" - \(item.name): \(item.value ?? "nil")")
                }

                if let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
                   let stateReceived = components.queryItems?.first(where: { $0.name == "state" })?.value {
                    print("✅ code: \(code), state: \(stateReceived)")
                    self.fetchNaverToken(withCode: code, state: stateReceived)
                } else {
                    print("❌ code 또는 state 파라미터 누락")
                    self.showAlert(title: "로그인 실패", message: "인증 정보(code 또는 state)가 없습니다.")
                }
            } else {
                print("❌ 콜백 URL 파싱 실패")
                self.showAlert(title: "로그인 실패", message: "콜백 URL을 파싱하지 못했습니다.")
            }
        }

        naverAuthSession?.presentationContextProvider = self
        naverAuthSession?.prefersEphemeralWebBrowserSession = true
        naverAuthSession?.start()
    }

    private func fetchNaverToken(withCode code: String, state: String) {
        let tokenURL = URL(string: "https://9fe0-182-224-45-138.ngrok-free.app/api/naver/token/")!
        // let tokenURL = URL(string: "http://192.168.0.16:8000/api/naver/token/")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["code": code, "state": state]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "서버 응답 없음")
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(LoginResponse.self, from: data)
                UserDefaults.standard.set(response.token, forKey: "access_token")
                UserDefaults.standard.set(response.refresh, forKey: "refresh_token")
                DispatchQueue.main.async {
                    self.navigateToMainScreen()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "응답 파싱 오류")
                }
            }
        }.resume()
    }

    private func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MyPageAfterLoginViewController")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
        }
    }

    private func saveResponseToFile(_ data: Data) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent("loginResponse.json")
        try? data.write(to: fileURL)
    }

    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }

    @objc func handleAppleLogin() {
        // 애플 로그인 처리 필요 시 구현
    }
    
    @IBAction func BackButton2(_ sender: UIButton) {
        // 현재 뷰에서, 이전 뷰로 돌아가고 싶을 때
        self.navigationController?.popViewController(animated: true)
    }
}

extension LoginPageViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
