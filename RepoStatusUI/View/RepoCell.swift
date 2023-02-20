//
//  RepoCell.swift
//  RepoStatusUI
//
//  Created by Simon Beavis on 11/02/23.
//

import Foundation
import SwiftUI

struct RepoCell: View {
    @EnvironmentObject var repoCollection: RepoCollection
    @AppStorage("compactView") var compactView = false

    @ObservedObject var repo: Repo
    @State var infoPopoverShown = false
    
    var body: some View {
        HStack {
            if compactView {
                repoName()
                Spacer()
                if repo.status.isValid {
                    branchName()
                        .padding(.trailing, 8)
                }
            }
            else {
                VStack(alignment: .leading) {
                    repoName()
                    branchName()
                }
                Spacer()
            }

            if repo.status.error {
                ErrorMessageView(message: repo.status.errorMessage)
            }
            else if repo.status.isValid {
                status()
            }
            else {
                ErrorMessageView(message: "Invalid Repo", kind: .warning)
            }
            
            infoButton()
        }
        .contextMenu {
            Button("Fetch", action: { fetch() })
            Button("Pull", action: { pull() })
            Section {
                Button("Remove \(repo.name)", action: { remove() })
            }
        }
    }
}

extension RepoCell {
    private func fetch() {
        _ = repo.fetch()
    }
    
    private func pull() {
        _ = repo.pull()
    }
    
    private func remove() {
        repoCollection.remove(repo)
    }
}

// MARK: - View Builders

extension RepoCell {
    @ViewBuilder
    private func repoName() -> some View {
        Text("\(repo.name)")
            .font(.body)
            .lineLimit(1)
            .truncationMode(.tail)
            .help(repo.name)
            .layoutPriority(0.1)
    }
    
    @ViewBuilder
    private func branchName() -> some View {
        HStack {
            Image(systemName: "arrow.triangle.branch")
            Text("\(repo.status.branch)")
                .font(.body)
                .foregroundColor(.branchName)
        }
        .padding(4)
        .padding([.leading, .trailing], 8)
        .foregroundColor(.branchName)
        .background(Color.branchNameBackground)
        .cornerRadius(8)
        .truncationMode(.tail)
        .lineLimit(1)
        .help(repo.status.branch)
    }
    
    @ViewBuilder
    private func status() -> some View {
        Text("\(repo.status.asString)")
            .font(Font.system(.body).monospaced())
            .padding(4)
            .padding([.leading, .trailing], 8)
            .foregroundColor(.statusItems)
            .background(Color.statusItemsBackground)
            .cornerRadius(8)
            .lineLimit(1)
            .layoutPriority(1)
    }
    
    @ViewBuilder
    private func infoButton() -> some View {
        Button(action: { infoPopoverShown = true },
               label: { infoIcon() })
        .buttonStyle(.borderless)
        .tint(.accentColor)
        .popover(isPresented: $infoPopoverShown,
                 arrowEdge: .trailing,
                 content: { infoPopover() })
    }

    @ViewBuilder
    private func infoIcon() -> some View {
        Image(systemName: "info.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 16, height: 16)
    }
    
    @ViewBuilder
    private func infoPopover() -> some View {
        VStack(alignment: .leading) {
            if repo.status.isValid {
                if repo.status.error {
                    Text("Error: \(repo.status.errorMessage)")
                }
                else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Modified:")
                            Text("Added:")
                            Text("Untracked:")
                            Text("Stashed:")
                            Text("Ahead:")
                            Text("Behind:")
                        }
                        VStack(alignment: .leading) {
                            Text(repo.status.contains(.modifiedFiles).string)
                            Text(repo.status.contains(.addedFiles).string)
                            Text(repo.status.contains(.newUntrackedFiles).string)
                            Text(repo.status.hasStash.string)
                            Text("\(repo.status.aheadCount)")
                            Text("\(repo.status.behindCount)")
                        }

                    }
                }
            }
            Divider()
            HStack {
                Text("Path:")
                Text("\(repo.url.path())")
                    .textSelection(.enabled)
                    .frame(maxWidth: 500)
            }
            Button("Show in Finder", action: { showInFinder() } )

        }
        .padding()
        .buttonStyle(.bordered)
    }
    
    private func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([repo.url])
    }
}

extension Bool {
    var string: String {
        self ? "Yes" : "No"
    }
}

struct RepoCell_Previews: PreviewProvider {
    static let repo = Repo(url: URL(string: "file:////Users/sjb/Source/RepoStatus")!)
    
    static var previews: some View {
        RepoCell(repo: repo)
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
            .frame(width: 300)
    }
}
