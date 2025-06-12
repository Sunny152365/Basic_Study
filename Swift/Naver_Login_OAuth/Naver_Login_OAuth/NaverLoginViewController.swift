import UIKit
import AuthenticationServices

class NaverLoginViewController: UIViewController {

    @IBOutlet weak var naverLoginView: UIView!

    private var authSession: ASWebAuthenticationSession?
    private var isLoginInProgress = false

    private let clientID = "_3lM5JlNiGaw3TTgWDa3"
    private let clientSecret = "u4zbVlZiD7"
    private let redirectURI = "https://ed26-182-224-45-138.ngrok-free.app/api/users/naver/callback/"

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[DEBUG] viewDidLoad 호출됨 - UI 구성 시작")
        view.backgroundColor = .white

        let naverImageView = UIImageView(image: UIImage(named: "naver_login"))
        naverImageView.contentMode = .scaleAspectFit
        naverImageView.frame = naverLoginView.bounds
        naverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverImageView.clipsToBounds = true
        naverImageView.isUserInteractionEnabled = true
        naverLoginView.addSubview(naverImageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(naverLoginViewTapped))
        naverImageView.addGestureRecognizer(tapGesture)
        print("[DEBUG] 네이버 로그인 버튼 구성 완료")
    }

    @objc func naverLoginViewTapped() {
        print("[INFO] 네이버 로그인 버튼 탭됨")
        guard !isLoginInProgress else {
            print("[WARNING] 로그인 중복 요청 차단")
            return
        }
        startNaverLogin()
    }

    func startNaverLogin() {
        isLoginInProgress = true
        let state = UUID().uuidString
        print("[INFO] startNaverLogin 시작 - state 생성됨: \(state)")

        let authURLString = "https://nid.naver.com/oauth2.0/authorize" +
            "?response_type=code" +
            "&client_id=\(clientID)" +
            "&redirect_uri=\(redirectURI)" +
            "&state=\(state)"

        guard let authURL = URL(string: authURLString) else {
            print("[ERROR] 인증 URL 생성 실패")
            isLoginInProgress = false
            return
        }

        let callbackScheme = "naver_\(clientID)"
        print("[DEBUG] 인증 URL: \(authURL.absoluteString)")
        print("[DEBUG] callbackScheme: \(callbackScheme)")

        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { [weak self] callbackURL, error in
            guard let self = self else { return }
            self.isLoginInProgress = false

            if let error = error {
                print("[ERROR] 인증 중 오류 발생: \(error.localizedDescription)")
                self.showAlert(title: "로그인 실패", message: "인증 도중 오류가 발생했습니다.")
                return
            }

            guard let url = callbackURL,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                print("[ERROR] 콜백 URL 파싱 실패")
                self.showAlert(title: "로그인 실패", message: "콜백 응답 파싱에 실패했습니다.")
                return
            }

            let code = queryItems.first(where: { $0.name == "code" })?.value
            let returnedState = queryItems.first(where: { $0.name == "state" })?.value

            print("[DEBUG] 인증 응답 코드: \(code ?? "nil"), state: \(returnedState ?? "nil")")

            guard let code = code, let returnedState = returnedState, returnedState == state else {
                print("[ERROR] 인증 코드 없음 또는 state 불일치")
                self.showAlert(title: "로그인 실패", message: "인증 응답이 유효하지 않습니다.")
                return
            }

            print("[INFO] 인증 코드 확보 성공, 토큰 요청 진행")
            self.requestAccessToken(code: code, state: state)
        }

        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false

        let started = authSession?.start() ?? false
        print("[INFO] 인증 세션 시작 결과: \(started)")
    }

    private func requestAccessToken(code: String, state: String) {
        print("[INFO] requestAccessToken 호출 - code: \(code), state: \(state)")

        guard let url = URL(string: "https://nid.naver.com/oauth2.0/token") else {
            print("[ERROR] 토큰 요청 URL 생성 실패")
            return
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "state", value: state)
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        print("[DEBUG] Access Token 요청 URL: \(request.url!.absoluteString)")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }

            if let error = error {
                print("[ERROR] 토큰 요청 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "토큰 요청 오류")
                }
                return
            }

            guard let data = data else {
                print("[ERROR] 토큰 응답 데이터 없음")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "응답 데이터가 비어 있습니다.")
                }
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("[ERROR] 토큰 응답 JSON 파싱 실패")
                print(String(data: data, encoding: .utf8) ?? "[디코딩 실패]")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "토큰 파싱 실패")
                }
                return
            }

            print("[DEBUG] 토큰 응답: \(json)")

            if let accessToken = json["access_token"] as? String {
                print("[INFO] Access Token 확보 성공")
                self.sendAccessTokenToBackend(accessToken)
            } else {
                print("[ERROR] access_token 누락 또는 실패 응답: \(json)")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "Access Token이 유효하지 않습니다.")
                }
            }
        }.resume()
    }

    private func sendAccessTokenToBackend(_ accessToken: String) {
        print("[INFO] 백엔드로 Access Token 전송 시작")

        guard let url = URL(string: "https://ed26-182-224-45-138.ngrok-free.app/api/users/naver-login/") else {
            print("[ERROR] 백엔드 URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        print("[DEBUG] 전송할 요청 바디: \(body)")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("[ERROR] 백엔드 요청 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "서버 요청 오류")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[ERROR] 응답이 HTTPURLResponse가 아님")
                return
            }

            print("[INFO] 백엔드 응답 상태 코드: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("[ERROR] 응답 파싱 실패 또는 상태 코드 오류")
                print(String(data: data ?? Data(), encoding: .utf8) ?? "[디코딩 실패]")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "로그인 응답 오류")
                }
                return
            }

            print("[DEBUG] 백엔드 응답 JSON: \(json)")

            if let access = json["access"] as? String,
               let refresh = json["refresh"] as? String,
               let user = json["user"] as? [String: Any] {

                let defaults = UserDefaults.standard
                defaults.set(access, forKey: "access_token")
                defaults.set(refresh, forKey: "refresh_token")
                defaults.set(user["email"] as? String, forKey: "user_email")
                defaults.set(user["nickname"] as? String, forKey: "user_nickname")
                defaults.set(user["id"] as? Int, forKey: "user_id")

                print("[INFO] JWT 및 사용자 정보 저장 완료")
                DispatchQueue.main.async {
                    self.navigateToMainScreen()
                }
            } else {
                print("[ERROR] 응답 JSON에 필수 키 누락")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "유효하지 않은 로그인 응답")
                }
            }
        }.resume()
    }

    private func navigateToMainScreen() {
        print("[INFO] 메인 화면으로 이동 시도")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
              let window = sceneDelegate.window ?? (sceneDelegate as? SceneDelegate)?.window else {
            print("[ERROR] UIWindow 접근 실패")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "EndPageViewController")
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
        print("[INFO] 메인 화면(EndPageViewController) 전환 완료")
    }

    private func showAlert(title: String, message: String) {
        print("[ALERT] \(title): \(message)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension NaverLoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        print("[DEBUG] presentationAnchor 요청됨")
        return self.view.window ?? ASPresentationAnchor()
    }
}
