//
//  AppDelegate.swift
//  Login_Navigation
//
//  Created by 최원일 on 5/27/25.
//

import UIKit
//import NaverThirdPartyLogin
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 기능 활성화 전역 초기화 코드
        FirebaseApp.configure()
        // Override point for customization after application launch.
        /*
        // 네이버 로그인 초기 설정
                naverLoginInstance?.isNaverAppOauthEnable = true      // 네이버 앱으로 로그인 허용
                naverLoginInstance?.isInAppOauthEnable = true         // 인앱 브라우저 로그인 허용
                naverLoginInstance?.serviceUrlScheme = "naverlogin"  // Info.plist에 등록한 URL Scheme와 같아야 함
                naverLoginInstance?.consumerKey = "YOUR_CONSUMER_KEY"        // 네이버 개발자센터 Client ID
                naverLoginInstance?.consumerSecret = "YOUR_CONSUMER_SECRET"  // 네이버 개발자센터 Client Secret
                naverLoginInstance?.appName = "YOUR_APP_NAME"                // 앱 이름
         */
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
    }
    /*
    func application(_ app: UIApplication, open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            if naverLoginInstance?.application(app, open: url, options: options) ?? false {
                return true
            }
            return false
        }
    */
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

