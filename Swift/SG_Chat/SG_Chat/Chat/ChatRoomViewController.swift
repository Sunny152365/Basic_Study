//
//  ChatRoomViewController.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.
//

import UIKit


class ChatRoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var chatRoom: ChatRoom? // 외부에서 전달받는 채팅방 정보
    var messages: [SimpleChatMessage] = []

    // WebSocket 연결용 task
    var webSocketTask: URLSessionWebSocketTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 안전하게 채팅방이 넘어왔는지 체크 후 타이틀 세팅
        if let room = chatRoom {
            title = "Room #\(room.id)"
        } else {
            title = "Unknown Room"
            print("⚠️ chatRoom이 전달되지 않았습니다.")
        }

        // 테이블뷰 델리게이트, 데이터소스, 텍스트필드 델리게이트 설정
        tableView.delegate = self
        tableView.dataSource = self
        messageField.delegate = self

        // 셀 등록 - 스토리보드에 prototype cell 있다면 생략 가능
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatMessageCell")

        // 서버에서 메시지 목록 API 호출
        fetchMessages()

        // WebSocket 연결 시작
        connectWebSocket()
    }

    // MARK: - 메시지 목록 API 호출
    func fetchMessages() {
        guard let roomId = chatRoom?.id,
              let url = URL(string: "https://yourserver.com/api/chatrooms/\(roomId)/messages/") else {
            print("❌ 메시지 URL 생성 실패")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("❌ 메시지 API 호출 실패:", error)
                return
            }

            guard let data = data else {
                print("❌ 메시지 데이터 없음")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                self?.messages = try decoder.decode([SimpleChatMessage].self, from: data)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                }
            } catch {
                print("❌ 메시지 JSON 디코딩 실패:", error)
            }
        }
        task.resume()
    }

    // MARK: - WebSocket 연결 및 메시지 수신 대기
    func connectWebSocket() {
        guard let roomId = chatRoom?.id,
              let url = URL(string: "wss://yourserver.com/ws/chat/\(roomId)/") else {
            print("❌ WebSocket URL 생성 실패")
            return
        }

        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        listenWebSocket()
    }

    func listenWebSocket() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("❌ WebSocket 수신 오류:", error)
                self?.reconnectWebSocket()
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleIncomingMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleIncomingMessage(text)
                    }
                @unknown default:
                    print("❓ 알 수 없는 메시지 타입")
                }
                // 계속 수신 대기
                self?.listenWebSocket()
            }
        }
    }

    func reconnectWebSocket() {
        print("WebSocket 재연결 시도 중...")
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connectWebSocket()
        }
    }

    // 수신된 메시지 처리 후 UI 업데이트
    func handleIncomingMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let newMessage = try decoder.decode(SimpleChatMessage.self, from: data)

            DispatchQueue.main.async {
                self.messages.append(newMessage)
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        } catch {
            print("❌ 수신 메시지 디코딩 실패:", error)
        }
    }

    // MARK: - 메시지 전송 액션

    @IBAction func sendMessage(_ sender: UIButton) {
        sendCurrentMessage()
    }

    func sendCurrentMessage() {
        guard let text = messageField.text, !text.isEmpty else { return }

        let messageDict: [String: Any] = [
            "sender": "me",  // 실제 로그인 유저명으로 교체 필요
            "content": text
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageDict, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message) { error in
                    if let error = error {
                        print("❌ 메시지 전송 실패:", error)
                    }
                }
            }
        } catch {
            print("❌ 메시지 직렬화 실패:", error)
        }

        messageField.text = ""
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath)
        cell.textLabel?.text = "\(msg.sender): \(msg.content)"
        return cell
    }

    // MARK: - 편의 메서드

    func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCurrentMessage()
        textField.resignFirstResponder()
        return true
    }

    // 뷰 컨트롤러 해제 시 WebSocket 닫기
    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}


// 전체 채팅방 화면을 관리
// 데이터 받아오기, 셀로 뿌리기, 유저 이벤트 처리
// 서버 연결 (ChatService)도 여기서 연결됨
// Model과 View를 연결하고 중간 제어함 → Controller
