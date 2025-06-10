import UIKit
import AuthenticationServices

class NaverLoginViewController: UIViewController {

    @IBOutlet weak var naverLoginView: UIView!

    private var authSession: ASWebAuthenticationSession?
    private var isLoginInProgress = false

    // 네이버 앱 등록 시 발급받은 클라이언트 아이디, 시크릿, 리다이렉트 URI
    private let clientID = "_3lM5JlNiGaw3TTgWDa3"
    private let clientSecret = "u4zbVlZiD7"
    // private let redirectURI = "com.mycompany.Naver-Login-OAuth"
    private let redirectURI = "naver_3lM5JlNiGaw3TTgWDa3://auth"

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[DEBUG] viewDidLoad 호출됨")
        view.backgroundColor = .white

        // 네이버 로그인 버튼 이미지뷰 생성 및 설정
        let naverImageView = UIImageView(image: UIImage(named: "naver_login"))
        naverImageView.contentMode = .scaleAspectFit
        naverImageView.frame = naverLoginView.bounds
        naverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverImageView.clipsToBounds = true
        naverImageView.isUserInteractionEnabled = true
        naverLoginView.addSubview(naverImageView)

        // 터치 제스처 등록 (로그인 시작)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(naverLoginViewTapped))
        naverImageView.addGestureRecognizer(tapGesture)
    }

    @objc func naverLoginViewTapped() {
        print("[DEBUG] 네이버 로그인 버튼 탭 감지됨")
        guard !isLoginInProgress else {
            print("[DEBUG] 로그인 진행 중이라 중복 요청 무시됨")
            return
        }
        startNaverLogin()
    }

    // 네이버 OAuth 인증 세션 시작
    func startNaverLogin() {
        isLoginInProgress = true
        let state = UUID().uuidString // CSRF 공격 방지용 state 토큰 생성
        print("[DEBUG] startNaverLogin 호출, state 생성: \(state)")

        // OAuth 인증 요청 URL 조립
        let authURLString = "https://nid.naver.com/oauth2.0/authorize" +
            "?response_type=code" +
            "&client_id=\(clientID)" +
            "&redirect_uri=\(redirectURI)" +
            "&state=\(state)"

        guard let authURL = URL(string: authURLString) else {
            print("[DEBUG] ❌ 인증 URL 생성 실패")
            isLoginInProgress = false
            return
        }
        print("[DEBUG] 인증 URL 생성 완료: \(authURL.absoluteString)")

        // 네이버 개발자 센터에 등록한 redirect URI 스킴과 반드시 일치시켜야 함
        // let callbackScheme = "com.mycompany.Naver-Login-OAuth"
        let callbackScheme = "naver_3lM5JlNiGaw3TTgWDa3"
        print("[DEBUG] ASWebAuthenticationSession 시작 직전 (callbackScheme: \(callbackScheme))")

        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { [weak self] callbackURL, error in
            guard let self = self else { return }
            self.isLoginInProgress = false

            if let error = error {
                print("[DEBUG] ❌ ASWebAuthenticationSession 에러 발생: \(error.localizedDescription)")
                self.showAlert(title: "로그인 실패", message: "인증 중 오류가 발생했습니다.")
                return
            }

            guard let url = callbackURL,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                print("[DEBUG] ❌ 콜백 URL 또는 쿼리 파싱 실패")
                self.showAlert(title: "로그인 실패", message: "인증 결과를 처리하지 못했습니다.")
                return
            }

            // 인증 코드와 state 값 추출
            let code = queryItems.first(where: { $0.name == "code" })?.value
            let returnedState = queryItems.first(where: { $0.name == "state" })?.value

            print("[DEBUG] 인증 콜백 URL 쿼리: code=\(code ?? "nil"), state=\(returnedState ?? "nil")")

            // state 값 검증
            guard let code = code,
                  let returnedState = returnedState,
                  returnedState == state else {
                print("[DEBUG] ❌ state 불일치 또는 인증 코드 없음")
                self.showAlert(title: "로그인 실패", message: "인증에 실패했습니다.")
                return
            }

            print("[DEBUG] ✅ 인증 코드 획득 성공: \(code)")
            self.requestAccessToken(code: code, state: state)
        }

        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false

        let started = authSession?.start() ?? false
        print("[DEBUG] ASWebAuthenticationSession start() 호출 완료, 성공 여부: \(started)")
    }

    // 인증 코드를 이용해 액세스 토큰 요청
    private func requestAccessToken(code: String, state: String) {
        print("[DEBUG] requestAccessToken 호출, code: \(code), state: \(state)")

        guard let url = URL(string: "https://nid.naver.com/oauth2.0/token") else {
            print("[DEBUG] ❌ 토큰 요청 URL 생성 실패")
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
                print("[DEBUG] ❌ Access Token 요청 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "토큰 요청 중 오류가 발생했습니다.")
                }
                return
            }

            guard let data = data else {
                print("[DEBUG] ❌ Access Token 응답 데이터 없음")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "토큰 응답이 없습니다.")
                }
                return
            }

            // JSON 파싱 시도
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("[DEBUG] ❌ Access Token 응답 파싱 실패")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "토큰 응답 파싱에 실패했습니다.")
                }
                return
            }

            print("[DEBUG] Access Token 응답 JSON: \(json)")

            if let accessToken = json["access_token"] as? String {
                print("[DEBUG] ✅ Access Token 획득 성공: \(accessToken)")
                self.sendAccessTokenToBackend(accessToken)
            } else {
                print("[DEBUG] ❌ Access Token 키 누락 또는 오류 응답: \(json)")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "유효하지 않은 토큰 응답입니다.")
                }
            }
        }.resume()
    }

    // 획득한 액세스 토큰을 백엔드 서버로 전송하여 JWT 등 발급 요청
    private func sendAccessTokenToBackend(_ accessToken: String) {
        print("[DEBUG] sendAccessTokenToBackend 호출, 토큰: \(accessToken)")

        guard let url = URL(string: "http://192.168.0.18:8000/api/users/naver-login/") else {
            print("[DEBUG] ❌ 백엔드 URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        print("[DEBUG] 백엔드 요청 바디: \(body)")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("[DEBUG] ❌ 백엔드 요청 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "서버 요청 중 오류가 발생했습니다.")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[DEBUG] ❌ 백엔드 응답이 HTTPURLResponse가 아님")
                return
            }
            print("[DEBUG] ✅ 백엔드 응답 상태 코드: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("[DEBUG] ❌ 로그인 실패 - 유효하지 않은 응답")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "로그인 응답 오류: \(httpResponse.statusCode)")
                }
                return
            }

            print("[DEBUG] 백엔드 응답 JSON: \(json)")

            // JWT 토큰과 사용자 정보 파싱 및 저장
            if let access = json["access"] as? String,
               let refresh = json["refresh"] as? String,
               let user = json["user"] as? [String: Any] {

                let defaults = UserDefaults.standard
                defaults.set(access, forKey: "access_token")
                defaults.set(refresh, forKey: "refresh_token")
                defaults.set(user["email"] as? String, forKey: "user_email")
                defaults.set(user["nickname"] as? String, forKey: "user_nickname")
                defaults.set(user["id"] as? Int, forKey: "user_id")

                print("[DEBUG] ✅ JWT 및 사용자 정보 UserDefaults 저장 완료")

                DispatchQueue.main.async {
                    self.navigateToMainScreen()
                }
            } else {
                print("[DEBUG] ❌ 로그인 응답에 필요한 키 누락")
                DispatchQueue.main.async {
                    self.showAlert(title: "로그인 실패", message: "유효하지 않은 로그인 응답입니다.")
                }
            }
        }.resume()
    }

    // 로그인 성공 후 메인 화면으로 이동 처리
    private func navigateToMainScreen() {
        print("[DEBUG] navigateToMainScreen 호출")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
              let window = sceneDelegate.window ?? (sceneDelegate as? SceneDelegate)?.window else {
            print("[DEBUG] ❌ UIWindow 접근 실패")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "EndPageViewController")
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
        print("[DEBUG] ✅ 메인 화면(EndPageViewController)으로 전환 완료")
    }

    // 경고창 표시 함수
    private func showAlert(title: String, message: String) {
        print("[DEBUG] showAlert 호출 - \(title): \(message)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// ASWebAuthenticationSession의 presentationContextProvider 구현
extension NaverLoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
