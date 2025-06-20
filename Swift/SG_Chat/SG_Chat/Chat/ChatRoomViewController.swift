//
//  ViewController.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.
//

// Controller
import UIKit

class ChatRoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var chatRoom: ChatRoom!
    var messages: [SimpleChatMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Room #\(chatRoom.id)"
        tableView.delegate = self
        tableView.dataSource = self
        connectWebSocket()
    }

    func connectWebSocket() {
        // TODO: WebSocket 연결 및 메시지 수신 처리
    }

    @IBAction func sendMessage(_ sender: UIButton) {
        guard let text = messageField.text, !text.isEmpty else { return }
        // TODO: 메시지 WebSocket으로 전송
        messageField.text = ""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath)
        cell.textLabel?.text = "\(msg.sender): \(msg.content)"
        return cell
    }
}

// 전체 채팅방 화면을 관리
// 데이터 받아오기, 셀로 뿌리기, 유저 이벤트 처리
// 서버 연결 (ChatService)도 여기서 연결됨
// Model과 View를 연결하고 중간 제어함 → Controller
