//
//  ConversationModels.swift
//  Texty
//
//  Created by Jeslin Yeoh on 03/03/2022
//  following iOS Academy's YouTube tutorial.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
