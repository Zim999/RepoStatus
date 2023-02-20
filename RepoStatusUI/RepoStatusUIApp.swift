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
    @AppStorage("compactView") var compactView = false
    @AppStorage("listSelection") var selection: UUID? {
        didSet {
            
        }
    }

    var body: some Scene {
        WindowGroup {
            BaseWindowView(selection: $selection)
                .environmentObject(repoCollection)
                .frame(minWidth: 250, minHeight: 250)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: {})

            CommandGroup(replacing: .toolbar, addition: {
                Toggle("Compact View", isOn: $compactView)
                Divider()
            })


            CommandMenu("Groups") {
                Button("Add Group...", action: { /* ... */ })
            }

            CommandMenu("Repository") {
                Button("Fetch", action: { repoCollection.fetchAllAsync() })
                Button("Pull", action: { repoCollection.pullAllAsync() })
            }
        }
        
    }
}
