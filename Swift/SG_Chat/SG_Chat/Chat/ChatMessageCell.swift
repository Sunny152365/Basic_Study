//
//  ChatMessageCell.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.
//

// View
import UIKit

class ChatMessageCell: UITableViewCell {

    private let messageLabel = UILabel()
    private let bubbleView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        bubbleView.layer.cornerRadius = 12
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        // 기본 정렬: 왼쪽 (보낸사람 여부는 configure에서 조정)
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12)
        ])
    }

    func configure(with message: SimpleChatMessage, isFromCurrentUser: Bool) {
        messageLabel.text = message.content
        bubbleView.backgroundColor = isFromCurrentUser ? UIColor.systemBlue : UIColor.lightGray
        messageLabel.textColor = isFromCurrentUser ? .white : .black

        // 정렬 업데이트
        if isFromCurrentUser {
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor).isActive = true
        } else {
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor).isActive = true
        }
    }
}

// 테이블 뷰의 한 줄 UI 구성을 담당
// message 내용을 뷰에 그리는 역할
// 재사용 가능한 화면 단위
// UI만 담당, 로직 없음 → View
