//
//  AppDelegate.swift
//  Naver_Login_OAuth
//
//  Created by 최원일 on 6/8/25.
//

import UIKit
import NaverThirdPartyLogin // ✅ SDK import 필요

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let clientID = "_3lM5JlNiGaw3TTgWDa3"
    let clientSecret = "u4zbVlZiD7"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // ✅ NaverThirdPartyLogin 초기화 설정
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isNaverAppOauthEnable = true
        instance?.isInAppOauthEnable = true
        instance?.isOnlyPortraitSupportedInIphone()
        
        instance?.serviceUrlScheme = "naver_3lM5JlNiGaw3TTgWDa3" // ⚠️ info.plist에 등록한 Scheme과 일치
        instance?.consumerKey = "_3lM5JlNiGaw3TTgWDa3"
        instance?.consumerSecret = "u4zbVlZiD7"
        instance?.appName = "imitateSoomgo" // 앱 이름 자유 설정 가능
        
        print("✅ NaverThirdPartyLogin 설정 완료")

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        print("📦 URL 수신: \(url)") // ✅ 이 로그가 나와야 앱이 다시 열리는 것

        guard url.scheme?.starts(with: "naver") == true else {
            return false
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let code = components?.queryItems?.first(where: { $0.name == "code" })?.value
        let state = components?.queryItems?.first(where: { $0.name == "state" })?.value

        if let code = code, let state = state {
            print("✅ code, state 수신 완료: \(code), \(state)")
            requestAccessToken(code: code, state: state)
        } else {
            print("❌ code 또는 state 누락")
        }

        return true
    }

    
    private func requestAccessToken(code: String, state: String) {
        let tokenURL = URL(string: "https://nid.naver.com/oauth2.0/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        let parameters = [
            "grant_type": "authorization_code",
            "client_id": "_3lM5JlNiGaw3TTgWDa3",
            "client_secret": "u4zbVlZiD7",
            "code": code,
            "state": state
        ]
        
        let bodyString = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String else {
                print("❌ access token 요청 실패")
                return
            }
            
            print("✅ Access Token 수신 완료: \(accessToken)")
            NotificationCenter.default.post(name: .naverTokenReceived, object: accessToken)
        }.resume()
    }
}

extension Notification.Name {
    static let naverTokenReceived = Notification.Name("naverTokenReceived")
}
