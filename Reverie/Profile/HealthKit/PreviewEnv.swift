//
//  PreviewEnv.swift
//  Reverie
//
//  Created by Abhiram Raju on 11/11/25.
//


import Foundation
enum PreviewEnv {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
