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
        VStack {
            HStack {
                Text("Header")
            }

            List {
                ForEach(repoCollection.groups) { group in
                    Text("\(group.name): \(group.repos.count)" )
                }
            }

            HStack {
                Text("Footer")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RepoCollection(from: AppSettings.collectionStoreFileURL))
    }
}
