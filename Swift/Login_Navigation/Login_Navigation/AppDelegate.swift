import UIKit
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("✅ 앱 시작")

        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: "d369a8ac1b2e52f2eac71adbaaa78e82")

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        print("📦 URL 수신: \(url.absoluteString)")

        // 딥링크: naverapp://login?access=xxx&refresh=yyy 형태 처리
        if url.scheme == "naverapp",
           url.host == "login",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {

            let accessToken = queryItems.first(where: { $0.name == "access" })?.value
            let refreshToken = queryItems.first(where: { $0.name == "refresh" })?.value

            print("🟢 Access Token: \(accessToken ?? "없음")")
            print("🟢 Refresh Token: \(refreshToken ?? "없음")")

            if let accessToken = accessToken, let refreshToken = refreshToken {
                UserDefaults.standard.set(accessToken, forKey: "access_token")
                UserDefaults.standard.set(refreshToken, forKey: "refresh_token")

                // TODO: 로그인 성공 후 화면 전환 등 원하는 작업 수행
            } else {
                print("⚠️ 토큰 정보가 불완전합니다.")
            }
            return true
        }

        // 카카오 로그인 URL 처리
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        print("⚠️ 처리 대상 URL 아님")
        return false
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
