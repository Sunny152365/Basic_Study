//
//  ChatListViewController.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chatRooms: [ChatRoom] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchChatRooms()
    }

    func fetchChatRooms() {
        // TODO: 네트워크로 채팅방 목록 가져오기
        // chatRooms = ...
        // self.tableView.reloadData()
        // 테스트용 더미 데이터
        chatRooms = [
            ChatRoom(id: "1", participants: ["wonil", "friend"], lastMessage: "Hello!", lastMessageTime: Date()),
            ChatRoom(id: "2", participants: ["wonil", "someone"], lastMessage: "Welcome!", lastMessageTime: Date()),
        ]

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = chatRooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath)
        cell.textLabel?.text = "Room #\(room.id)"
        cell.detailTextLabel?.text = room.lastMessage ?? ""
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = chatRooms[indexPath.row]
        performSegue(withIdentifier: "ShowChatRoom", sender: room)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChatRoom",
           let destVC = segue.destination as? ChatRoomViewController,
           let room = sender as? ChatRoom {
            destVC.chatRoom = room
        }
    }
}
