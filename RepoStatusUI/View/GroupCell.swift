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
    
    @ObservedObject var group: RepoGroup
    @State var requestNewRepo = false

    var body: some View {
        VStack {
            HStack {
                groupTitle()
                Spacer()
                addButton()
            }
            .padding([.leading, .top, .bottom], 4)
            .cornerRadius(4)
            .fileImporter(isPresented: $requestNewRepo,
                          allowedContentTypes: ImportedFileTypes,
                          allowsMultipleSelection: false,
                          onCompletion: { result in
                importFile(from: result)
            })
            repoList()
        }
    }
    
    func addRepos(in urls: [URL]) {
        for u in urls {
            let r = Repo(url: u)
            group.add(r)
        }
    }
}

// MARK: - Private
extension GroupCell {
    func importFile(from result: Result<[URL], Error>) {
        switch result {
            case .success(let urls):
                addRepos(in: urls)
            case .failure(let error):
                print(error.localizedDescription)
        }
    }
}

// MARK: - View Builders
extension GroupCell {
    
    @ViewBuilder
    func repoList() -> some View {
        ForEach(group.repos) { repo in
            VStack {
                RepoCell(repo: repo)
                separator()
            }
            .padding(.leading, 16)
        }
    }

    @ViewBuilder
    func separator() -> some View {
        Rectangle()
            .frame(height: 1)
            .opacity(0.1)
    }
    
    @ViewBuilder
    func groupTitle() -> some View {
        Text("\(group.displayName)")
            .font(.title3)
            .foregroundColor(.groupText)
    }
    
    @ViewBuilder
    func addButton() -> some View {
        Button(action: { requestNewRepo = true },
               label: { bigAddImage() })
        .buttonStyle(BorderlessButtonStyle())
        .tint(.accentColor)
    }
    
    @ViewBuilder
    func bigAddImage() -> some View {
        Image(systemName: "plus")
            .resizable()
            .frame(width: 14, height: 14)
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
