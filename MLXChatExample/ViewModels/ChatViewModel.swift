//
//  ChatViewModel.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import Foundation
import MLXLMCommon
import UniformTypeIdentifiers

@Observable
@MainActor
class ChatViewModel {
    private let mlxService: MLXService

    init(mlxService: MLXService) {
        self.mlxService = mlxService
    }

    var prompt: String = ""
    var messages: [Message] = [
        .system("You are a helpful assistant!")
    ]
    var selectedModel: LMModel = MLXService.availableModels.first!

    var mediaSelection = MediaSelection()

    var isGenerating = false
    private var generateTask: Task<Void, any Error>?

    private var generateCompletionInfo: GenerateCompletionInfo?
    var tokensPerSecond: Double {
        generateCompletionInfo?.tokensPerSecond ?? 0
    }

    var modelDownloadProgress: Progress? {
        mlxService.modelDownloadProgress
    }

    var errorMessage: String?

    func generate() async {
        // Cancel any existing task
        if let existingTask = generateTask {
            existingTask.cancel()
            generateTask = nil
        }

        isGenerating = true

        messages.append(.user(prompt, images: mediaSelection.images, videos: mediaSelection.videos))
        messages.append(.assistant(""))

        clear(.prompt)

        generateTask = Task {
            for await generation in try await mlxService.generate(messages: messages, model: selectedModel) {
                switch generation {
                case .chunk(let chunk):
                    if let assistantMessage = messages.last {
                        assistantMessage.content += chunk
                    }
                case .info(let info):
                    generateCompletionInfo = info
                }
            }
        }

        do {
            try await withTaskCancellationHandler {
                try await generateTask?.value
            } onCancel: {
                Task { @MainActor in
                    generateTask?.cancel()

                    if let assistantMessage = messages.last {
                        assistantMessage.content += "\n[Cancelled]"
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
        generateTask = nil
    }

    func addMedia(_ result: Result<URL, any Error>) {
        do {
            let url = try result.get()

            if let mediaType = UTType(filenameExtension: url.pathExtension) {
                if mediaType.conforms(to: .image) {
                    mediaSelection.images = [url]
                } else if mediaType.conforms(to: .movie) {
                    mediaSelection.videos = [url]
                }
            }
        } catch {
            errorMessage = "Failed to load media item.\n\nError: \(error)"
        }
    }

    func clear(_ options: ClearOption) {
        if options.contains(.prompt) {
            prompt = ""
            mediaSelection = .init()
        }

        if options.contains(.chat) {
            messages = []
            generateTask?.cancel()
        }

        if options.contains(.meta) {
            generateCompletionInfo = nil
        }

        errorMessage = nil
    }
}

@Observable
class MediaSelection {
    var isShowing = false

    var images: [URL] = []
    var videos: [URL] = []

    var isEmpty: Bool {
        images.isEmpty && videos.isEmpty
    }
}

struct ClearOption: RawRepresentable, OptionSet {
    let rawValue: Int

    static let prompt = ClearOption(rawValue: 1 << 0)
    static let chat = ClearOption(rawValue: 1 << 1)
    static let meta = ClearOption(rawValue: 1 << 2)
}
