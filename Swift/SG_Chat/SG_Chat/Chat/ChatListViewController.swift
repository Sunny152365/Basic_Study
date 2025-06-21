//  ChatListViewController.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.

import UIKit

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var chatRooms: [ChatRoom] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 테이블뷰 델리게이트 및 데이터소스 설정
        tableView.delegate = self
        tableView.dataSource = self

        // 기본 셀 등록 (스토리보드 프로토타입 셀 사용할 경우 생략 가능)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatRoom")

        // 채팅방 목록 불러오기
        fetchChatRooms()
    }

    // MARK: - 채팅방 목록 API 호출
    func fetchChatRooms() {
        guard let url = URL(string: "https://yourdomain.com/chat/rooms/") else {
            print("❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // JWT 토큰이 있다면 여기에 추가
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ 네트워크 오류:", error)
                return
            }

            guard let data = data else {
                print("❌ 응답 데이터 없음")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let rooms = try decoder.decode([ChatRoom].self, from: data)

                DispatchQueue.main.async {
                    self?.chatRooms = rooms
                    self?.tableView.reloadData()
                }
            } catch {
                print("❌ JSON 디코딩 실패:", error)
            }
        }

        task.resume()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = chatRooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoom", for: indexPath)
        cell.textLabel?.text = "Room #\(room.id)"
        cell.detailTextLabel?.text = room.lastMessage ?? "(No messages yet)"
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = chatRooms[indexPath.row]
        performSegue(withIdentifier: "ChatRoomViewController", sender: room)
    }

    // MARK: - Segue 준비
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatRoomViewController",
           let destVC = segue.destination as? ChatRoomViewController,
           let room = sender as? ChatRoom {
            destVC.chatRoom = room
        }
    }
}
