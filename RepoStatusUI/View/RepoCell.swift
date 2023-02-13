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
                branchName()
                    .padding(.trailing, 8)
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
            .foregroundColor(.repoName)
    }
    
    @ViewBuilder
    private func branchName() -> some View {
        HStack {
            Image(systemName: "arrow.triangle.branch")
            Text("\(repo.status.branch)")
                .font(.body)
        }
        .foregroundColor(.branchName)
    }
    
    @ViewBuilder
    private func status() -> some View {
        Text("\(repo.status.asString)")
            .font(Font.system(.body).monospaced())
            .foregroundColor(.statusItems)
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
            .frame(width: 18)
    }
    
    @ViewBuilder
    private func infoPopover() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Path:")
                Text("\(repo.url.path())")
                    .textSelection(.enabled)
            }
            Button("Show in Finder", action: { showInFinder() } )
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }
    
    private func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([repo.url])
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
