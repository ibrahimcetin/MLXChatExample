//
//  HubApi+default.swift
//  MLXChatExample
//
//  Created by İbrahim Çetin on 21.04.2025.
//

import Foundation
@preconcurrency import Hub

extension HubApi {
    static let `default` = HubApi(downloadBase: URL.downloadsDirectory.appending(path: "huggingface"))
}
