//
//  Message.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import Foundation

@Observable
class Message: Identifiable {
    let id: UUID
    let role: Role
    var content: String
    var images: [URL]
    var videos: [URL]
    let timestamp: Date

    init(role: Role, content: String, images: [URL] = [], videos: [URL] = []) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.images = images
        self.videos = videos
        self.timestamp = .now
    }

    enum Role {
        case user
        case assistant
        case system
    }
}

extension Message {
    static func user(_ content: String, images: [URL] = [], videos: [URL] = []) -> Message {
        Message(role: .user, content: content, images: images, videos: videos)
    }

    static func assistant(_ content: String) -> Message {
        Message(role: .assistant, content: content)
    }

    static func system(_ content: String) -> Message {
        Message(role: .system, content: content)
    }
}
