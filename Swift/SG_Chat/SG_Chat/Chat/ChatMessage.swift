//
//  ChatMessage.swift
//  SG_Chat
//
//  Created by 최원일 on 6/19/25.
//

// 모델
import Foundation

struct SimpleChatMessage: Codable {
    let id: Int
    let sender: String
    let content: String
    let createdAt: Date
}

// 채팅 메시지 하나를 표현하는 데이터 구조
// 서버에서 받아오거나 보낼 때 사용됨
// 비즈니스 로직 or 순수 데이터 객체에 해당
