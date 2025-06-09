//
//  AppDelegate.swift
//  Naver_Login_OAuth
//
//  Created by 최원일 on 6/8/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // SDK 초기화 제거, 필요 없으니 비워둬도 됨
        print("✅ 앱 시작")
        return true
    }

    // iOS 12 이하 대응용 URL 콜백 함수 (필요 시에만)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("📦 URL 수신: \(url)")
        // ASWebAuthenticationSession이 iOS 13 이상부터 지원하므로,
        // iOS 12 이하 기기라면 직접 처리할 필요 있음.
        // 지금은 빈 처리 (필요하다면 구현)
        return true
    }
}
