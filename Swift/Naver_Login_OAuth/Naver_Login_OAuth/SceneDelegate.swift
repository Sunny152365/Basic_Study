import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    // iOS 13+에서 커스텀 URL 스킴 처리 (주로 디버깅용)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        print("[DEBUG] 앱이 URL로 열림: \(url.absoluteString)")
        // 현재는 ASWebAuthenticationSession이 콜백을 자체 처리하므로 여기선 별도 처리 없음
    }
}
