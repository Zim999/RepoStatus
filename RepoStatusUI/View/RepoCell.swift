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
                Text("\(repo.name)")
                    .font(.body)
                    .foregroundColor(.repoName)
                Text("\(repo.status.branch)")
                    .font(.body)
                    .foregroundColor(.branchName)
            }
            Spacer()
            Text("\(repo.status.asString)")
                .font(Font.system(.body).monospaced())
                .foregroundColor(.statusItems)
            Button(action: { },
                   label: { Image(systemName: "info.circle") })
            .buttonStyle(.borderless)
            .tint(.accentColor)
        }
    }
}
