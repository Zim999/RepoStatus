//
//  GroupCell.swift
//  RepoStatusUI
//
//  Created by Simon Beavis on 11/02/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct GroupCell: View {
    let ImportedFileTypes = [UTType.folder, UTType.directory]

    @AppStorage("expansionState") var expansionState = ExpansionState()

    @EnvironmentObject var repoCollection: RepoCollection
    @ObservedObject var group: RepoGroup
    @State var showOpenSheet = false
    @State var popoverShown = false
    var filterText = ""
    
    var isSelected: Bool
    
    var body: some View {
        DisclosureGroup(isExpanded: $expansionState[group.id],
                        content: { repoList() },
                        label: { groupTitle() }
        )
        .fileImporter(isPresented: $showOpenSheet,
                      allowedContentTypes: ImportedFileTypes,
                      allowsMultipleSelection: false,
                      onCompletion: { result in
            importRepos(from: try? result.get())
        })
    }
}

// MARK: - Private
extension GroupCell {
    private func importRepos(from urls: [URL]?) {
        guard let urls else { return }

        for u in urls {
            let r = Repo(url: u)
            repoCollection.add(r, to: group)
        }
    }

    private func requestRepoPath() {
        showOpenSheet = true
    }
    
    private func rename() {
        // ...
    }

    private func fetch() {
        // ...
    }

    private func pull() {
        // ...
    }

    private func refresh() {
        // ...
    }

    private func remove() {
        repoCollection.remove(group)
    }
}

// MARK: - View Builders
extension GroupCell {
    
    @ViewBuilder
    private func repoList() -> some View {
        let repos = r()
        
        if repos.isEmpty {
            Text("No matching repos")
                .padding(.leading, 16)
        }
        else {
            ForEach(repos) { repo in
                VStack(alignment: .leading) {
                    RepoCell(repo: repo)
                }
                .padding(.leading, 16)
            }
        }
    }
    
    func r() -> [Repo] {
        if filterText.isEmpty {
            return group.repos
        }
        else {
            return group.repos.filter {
                $0.name.localizedStandardContains(filterText)
            }
        }
    }
 
    @ViewBuilder
    private func groupTitle() -> some View {
        HStack {
            Label(group.name, systemImage: "folder")
                .contextMenu {
                    Section {
                        Button("Fetch", action: { fetch() })
                        Button("Pull", action: { pull() })
                    }
                    Section {
                        Button("Refresh", action: { refresh() })
                    }
                    Section {
                        Button("Add Repo...", action: { requestRepoPath() })
                        Button("Rename Group...", action: { rename() })
                    }
                    Section {
                        Button("Remove Group", action: { remove() })
                    }
                }
            badge()
        }
    }
    
    @ViewBuilder
    private func separator() -> some View {
        Rectangle()
            .frame(height: 1)
            .opacity(0.1)
    }
    
    @ViewBuilder
    private func badge() -> some View {
        ZStack {
            Circle()
                .opacity(0.05)
            Text("\(group.repos.count)")
                .font(.system(size: 11))
                .opacity(0.7)
        }
        .frame(width: 18, height: 18)
    }
}

struct GrooupCell_Previews: PreviewProvider {
    static let group = RepoGroup(name: "Test Group")
    
    static var previews: some View {
        GroupCell(group: group, isSelected: true)
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
            .frame(width: 400)
    }
}
