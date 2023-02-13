//
//  RepoGroup.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation
import Combine

/// A named collection of Repo's
class RepoGroup: Codable, RepoCollectionItem, ObservableObject {

    /// Name for group
    @Published var name : String

    /// Unique identifier for group. Preserved between execution of app
    var id: UUID
    
    /// Repos contained in this group
    @Published var repos = [Repo]()

    /// Initialise a RepoGroup with the specified name
    /// - Parameter name: The group name
    init(name: String) {
        self.id = UUID()
        self.name = name
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case repos
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.repos = try container.decode([Repo].self, forKey: .repos)
    }

    /// Refresh the status of all repos in the group
    func refresh() {
        repos.forEach( { $0.refresh() })
    }
    
    /// Add a repo to the group
    /// - Parameter repo: Repo to add
    func add(_ repo: Repo) {
        repos.append(repo)
        sort()
    }
    
    /// Remove a repo from the group
    /// - Parameter repo: The repo to remove
    func remove(_ repo: Repo) {
        if let idx = repos.firstIndex(of: repo) {
            repos.remove(at: idx)
        }
    }

    /// Tests whether this group contains the specified repo
    /// - Parameter repo: Repo to test for
    /// - Returns: True if the group contains the repo, otherwise false
    func contains(_ repo: Repo) -> Bool {
        return repos.contains(repo)
    }

    /// Returns the first repo is the group that has the specified name, or nil if the group
    /// does not contain a repo with the specified name
    /// - Parameter repoName: Name of the repo to find
    /// - Returns: A repo with the specified name, or nil
    func repo(named repoName: String) -> Repo? {
        for repo in repos {
            if repo.name == repoName {
                return repo
            }
        }
        return nil
    }

    /// Performs a git pull on all repos in the group
    /// - Returns: true
    func pull() -> Bool {
        repos.forEach( { _ = $0.pull() })
        return true
    }
}

extension RepoGroup {
    private func sort() {
        repos.sort { lhs, rhs in
            lhs.name.localizedCompare(rhs.name) == .orderedAscending
        }
    }
}

extension RepoGroup: Equatable {
    public static func == (lhs: RepoGroup, rhs: RepoGroup) -> Bool {
        return lhs.name == rhs.name
    }
}

extension RepoGroup {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(repos, forKey: .repos)
    }
}


