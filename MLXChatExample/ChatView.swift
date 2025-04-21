//
//  ChatView.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import SwiftUI
import AVFoundation
import AVKit

struct ChatView: View {
    @Bindable private var vm: ChatViewModel

    init(viewModel: ChatViewModel) {
        self.vm = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ConversationView(messages: vm.messages)

                Divider()

                if !vm.mediaSelection.isEmpty {
                    MediaPreviewsView(mediaSelection: vm.mediaSelection)
                }

                PromptField(
                    prompt: $vm.prompt,
                    sendButtonAction: vm.generate,
                    mediaButtonAction: vm.selectedModel.isVisionModel ? {
                        vm.mediaSelection.isShowing = true
                    } : nil
                )
                .padding()
            }
            .navigationTitle("MLX Chat Example")
            .toolbar {
                ChatToolbarView(vm: vm)
            }
            .fileImporter(
                isPresented: $vm.mediaSelection.isShowing,
                allowedContentTypes: [.image, .movie],
                onCompletion: vm.addMedia
            )
        }
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel(mlxService: MLXService()))
}
