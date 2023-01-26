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
        VStack(alignment: .leading) {

            List {
                ForEach(repoCollection.groups) { group in
                    GroupCell(group: group)
                }
                .listRowBackground(Color.listBackground)
            }
            .background(Color.listBackground)
            .scrollContentBackground(.hidden)
            .cornerRadius(8)

            HStack {
                Text("\(repoCollection.groups.count) Groups, \(repoCount()) Repos")
            }
        }
        .padding()
        .background(Color.appBackground)
        .toolbar(content: {
            ToolbarItemGroup(placement: .automatic, content: {
                Button(action: { }, label: { Image(systemName: "arrow.down") })
                Button(action: { }, label: { Image(systemName: "arrow.down.to.line") })
            })
            ToolbarItemGroup(placement: .automatic, content: {
                Button(action: { refresh() },
                       label: { Image(systemName: "arrow.clockwise") })
            })
        })
//        .task(priority: .background) {
//            repoCollection.forEach(in: nil, group: nil) { repo in
//                repo.refresh(fetching: true)
//            }
//        }
    }

    func repoCount() -> Int {
        var count = 0
        repoCollection.groups.forEach { count += $0.repos.count }
        return count
    }

    func refresh() {
        repoCollection.forEach(perform: { $0.refresh() })
    }

}
struct GroupCell: View {

    @ObservedObject var group: RepoGroup

    var body: some View {
        VStack {
            HStack {
                Group {
                    Text("\(group.displayName)" )
                    Spacer()
                    Text("\(group.repos.count)")
                }
                .foregroundColor(.groupText)

                Button(action: {},
                       label: {
                    Image(systemName: "pencil")
                })
                .buttonStyle(BorderlessButtonStyle())
                .tint(.accentColor)
                .padding(.trailing, 4)
            }
            .padding([.leading, .top, .bottom], 4)
            .background(Color.groupBackground)
            .cornerRadius(4)

            let columns = [GridItem(.flexible(minimum: 50)),
                           GridItem(.fixed(100)),
                           GridItem(.fixed(50)) ]

            LazyVGrid(columns: columns,
                      alignment: .trailing,
                      spacing: 4.0,
                      content: {
                ForEach(group.repos) { repo in
                    RepoCell(repo: repo)
                }

            } )
        }
    }
}

struct RepoCell: View {
    @ObservedObject var repo: Repo

    var body: some View {
        Text("\(repo.name)")
        Text("- - - - - -")
        Text("\(repo.status.branch)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
    }
}
