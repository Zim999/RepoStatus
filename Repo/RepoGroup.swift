//
//  RepoGroup.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

/// Represents a group of Repo's
class RepoGroup: Codable, RepoCollectionItem {
    /// Display name for group
    var name : String
    
    /// Unique identifier for group. Preserved between execution of app
    var uuid: UUID
    
    /// Repos contained in this group
    var repos = [Repo]()

    init(name: String) {
        self.name = name
        self.uuid = UUID()
    }
    
    /// Refresh the status of all repos in the group
    func refresh() {
        repos.forEach( { $0.refresh() })
    }
    
    /// Add a repo to the group
    /// - Parameter repo: Repo to add
    func add(_ repo: Repo) {
        repos.append(repo)
    }
    
    /// Remove a repo from the group
    /// - Parameter repo: The repo to remove
    func remove(_ repo: Repo) {
        if let idx = repos.firstIndex(of: repo) {
            repos.remove(at: idx)
        }
    }
    
    func contains(_ repo: Repo) -> Bool {
        return repos.contains(repo)
    }

    func repo(named repoName: String) -> Repo? {
        for repo in repos {
            if repo.name == repoName {
                return repo
            }
        }
        return nil
    }

    func pull() -> Bool {
        repos.forEach( { _ = $0.pull() })
        // ...
        return true
    }
}

extension RepoGroup: Equatable {
    public static func == (lhs: RepoGroup, rhs: RepoGroup) -> Bool {
        return lhs.name == rhs.name
    }
}
