import UIKit
import AuthenticationServices

class NaverLoginViewController: UIViewController {
    
    @IBOutlet weak var naverLoginView: UIView!
    
    private var authSession: ASWebAuthenticationSession?
    private var isLoginInProgress = false

    private let clientID = "_3lM5JlNiGaw3TTgWDa3"
    private let redirectURI = "https://1977-222-98-221-76.ngrok-free.app/api/naver/callback/"
    private let callbackScheme = "naver_3lM5JlNiGaw3TTgWDa3"  // 기존 코드에 맞춤

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let naverImageView = UIImageView(image: UIImage(named: "naver_login"))
        naverImageView.contentMode = .scaleAspectFit
        naverImageView.frame = naverLoginView.bounds
        naverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverImageView.isUserInteractionEnabled = true
        naverLoginView.addSubview(naverImageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(naverLoginViewTapped))
        naverImageView.addGestureRecognizer(tapGesture)
    }

    @objc func naverLoginViewTapped() {
        guard !isLoginInProgress else {
            print("[DEBUG] 로그인 진행 중이라 중복 호출 방지")
            return
        }
        print("[DEBUG] 네이버 로그인 시작")
        startNaverLogin()
    }

    func startNaverLogin() {
        isLoginInProgress = true
        let state = UUID().uuidString
        print("[DEBUG] state 생성:", state)

        let authURLString = "https://nid.naver.com/oauth2.0/authorize" +
            "?response_type=code" +
            "&client_id=\(clientID)" +
            "&redirect_uri=\(redirectURI)" +
            "&state=\(state)"

        guard let authURL = URL(string: authURLString) else {
            print("[DEBUG] authURL 생성 실패")
            isLoginInProgress = false
            return
        }

        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackScheme) { [weak self] callbackURL, error in
            guard let self = self else { return }
            self.isLoginInProgress = false

            if let error = error {
                print("[DEBUG] ASWebAuthenticationSession error:", error)
                self.showAlert(title: "로그인 실패", message: error.localizedDescription)
                return
            }

            guard let url = callbackURL,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                print("[DEBUG] 콜백 URL 또는 쿼리 아이템 파싱 실패")
                self.showAlert(title: "로그인 실패", message: "잘못된 인증 응답")
                return
            }

            print("[DEBUG] callbackURL:", url.absoluteString)
            print("[DEBUG] 쿼리 아이템:", queryItems.map { "\($0.name): \($0.value ?? "nil")" })

            guard let accessToken = queryItems.first(where: { $0.name == "access" })?.value,
                  let refreshToken = queryItems.first(where: { $0.name == "refresh" })?.value else {
                self.showAlert(title: "로그인 실패", message: "토큰이 없습니다.")
                return
            }

            print("[DEBUG] accessToken:", accessToken)
            print("[DEBUG] refreshToken:", refreshToken)

            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: "access_token")
            defaults.set(refreshToken, forKey: "refresh_token")

            DispatchQueue.main.async {
                self.navigateToMainScreen()
            }
        }

        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        print("[DEBUG] ASWebAuthenticationSession 시작")
        authSession?.start()
    }

    private func navigateToMainScreen() {
        print("[DEBUG] 메인 화면으로 이동")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
           let window = sceneDelegate.window ?? (sceneDelegate as? SceneDelegate)?.window {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "EndPageViewController")
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
        } else {
            print("[DEBUG] 윈도우 또는 씬 델리게이트 접근 실패")
        }
    }

    func showAlert(title: String, message: String) {
        print("[DEBUG] Alert - \(title): \(message)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}

extension NaverLoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
