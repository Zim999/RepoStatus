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
    @AppStorage("selection") var selection: UUID?
    
    var body: some Scene {
        WindowGroup {
            Group {
                BaseWindowView(selection: $selection)
                    .environmentObject(repoCollection)
                    .frame(minWidth: 250, minHeight: 250)
                    .onAppear {
                        NSWindow.allowsAutomaticWindowTabbing = false
                    }
            }
            .environmentObject(repoCollection)
        }
        .commands {
            self.menuCommands
        }
    }
    
    @CommandsBuilder
    var menuCommands: some Commands {
        CommandGroup(replacing: .newItem, addition: {})

        CommandMenu("Group") {
            Button("New Group...", action: { addGroup() })
                .keyboardShortcut(KeyEquivalent("g"), modifiers: .command )
            Divider()
            Group {
                Button("Fetch", action: {  })
                    .keyboardShortcut(KeyEquivalent("f"), modifiers: .command )
                Button("Pull", action: {  })
                    .keyboardShortcut(KeyEquivalent("p"), modifiers: .command )
                Divider()
                Button("Add Repo to Group...", action: {  })
                Button("Rename...", action: {  })
                Divider()
                Button("Remove...", action: {  })
                    .keyboardShortcut(KeyEquivalent.delete, modifiers: .command )
            }
            .disabled(!aGroupIsSelected)
        }
        
        CommandMenu("Repo") {
            Group {
                Button("Fetch", action: { repoCollection.fetchAllAsync() })
                    .keyboardShortcut(KeyEquivalent("f"), modifiers: .command )
                Button("Pull", action: { repoCollection.pullAllAsync() })
                    .keyboardShortcut(KeyEquivalent("p"), modifiers: .command )
                Divider()
                Button("Remove...", action: {  })
                    .keyboardShortcut(KeyEquivalent.delete, modifiers: .command )
            }
            .disabled(!aRepoIsSelected)
        }
    }
    
    private func addGroup() {
        // ...
    }
    
    private var aGroupIsSelected: Bool {
        guard let selection else { return false }
        return repoCollection.group(with: selection) != nil
    }
    
    private var aRepoIsSelected: Bool {
        guard let selection else { return false }
        return repoCollection.repo(with: selection) != nil
    }
}
