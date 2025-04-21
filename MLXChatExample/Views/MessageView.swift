//
//  MessageView.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import SwiftUI
import AVKit

struct MessageView: View {
    let message: Message

    init(_ message: Message) {
        self.message = message
    }

    var body: some View {
        switch message.role {
        case .user:
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    if let firstImage = message.images.first {
                        AsyncImage(url: firstImage) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: 250, maxHeight: 200)
                        .clipShape(.rect(cornerRadius: 12))
                    }

                    if let firstVideo = message.videos.first {
                        VideoPlayer(player: AVPlayer(url: firstVideo))
                            .frame(width: 250, height: 340)
                            .clipShape(.rect(cornerRadius: 12))
                    }

                    Text(message.content)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.tint, in: .rect(cornerRadius: 16))
                        .textSelection(.enabled)
                }
            }

        case .assistant:
            HStack {
                Text(message.content)
                    .textSelection(.enabled)

                Spacer()
            }

        case .system:
            Label(message.content, systemImage: "desktopcomputer")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageView(.system("You are a helpful assistant."))

        MessageView(
            .user(
                "Here's a photo",
                images: [URL(string: "https://picsum.photos/200")!]
            )
        )

        MessageView(.assistant("I see your photo!"))
    }
    .padding()
}
