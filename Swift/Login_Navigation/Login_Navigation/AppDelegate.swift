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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // ✅ 네이버 로그인 초기 설정
        naverLoginInstance?.isNaverAppOauthEnable = true
        naverLoginInstance?.isInAppOauthEnable = true
        naverLoginInstance?.serviceUrlScheme = "naver_3lM5JlNiGaw3TTgWDa3" // Info.plist와 동일해야 함
        naverLoginInstance?.consumerKey = "_3lM5JlNiGaw3TTgWDa3"
        naverLoginInstance?.consumerSecret = "u4zbVlZiD7"
        naverLoginInstance?.appName = "imitateSoomgo"

        // ✅ 카카오 로그인 초기화
        KakaoSDK.initSDK(appKey: "d369a8ac1b2e52f2eac71adbaaa78e82")

        return true
    }

    // ✅ 앱 URL 처리 - 네이버 로그인 콜백을 처리
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return NaverThirdPartyLoginConnection
            .getSharedInstance()
            .application(application, open: url, options: options)
    }

    // ✅ UISceneDelegate 사용 시 필요 (iOS 13 이상)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 필요 시 세션 정리
    }
}
