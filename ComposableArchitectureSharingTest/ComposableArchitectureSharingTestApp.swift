//
//  ComposableArchitectureSharingTestApp.swift
//  ComposableArchitectureSharingTest
//
//  Created by Yan Smaliak on 15/12/2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct ComposableArchitectureSharingTestApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppFeature.State(), reducer: { AppFeature() }))
        }
    }
}
