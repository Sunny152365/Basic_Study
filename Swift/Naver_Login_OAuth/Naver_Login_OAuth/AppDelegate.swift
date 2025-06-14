import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("✅ 앱 시작")
        return true
    }

    // 딥링크 처리
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("📦 URL 수신: \(url.absoluteString)")

        // naverapp://login?access=xxx&refresh=yyy 형태 처리
        guard url.scheme == "naverapp",
              url.host == "login",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            print("⚠️ 처리 대상 URL 아님")
            return false
        }

        let accessToken = queryItems.first(where: { $0.name == "access" })?.value
        let refreshToken = queryItems.first(where: { $0.name == "refresh" })?.value

        print("🟢 Access Token: \(accessToken ?? "없음")")
        print("🟢 Refresh Token: \(refreshToken ?? "없음")")

        if let accessToken = accessToken, let refreshToken = refreshToken {
            // UserDefaults 등에 저장
            UserDefaults.standard.set(accessToken, forKey: "access_token")
            UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
            
            // TODO: 여기서 로그인 성공 후 화면 전환 등 원하는 처리 추가
        } else {
            print("⚠️ 토큰 정보가 불완전합니다.")
        }

        return true
    }
}
