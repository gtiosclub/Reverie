//
//  TabState.swift
//  Reverie
//
//  Created by Zhihui Chen on 10/22/25.
//
import SwiftUI
import Combine

enum TabType {
    case home
    case analytics
    case archive
    case none
}

final class TabState: ObservableObject {
    static let shared = TabState()
    var activeTab: TabType = .home
}
