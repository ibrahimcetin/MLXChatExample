//
//  ChatToolbarView.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 21.04.2025.
//

import SwiftUI

struct ChatToolbarView: View {
    @Bindable var vm: ChatViewModel

    var body: some View {
        if let errorMessage = vm.errorMessage {
            ErrorView(errorMessage: errorMessage)
        }

        if let progress = vm.modelDownloadProgress, !progress.isFinished {
            DownloadProgressView(progress: progress)
        }

        Button {
            vm.clear([.chat, .meta])
        } label: {
            GenerationInfoView(
                tokensPerSecond: vm.tokensPerSecond
            )
        }

        Picker("Model", selection: $vm.selectedModel) {
            ForEach(MLXService.availableModels) { model in
                Text(model.displayName)
                    .tag(model)
            }
        }
    }
}
