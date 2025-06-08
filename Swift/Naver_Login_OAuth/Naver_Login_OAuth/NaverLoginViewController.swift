//
//  ViewController.swift
//  Naver_Login_OAuth
//
//  Created by 최원일 on 6/8/25.
//

import UIKit
import NaverThirdPartyLogin

class NaverLoginViewController: UIViewController {

    private let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

    @IBOutlet weak var naverLoginView: UIView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ viewDidLoad 호출됨")

        view.backgroundColor = .white

        // 네이버 로그인 설정
        naverLoginInstance?.isNaverAppOauthEnable = true
        naverLoginInstance?.isInAppOauthEnable = true
        naverLoginInstance?.isOnlyPortraitSupportedInIphone()
        naverLoginInstance?.delegate = self
        print("✅ Naver SDK 초기화 및 delegate 설정 완료")

        // 이미지뷰 구성
        let naverImageView = UIImageView(image: UIImage(named: "naver_login"))
        naverImageView.contentMode = .scaleAspectFit
        naverImageView.frame = naverLoginView.bounds
        naverImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        naverImageView.clipsToBounds = true
        naverImageView.isUserInteractionEnabled = true
        naverLoginView.addSubview(naverImageView)

        // 탭 제스처 등록
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(naverLoginViewTapped))
        naverImageView.addGestureRecognizer(tapGesture)
        print("✅ 탭 제스처 등록 완료")

        // Notification 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNaverAccessToken(_:)),
            name: .naverTokenReceived,
            object: nil
        )
    }

    @objc func naverLoginViewTapped() {
        print("✅ 뷰가 클릭됨 - 로그인 시도 시작")
        naverLoginInstance?.requestThirdPartyLogin()
        print("🔄 requestThirdPartyLogin() 호출 완료")
    }

    func sendAccessTokenToBackend(_ accessToken: String) {
        print("✅ 서버에 access token 전달 시작")

        guard let url = URL(string: "https://66c7-222-98-221-76.ngrok-free.app/api/users/naver-login/") else {
            print("❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["access_token": accessToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 통신 실패: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ 서버 응답 상태코드: \(httpResponse.statusCode)")
            }

            if let data = data {
                print("✅ 서버 응답 데이터: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }
}

// MARK: - NaverThirdPartyLoginConnectionDelegate
extension NaverLoginViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("✅ access token 발급 성공")
        // 👉 여기서는 더 이상 sendAccessTokenToBackend를 호출하지 않음
    }

    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("ℹ️ Refresh Token 흐름 발생")
    }

    func oauth20ConnectionDidFinishDeleteToken() {
        print("ℹ️ 토큰 삭제 완료")
    }

    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("❌ 네이버 로그인 실패: \(error.localizedDescription)")
    }

    @objc func handleNaverAccessToken(_ notification: Notification) {
        if let token = notification.object as? String {
            print("✅ Notification 통해 access token 수신 완료: \(token)")
            sendAccessTokenToBackend(token)
        } else {
            print("❌ Notification에서 access token 추출 실패")
        }
    }
}
