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

    @ObservedObject var group: RepoGroup
    @State var requestNewRepo = false

    var body: some View {
        VStack {
            HStack {
                Text("\(group.displayName)")
                    .font(.title3)
                    .foregroundColor(.groupText)
                Spacer()

                Button(action: { requestNewRepo = true },
                       label: { Image(systemName: "plus") })
                .buttonStyle(BorderlessButtonStyle())
                .tint(.accentColor)
                .padding(.trailing, 4)
            }
            .padding([.leading, .top, .bottom], 4)
            .cornerRadius(4)
            .fileImporter(isPresented: $requestNewRepo,
                          allowedContentTypes: [UTType.folder, UTType.directory],
                          allowsMultipleSelection: false,
                          onCompletion: { result in
                switch result {
                    case .success(let urls):
                        addRepos(in: urls)
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            })

            ForEach(group.repos) { repo in
                VStack {
                    RepoCell(repo: repo)
                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.1)
                }
                .padding(.leading, 16)
            }
        }
    }
    
    func addRepos(in urls: [URL]) {
        for u in urls {
            let r = Repo(url: u)
            group.add(r)
        }
    }
}

