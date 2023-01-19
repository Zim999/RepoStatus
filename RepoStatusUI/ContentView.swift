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
            HStack {
                Text("RepoStatus")
                Group {
                    Spacer()
                    Button(action: {} , label: { Text("Fetch") })
                    Button(action: {} , label: { Text("Pull") })
                    Spacer()
                    Button(action: {
                        Task {
                            repoCollection.forEach(in: nil, group: nil, repo: { $0.refresh(fetching: false) })
                        }
                    },
                           label: { Image(systemName: "arrow.clockwise") })
                }
            }

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
//        .task {
//            repoCollection.forEach(in: nil, group: nil, repo: { $0.refresh(fetching: false) })
//        }
    }

    func repoCount() -> Int {
        var count = 0
        repoCollection.groups.forEach { count += $0.repos.count }
        return count
    }
}

//extension NSTableView {
//    open override func viewDidMoveToWindow() {
//        super.viewDidMoveToWindow()
//
//        backgroundColor = NSColor.clear
//        enclosingScrollView!.drawsBackground = false
//    }
//}

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

            ForEach(group.repos) { repo in
                RepoCell(repo: repo)
            }
        }
    }
}

struct RepoCell: View {

    @ObservedObject var repo: Repo

    var body: some View {
        HStack {
            Text("\(repo.name)")
            Spacer()
            Text("- - - - - -")
            Text("\(repo.status.branch)")
        }
        .padding(2)
        .padding([.leading, .trailing])
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
    }
}
