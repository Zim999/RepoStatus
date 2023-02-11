//
//  ContentView.swift
//  RepoStatusUI
//
//  Created by Beavis, Simon on 19/01/23.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var repoCollection: RepoCollection
    
    var body: some View {
        ZStack {
            windowBackground()
            
            VStack(alignment: .leading) {
                repoList()
                    .padding(.bottom, -8)
                statusBar()
            }
            .toolbar(content: {
                toolbarButtons()
            })
            .task(priority: .background) {
                refresh()
            }
        }
    }

    @ViewBuilder
    func windowBackground() -> some View {
        Rectangle()
            .foregroundColor(.appBackground)
    }
    
    @ViewBuilder
    func repoList() -> some View {
        List {
            ForEach(repoCollection.groups) { group in
                GroupCell(group: group)
            }
        }
    }
    
    @ViewBuilder
    func statusBar() -> some View {
        Text("\(repoCollection.groups.count) Groups, \(repoCount()) Repos")
            .padding(8)
    }

    func toolbarButtons() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .automatic, content: {
                Button(action: { /* fetch */ }, label: { Image(systemName: "arrow.down") })
                Button(action: { /* Pull */ }, label: { Image(systemName: "arrow.down.to.line") })
            })
            ToolbarItemGroup(placement: .automatic, content: {
                Button(action: { refresh() },
                       label: { Image(systemName: "arrow.clockwise") })
            })
        }
    }

    func repoCount() -> Int {
        var count = 0
        repoCollection.groups.forEach { count += $0.repos.count }
        return count
    }

    func refresh() {
        repoCollection.refreshAllAsync()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
            .frame(width: 400)
    }
}
