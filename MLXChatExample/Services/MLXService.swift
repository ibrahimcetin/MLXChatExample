//
//  MLXService.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 20.04.2025.
//

import Foundation

import MLX
import MLXLMCommon
import MLXLLM
import MLXVLM

@Observable
class MLXService {
    static let availableModels: [LMModel] = [
        LMModel(name: "llama3.2:1b", configuration: LLMRegistry.llama3_2_1B_4bit, type: .llm),
        LMModel(name: "qwen2.5:1.5b", configuration: LLMRegistry.qwen2_5_1_5b, type: .llm),
        LMModel(name: "smolLM:135m", configuration: LLMRegistry.smolLM_135M_4bit, type: .llm),
        LMModel(name: "qwen2.5VL:3b", configuration: VLMRegistry.qwen2_5VL3BInstruct4Bit, type: .vlm),
        LMModel(name: "qwen2VL:2b", configuration: VLMRegistry.qwen2VL2BInstruct4Bit, type: .vlm),
        LMModel(name: "smolVLM", configuration: VLMRegistry.smolvlminstruct4bit, type: .vlm)
    ]

    private let modelCache = NSCache<NSString, ModelContainer>()

    @MainActor
    private(set) var modelDownloadProgress: Progress?

    private func load(model: LMModel) async throws -> ModelContainer {
        // limit the buffer cache
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

        if let container = modelCache.object(forKey: model.name as NSString) {
            return container
        } else {
            let factory: ModelFactory = switch model.type {
            case .llm:
                LLMModelFactory.shared
            case .vlm:
                VLMModelFactory.shared
            }

            let container = try await factory.loadContainer(hub: .default, configuration: model.configuration) { progress in
                Task { @MainActor in
                    self.modelDownloadProgress = progress
                }
            }

            modelCache.setObject(container, forKey: model.name as NSString)

            return container
        }
    }

    func generate(messages: [Message], model: LMModel) async throws -> AsyncStream<Generation> {
        // Load the selected model container
        let modelContainer = try await load(model: model)

        // Convert our `Message` to `Chat.Message` from MLXLMCommon.
        let chat = messages.map { message in
            let role: Chat.Message.Role = switch message.role {
            case .assistant:
                .assistant
            case .user:
                .user
            case .system:
                .system
            }

            let images: [UserInput.Image] = message.images.map { imageURL in .url(imageURL)}
            let videos: [UserInput.Video] = message.videos.map { videoURL in .url(videoURL)}


            return Chat.Message(role: role, content: message.content, images: images, videos: videos)
        }

        // Use chat messages to create UserInput instance
        let userInput = UserInput(chat: chat)

        // Return AsyncStrem to generate output
        return try await modelContainer.perform { (context: ModelContext) in
            let lmInput = try await context.processor.prepare(input: userInput)
            let parameters = GenerateParameters(temperature: 0.7)

            return try MLXLMCommon.generate(input: lmInput, parameters: parameters, context: context)
        }
    }
}
