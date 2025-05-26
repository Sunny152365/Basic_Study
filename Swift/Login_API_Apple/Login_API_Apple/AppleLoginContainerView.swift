//
//  AppleLoginContainerView.swift
//  Login_API_Apple
//
//  Created by 최원일 on 5/25/25.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {

    @IBOutlet weak var appleLoginContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginButton()
    }

    private func setupAppleLoginButton() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.frame = appleLoginContainerView.bounds
        appleButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // 눌렀을 때 액션 연결
        appleButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)

        appleLoginContainerView.addSubview(appleButton)
    }

    @objc func handleAppleSignIn() {
        print("애플 로그인 버튼 클릭됨")

        // 유료 계정 없으므로 실제 요청은 생략
        // 인증 요청 코드 예시 (작동 안 함):
        /*
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        */
    }
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

/*
 [User taps Sign in with Apple button]
               ↓
 [App creates ASAuthorizationAppleIDRequest]
               ↓
 [ASAuthorizationController sends request to Apple]
               ↓
 [Apple prompts user for FaceID/TouchID]
               ↓
 [Apple returns IdentityToken + User Info]
               ↓
 [App receives token and user ID/email]
               ↓
 (선택) [App sends token to backend server]
               ↓
 [Backend verifies token with Apple server]
               ↓
 [User is authenticated, session starts]

 */
