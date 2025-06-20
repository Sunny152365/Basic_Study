//
//  ChatService.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.
//

import Foundation

// MARK: - 모델 정의
struct ChatMessage: Codable {
    let user: String
    let message: String
    let createdAt: Date? // 필요 없다면 제거해도 됨
}

// MARK: - 델리게이트 프로토콜
protocol ChatServiceDelegate: AnyObject {
    func didReceiveMessage(_ message: ChatMessage)
    func didDisconnectWithError(_ error: Error?)
}

// MARK: - 서비스 구현
class ChatService: NSObject {
    private var webSocketTask: URLSessionWebSocketTask?
    weak var delegate: ChatServiceDelegate?

    func connect(roomID: String, userToken: String? = nil) {
        let urlString = "ws://127.0.0.1:8000/ws/chat/\(roomID)/"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        if let token = userToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        webSocketTask = URLSession(configuration: .default).webSocketTask(with: request)
        webSocketTask?.resume()

        receiveMessage()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    func sendMessage(_ message: String, username: String) {
        let json: [String: Any] = ["message": message, "user": username]
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let text = String(data: data, encoding: .utf8) else { return }

        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                print("WebSocket send error: \(error.localizedDescription)")
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.delegate?.didDisconnectWithError(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    if let chatMessage = self.parseMessage(text) {
                        self.delegate?.didReceiveMessage(chatMessage)
                    }
                default:
                    print("Unsupported message received")
                }
                self.receiveMessage()
            }
        }
    }

    private func parseMessage(_ text: String) -> ChatMessage? {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let user = json["user"] as? String,
              let message = json["message"] as? String else {
            return nil
        }

        return ChatMessage(user: user, message: message, createdAt: Date()) // createdAt은 옵션
    }
}
