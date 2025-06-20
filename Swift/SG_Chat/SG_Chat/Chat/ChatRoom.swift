//
//  ChatRoom.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.
//

// 모델
import Foundation

struct ChatRoom {
    let id: String
    let participants: [String] // username 목록
    let lastMessage: String?
    let lastMessageTime: Date
}

