const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// 네이버 로그인 후 커스텀 토큰 생성 함수
exports.naverLogin = functions.https.onRequest(async (req, res) => {
  try {
    const accessToken = req.body.accessToken;
    if (!accessToken) {
      return res.status(400).json({ error: "accessToken is required" });
    }

    // 네이버 프로필 API 호출
    const naverResponse = await axios.get("https://openapi.naver.com/v1/nid/me", {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    const naverUser = naverResponse.data.response;
    if (!naverUser) {
      return res.status(401).json({ error: "Invalid Naver access token" });
    }

    const uid = `naver:${naverUser.id}`;

    // Firebase에 사용자 조회 또는 생성
    let userRecord;
    try {
      userRecord = await admin.auth().getUser(uid);
    } catch (error) {
      if (error.code === "auth/user-not-found") {
        userRecord = await admin.auth().createUser({
          uid,
          displayName: naverUser.name,
          email: naverUser.email || undefined,
        });
      } else {
        throw error;
      }
    }

    // 커스텀 토큰 생성
    const customToken = await admin.auth().createCustomToken(uid);

    return res.json({ token: customToken });
  } catch (error) {
    console.error("Naver Login Error:", error);
    return res.status(500).json({ error: error.message });
  }
});

// 카카오 로그인 후 커스텀 토큰 생성 함수
exports.kakaoLogin = functions.https.onRequest(async (req, res) => {
  try {
    const accessToken = req.body.accessToken;
    if (!accessToken) {
      return res.status(400).json({ error: "accessToken is required" });
    }

    // 카카오 API 호출 - 사용자 정보 조회
    const kakaoResponse = await axios.get("https://kapi.kakao.com/v2/user/me", {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    const kakaoUser = kakaoResponse.data;
    if (!kakaoUser || !kakaoUser.id) {
      return res.status(401).json({ error: "Invalid Kakao access token" });
    }

    const uid = `kakao:${kakaoUser.id}`;

    // Firebase 사용자 조회 또는 생성
    let userRecord;
    try {
      userRecord = await admin.auth().getUser(uid);
    } catch (error) {
      if (error.code === "auth/user-not-found") {
        userRecord = await admin.auth().createUser({
          uid,
          displayName: kakaoUser.properties?.nickname || undefined,
          email: kakaoUser.kakao_account?.email || undefined,
        });
      } else {
        throw error;
      }
    }

    // 커스텀 토큰 생성
    const customToken = await admin.auth().createCustomToken(uid);

    return res.json({ token: customToken });
  } catch (error) {
    console.error("Kakao Login Error:", error);
    return res.status(500).json({ error: error.message });
  }
});

// 네이버, 카카오 로그인 성공 후, 받은 accessToken을 JSON Body에 담아서 호출
func requestCustomToken(from url: String, accessToken: String, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: url) else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body = ["accessToken": accessToken]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil,
              let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["token"] as? String else {
            completion(nil)
            return
        }
        completion(token)
    }.resume()
}

// 네이버
requestCustomToken(from: "https://us-central1-soomgologinimitate.cloudfunctions.net/naverLogin", accessToken: naverAccessToken) { customToken in
    guard let customToken = customToken else { return }
    Auth.auth().signIn(withCustomToken: customToken) { result, error in
        // Firebase 로그인 완료 처리
    }
}
// 카카오
requestCustomToken(from: "https://us-central1-soomgologinimitate.cloudfunctions.net/kakaoLogin", accessToken: kakaoAccessToken) { customToken in
    guard let customToken = customToken else { return }
    Auth.auth().signIn(withCustomToken: customToken) { result, error in
        // Firebase 로그인 완료 처리
    }
}



/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
