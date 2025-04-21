//
//  LMModel.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 21.04.2025.
//

import MLXLMCommon

struct LMModel {
    let name: String
    let configuration: ModelConfiguration
    let type: ModelType

    enum ModelType {
        case llm
        case vlm
    }
}

// - MARK: Helpers

extension LMModel {
    var displayName: String {
        if isVisionModel {
            "\(name) (Vision)"
        } else {
            name
        }
    }

    var isLanguageModel: Bool {
        type == .llm
    }

    var isVisionModel: Bool {
        type == .vlm
    }
}

extension LMModel: Identifiable, Hashable {
    var id: String {
        name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
