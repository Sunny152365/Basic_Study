//
//  ViewController.swift
//  Basic_Chat
//
//  Created by 최원일 on 6/10/25.
//

import UIKit

struct Message {
    let text: String
    let isSentByUser: Bool
}

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self as UITableViewDataSource
        tableView.delegate = self as UITableViewDelegate
        tableView.separatorStyle = .none
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = messageTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let newMessage = Message(text: text, isSentByUser: true)
        messages.append(newMessage)
        messageTextField.text = ""

        tableView.reloadData()
        scrollToBottom()
    }

    private func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// ✅ 이 부분이 수정된 extension입니다
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]

        let cellIdentifier = message.isSentByUser ? "UserMessageCell" : "OtherMessageCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        cell.textLabel?.text = message.text
        cell.textLabel?.textAlignment = message.isSentByUser ? .right : .left

        return cell
    }
}
