//
//  ContentView.swift
//  ComposableArchitectureSharingTest
//
//  Created by Yan Smaliak on 15/12/2024.
//

import ComposableArchitecture
import SwiftUI

struct Dummy: Identifiable, Codable {
    let id: UUID
    let value: String
}

extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<Dummy>>.Default {
    static var dummies: Self {
        Self[.fileStorage(.documentsDirectory.appending(component: "dummy.json")), default: []]
    }
}

@Reducer
struct ContentFeature {
    @ObservableState
    struct State {
        @Shared(.dummies) var dummies: IdentifiedArrayOf<Dummy>
        var strings: [String] = []
    }

    enum Action {
        case onAppear
        case addButtonTapped
        case clearButtonTapped
        case stringGenerated(String)
    }

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return generateStrings()

            case .addButtonTapped:
                let id = UUID()
                let dummy = Dummy(id: id, value: "Dummy \(id.uuidString)")
                state.$dummies.withLock { $0[id: dummy.id] = dummy }
                return .none

            case .clearButtonTapped:
                state.$dummies.withLock { $0.removeAll() }
                return .none

            case .stringGenerated(let text):
                state.strings.append(text)
                return .none
            }
        }
    }

    private func generateStrings() -> Effect<Action> {
        .run { send in
            await send(.stringGenerated("Message 0"))

            let inspiringMessages = ["Message 1", "Message 2", "Message 3", "Message 4", "Message 5"]
            for message in inspiringMessages {
                try await clock.sleep(for: .seconds(3))
                await send(.stringGenerated(message))
            }
        }
    }
}

struct ContentView: View {
    @Bindable var store: StoreOf<ContentFeature>

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(store.dummies) { dummy in
                    VStack {
                        Text(dummy.value)
                    }
                }
            }

            Divider()

            List {
                ForEach(store.strings, id: \.self) { text in
                    Text(text)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    store.send(.addButtonTapped)
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button("Clear", role: .destructive) {
                    store.send(.clearButtonTapped)
                }
                .tint(.red)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
