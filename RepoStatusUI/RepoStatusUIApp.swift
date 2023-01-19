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
            ContentView()
                .environmentObject(repoCollection)
        }
    }
}
