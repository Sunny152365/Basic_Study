import UIKit
import AuthenticationServices

class NaverLoginViewController: UIViewController {

    @IBOutlet weak var naverLoginView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("[DEBUG] viewDidLoad 호출됨")
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
    }

    @objc func naverLoginViewTapped() {
        print("[DEBUG] ✅ 뷰가 클릭됨 - OAuth 로그인 시도 시작")
        startNaverLogin()
    }

    func startNaverLogin() {
        print("[DEBUG] startNaverLogin 시작")

        let clientID = "_3lM5JlNiGaw3TTgWDa3"
        let redirectURI = "naver_3lM5JlNiGaw3TTgWDa3://auth"
        let state = UUID().uuidString

        let authURL = """
        https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURI)&state=\(state)
        """

        guard let url = URL(string: authURL) else {
            print("[DEBUG] ❌ startNaverLogin: URL 생성 실패")
            return
        }
        print("[DEBUG] authURL 생성됨: \(url)")

        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "naver_3lM5JlNiGaw3TTgWDa3"
        ) { callbackURL, error in
            print("[DEBUG] ASWebAuthenticationSession 콜백 호출됨")

            guard
                error == nil,
                let callbackURL = callbackURL,
                let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                let queryItems = components.queryItems
            else {
                print("[DEBUG] ❌ 로그인 실패 또는 취소: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let code = queryItems.first(where: { $0.name == "code" })?.value,
               let state = queryItems.first(where: { $0.name == "state" })?.value {
                print("[DEBUG] ✅ 로그인 성공: code=\(code), state=\(state)")
                self.requestAccessToken(code: code, state: state)
            } else {
                print("[DEBUG] ❌ code 또는 state 추출 실패")
            }
        }

        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true

        print("[DEBUG] ASWebAuthenticationSession 시작")
        session.start()
    }

    func requestAccessToken(code: String, state: String) {
        print("[DEBUG] requestAccessToken 시작")

        let clientID = "_3lM5JlNiGaw3TTgWDa3"
        let clientSecret = "u4zbVlZiD7"
        let redirectURI = "naver_3lM5JlNiGaw3TTgWDa3://auth"

        var components = URLComponents(string: "https://nid.naver.com/oauth2.0/token")!
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]

        guard let url = components.url else {
            print("[DEBUG] ❌ requestAccessToken: URLComponents.url 생성 실패")
            return
        }
        print("[DEBUG] accessToken 요청 URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[DEBUG] ❌ 토큰 요청 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("[DEBUG] ❌ 응답 데이터 없음")
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let accessToken = json["access_token"] as? String {
                    print("[DEBUG] ✅ Access Token 추출 완료: \(accessToken)")
                    self.sendAccessTokenToBackend(accessToken)
                } else {
                    print("[DEBUG] ⚠️ 응답에 access_token 없음: \(json)")
                }
            } else {
                print("[DEBUG] ❌ 응답 JSON 파싱 실패")
            }
        }.resume()
    }

    func sendAccessTokenToBackend(_ accessToken: String) {
        print("[DEBUG] 서버에 access token 전달 시작")

        guard let url = URL(string: "https://66c7-222-98-221-76.ngrok-free.app/api/users/naver-login/") else {
            print("[DEBUG] ❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[DEBUG] ❌ 서버 통신 실패: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("[DEBUG] ✅ 서버 응답 상태코드: \(httpResponse.statusCode)")
            }

            if let data = data {
                print("[DEBUG] ✅ 서버 응답 데이터: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }
}

// MARK: - ASWebAuthenticationSession Presentation Anchor
extension NaverLoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        print("[DEBUG] presentationAnchor 호출됨")
        return self.view.window!
    }
}
