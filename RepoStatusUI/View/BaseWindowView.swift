//
//  BaseWindowView.swift
//  RepoStatusUI
//
//  Created by Beavis, Simon on 19/01/23.
//

import SwiftUI

struct BaseWindowView: View {
    
    @EnvironmentObject var repoCollection: RepoCollection
    
    var body: some View {
        VStack(alignment: .leading) {
            repoList()
        }
        .toolbar(content: {
            toolbarButtons()
        })
        .task(priority: .background) {
            refresh()
        }
    }
}

// MARK: - Private

extension BaseWindowView {
    private func refresh() {
        repoCollection.refreshAllAsync()
    }
    
    private func fetch() {
        repoCollection.fetchAllAsync()
    }
    
    private func pull() {
        repoCollection.pullAllAsync()
    }
}

// MARK: - View Builders

extension BaseWindowView {
    @ViewBuilder
    private func repoList() -> some View {
        List {
            ForEach(repoCollection.groups) { group in
                GroupCell(group: group)
            }
        }
    }
    
    private func toolbarButtons() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .automatic, content: {
                fetchButton()
                pullButton()
            })
            ToolbarItemGroup(placement: .automatic, content: {
                refreshButton()
            })
        }
    }

    @ViewBuilder
    private func fetchButton() -> some View {
        Button(action: { fetch() },
               label: { Image(systemName: "arrow.down") })
    }

    @ViewBuilder
    private func pullButton() -> some View {
        Button(action: { pull() },
               label: { Image(systemName: "arrow.down.to.line") })
    }

    @ViewBuilder
    private func refreshButton() -> some View {
        Button(action: { refresh() },
               label: { Image(systemName: "arrow.clockwise") })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BaseWindowView()
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
            .frame(width: 400)
    }
}
