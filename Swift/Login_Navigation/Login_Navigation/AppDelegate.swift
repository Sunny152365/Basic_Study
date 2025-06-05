//
//  AppDelegate.swift
//  Login_Navigation
//
//  Created by 최원일 on 5/27/25.
//

import UIKit
import NaverThirdPartyLogin
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 네이버 로그인 초기 설정
        naverLoginInstance?.isNaverAppOauthEnable = true      // 네이버 앱으로 로그인 허용
        naverLoginInstance?.isInAppOauthEnable = true         // 인앱 브라우저 로그인 허용
        
        // Info.plist에 등록한 네이버 URL Scheme과 반드시 동일하게 수정 필요
        naverLoginInstance?.serviceUrlScheme = "naver_3lM5JlNiGaw3TTgWDa3"
        
        naverLoginInstance?.consumerKey = "_3lM5JlNiGaw3TTgWDa3"        // 네이버 개발자센터 Client ID
        naverLoginInstance?.consumerSecret = "u4zbVlZiD7"               // 네이버 개발자센터 Client Secret
        naverLoginInstance?.appName = "imitateSoomgo"                   // 앱 이름

        // 카카오 로그인 초기 설정
        KakaoSDK.initSDK(appKey: "d369a8ac1b2e52f2eac71adbaaa78e82")
        
        return true
    }

    // MARK: - URL 스킴 처리 (네이버 로그인 콜백)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        // ✅ 네이버 로그인 콜백 처리
        let result = NaverThirdPartyLoginConnection.getSharedInstance().receiveAccessToken(url)
        if result == .success {
            print("✅ Naver Login Success")
            return true
        } else {
            print("❌ Naver Login Failed")
            return false
        }
    }

    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 생략 가능
    }
}
