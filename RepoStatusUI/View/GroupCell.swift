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
    
    func addRepos(in urls: [URL]) {
        for u in urls {
            let r = Repo(url: u)
            repoCollection.add(r, to: group)
        }
    }
}

// MARK: - Private
extension GroupCell {
    private func importRepos(from urls: [URL]?) {
        guard let urls else { return }
        addRepos(in: urls)
    }
    
    private func requestRepoPath() {
        showOpenSheet = true
    }
    
    private func rename() {
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
        ForEach(group.repos) { repo in
            VStack {
                RepoCell(repo: repo)
                separator()
            }
            .padding(.leading, 16)
        }
    }

    @ViewBuilder
    private func groupTitle() -> some View {
        HStack {
            Text("\(group.name)")
                .contextMenu {
                    Button("Add Repo...", action: { requestRepoPath() })
                    Button("Rename Group...", action: { rename() })
                    Section {
                        Button("Remove Group", action: { remove() })
                    }
                }
        }
        .badge(group.repos.count)
    }
    
    @ViewBuilder
    private func separator() -> some View {
        Rectangle()
            .frame(height: 1)
            .opacity(0.1)
    }
}

struct GrooupCell_Previews: PreviewProvider {
    static let group = RepoGroup(name: "Test Group")
    
    static var previews: some View {
        GroupCell(group: group)
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
            .frame(width: 400)
    }
}
