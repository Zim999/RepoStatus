//
//  RepoCell.swift
//  RepoStatusUI
//
//  Created by Simon Beavis on 11/02/23.
//

import Foundation
import SwiftUI

struct RepoCell: View {
    @ObservedObject var repo: Repo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                repoName()
                branchName()
            }
            Spacer()
            status()
            infoButton()
        }
    }
}

// MARK: - View Builders

extension RepoCell {
    @ViewBuilder
    func repoName() -> some View {
        Text("\(repo.name)")
            .font(.body)
            .foregroundColor(.repoName)
    }
    
    @ViewBuilder
    func branchName() -> some View {
        HStack {
            Image(systemName: "arrow.triangle.branch")
            Text("\(repo.status.branch)")
                .font(.body)
        }
        .foregroundColor(.branchName)
    }
    
    @ViewBuilder
    func status() -> some View {
        Text("\(repo.status.asString)")
            .font(Font.system(.body).monospaced())
            .foregroundColor(.statusItems)
    }
    
    @ViewBuilder
    func infoButton() -> some View {
        Button(action: { },
               label: { Image(systemName: "info.circle") })
        .buttonStyle(.borderless)
        .tint(.accentColor)
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
