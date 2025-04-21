//
//  ConversationView.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import SwiftUI

struct ConversationView: View {
    let messages: [Message]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages) { message in
                    MessageView(message)
                        .padding(.horizontal, 12)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ConversationView(messages: SampleData.conversation)
}
