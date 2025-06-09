//
//  SceneDelegate.swift
//  Naver_Login_OAuth
//
//  Created by 최원일 on 6/8/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 씬이 시스템에 의해 해제될 때 호출됩니다.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 씬이 활성화 될 때 호출됩니다.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 씬이 비활성화 될 때 호출됩니다.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 백그라운드에서 포그라운드로 전환될 때 호출됩니다.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 앱이 백그라운드로 들어갈 때 호출됩니다.
    }
}
