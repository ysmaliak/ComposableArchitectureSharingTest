//
//  AppView.swift
//  ComposableArchitectureSharingTest
//
//  Created by Yan Smaliak on 15/12/2024.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var content = ContentFeature.State()
    }

    enum Action {
        case content(ContentFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .content:
                .none
            }
        }
        ._printChanges()

        Scope(state: \.content, action: \.content) {
            ContentFeature()
        }
    }
}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack {
            ContentView(store: store.scope(state: \.content, action: \.content))
        }
    }
}
