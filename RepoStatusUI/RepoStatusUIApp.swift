//
//  RepoStatusUIApp.swift
//  RepoStatusUI
//
//  Created by Beavis, Simon on 19/01/23.
//

import SwiftUI

@main
struct RepoStatusUIApp: App {

    var repoCollection = RepoCollection(from: AppSettings.collectionStoreFileURL)

    var body: some Scene {
        WindowGroup {
            BaseWindowView()
                .environmentObject(repoCollection)
                .frame(minWidth: 250, minHeight: 250)
        }
        .commands {
            CommandMenu("Repos") {
                Button("Fetch", action: { })
                Button("Pull", action: { })
            }
        }
    }
}
