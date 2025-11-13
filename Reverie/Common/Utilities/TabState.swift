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
    
//    var index: Int {
//        switch self {
//        case .home: return 0
//        case .analytics: return 1
//        case .archive: return 2
//        case .none: return 3
//        }
//    }
}

final class TabState: ObservableObject {
    static let shared = TabState()
    var activeTab: TabType = .home
}
