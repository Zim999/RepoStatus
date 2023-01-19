//
//  RepoCollectionItem.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 19/01/23.
//

import Foundation

/// To be implemented by all items in a RepoCollection (individual Repo and RepoGroup objects)
protocol RepoCollectionItem: Identifiable {
    var id: UUID { get }
    var name: String { get }

    func pull() -> Bool
}
