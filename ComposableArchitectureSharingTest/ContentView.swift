//
//  ContentView.swift
//  ComposableArchitectureSharingTest
//
//  Created by Yan Smaliak on 15/12/2024.
//

import Sharing
import SwiftUI

struct Dummy: Identifiable, Codable {
    let id: UUID
    let value: String
}

extension SharedKey where Self == FileStorageKey<[Dummy]>.Default {
    static var dummies: Self {
        Self[.fileStorage(.documentsDirectory.appending(component: "dummy.json")), default: []]
    }
}

@MainActor
@Observable
final class ContentViewModel {
    @ObservationIgnored @Shared(.dummies) var dummies: [Dummy] = []
    var strings: [String] = []

    func onAppear() {
        Task {
            await generateStrings()
        }
    }

    func addDummy() {
        let id = UUID()
        let dummy = Dummy(id: id, value: "Dummy \(id.uuidString)")
        $dummies.withLock { $0.append(dummy) }
    }

    func clearDummies() {
        $dummies.withLock { $0.removeAll() }
    }

    private func generateStrings() async {
        strings.append("Message 0")

        let inspiringMessages = ["Message 1", "Message 2", "Message 3", "Message 4", "Message 5"]
        for message in inspiringMessages {
            try? await Task.sleep(for: .seconds(3))
            strings.append(message)
        }
    }
}

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.dummies) { dummy in
                    VStack {
                        Text(dummy.value)
                    }
                }
            }

            Divider()

            List {
                ForEach(viewModel.strings, id: \.self) { text in
                    Text(text)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    viewModel.addDummy()
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button("Clear", role: .destructive) {
                    viewModel.clearDummies()
                }
                .tint(.red)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
