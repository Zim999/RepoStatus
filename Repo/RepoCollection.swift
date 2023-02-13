//
//  RepoCollection.swift
//  GitMon
//
//  Created by Simon Beavis on 10/6/20.
//

import Foundation
import Combine

/// Holds a list of RepoGroups, each containing Repos
class RepoCollection: ObservableObject {
    private var storageFileURL: URL
    static let DefaultGroupName = "Repos"

    // MARK: - Properties

    /// Groups in the collection
    @Published var groups = [RepoGroup]()
    
    /// Is the collection empty
    var isEmpty: Bool {
        return groups.count == 0
    }

    // MARK: - Public

    /// Initialise the collection from a JSON file at the given file URL
    /// - Parameter url: File URL to load the collecrtion configuration from
    init(from url: URL) {
        storageFileURL = url
        createConfigStorageFolder()
        
        if load() && groups.count == 0 {
            addDefaultGroup()
        }
    }
    
    func refreshAllAsync() {
        // TODO: Should refresh more than one at a time...
        // ...
        Task {
            forEach { repo in
                repo.refresh()
            }
        }
    }

    func fetchAllAsync() {
        // TODO: Should refresh more than one at a time...
        // ...
        Task {
            forEach { repo in
                _ = repo.fetch()
                repo.refresh(fetching: false)
            }
        }
    }

    func pullAllAsync() {
        // TODO: Should refresh more than one at a time...
        // ...
        Task {
            forEach { repo in
                _ = repo.pull()
                repo.refresh(fetching: false)
            }
        }
    }

    /// Add a group to the collection
    /// - Parameter group: Group to add
    func add(_ group: RepoGroup) {
        groups.append(group)
        sort()

        _ = save()
    }

    /// Add a new repo to the specified repo group
    /// - Parameters:
    ///   - repo: Repo to add
    ///   - repoGroup: Group to add the repo to
    func add(_ repo: Repo, to repoGroup: RepoGroup) {
        repoGroup.add(repo)
        _ = save()
    }
    
    /// Remove a group, and its contents, from the collection.
    /// - Parameter group: Group to remove
    func remove(_ group: RepoGroup) {
        if let idx = groups.firstIndex(of: group) {
            groups.remove(at: idx)
            _ = save()
        }
    }

    /// Remove the repo from the collection
    /// - Parameters:
    ///   - repo: Repo to remove
    func remove(_ repo: Repo) {
        for group in groups {
            if group.contains(repo) {
                group.remove(repo)
            }
        }
        _ = save()
    }
    
    /// Finds the item, RepoGroup or Repo, in the collection, with the
    /// specifid UUID.
    /// - Parameter uuid: Identifier of the item to find
    /// - Returns: The item, or nil if no item with the UUID is in the collection
    func item(with uuid: UUID) -> (any RepoCollectionItem)? {
        for group in groups {
            if group.id == uuid {
                return group
            }
            for repo in group.repos {
                if repo.id == uuid {
                    return repo
                }
            }
        }

        return nil
    }

    /// Return all repos with the specified name
    /// - Parameter named: Name of the repos to find
    /// - Returns: Optional array of repos with matching name
    func repos(named: String) -> [Repo]? {
        var repos = [Repo]()

        for group in groups {
            for repo in group.repos {
                if repo.name == named {
                    repos.append(repo)
                }
            }
        }

        return repos.isEmpty ? nil : repos
    }

    /// Tests whether the collection contains a group with the specified name
    /// - Parameter groupName: Group name to test
    /// - Returns: True if the collection contains a group with the name, false if it does not
    func contains(_ groupName: String) -> Bool {
        return groups.contains { existingGroup in
            existingGroup.name == groupName
        }
    }

    /// Return the group with the specified name
    /// - Parameter groupName: Name of the group to find
    /// - Returns: The group with the specified name, or nil if no group has that name
    func group(named groupName: String) -> RepoGroup? {
        for group in groups {
            if group.name == groupName {
                return group
            }
        }
        return nil
    }

    /// Return the groups that have any of the specified names
    /// - Parameter groupNames: The group names to find
    /// - Returns: Array of groups matching the names
    func groups(named groupNames: [String]) -> [RepoGroup] {
        var results = [RepoGroup]()
        
        for group in groups {
            if groupNames.contains(group.name) {
                results.append(group)
            }
        }
        return results
    }

    /// Finds the first group that contains the specified repo
    /// - Parameter repo: Repo to find
    /// - Returns: RepoGroup that contains repo, or nil if is not found
    func groupContaining(_ repo : Repo) -> RepoGroup? {
        let items = groups.filter { (group) -> Bool in
            group.repos.contains { (r) -> Bool in
                r === repo
            }
        }

        return items.first
    }

    // MARK: - Acting on Contents

    /// Concurrently perform action on each repo in the given groups, or on all repos if the
    /// group set is nil
    /// - Parameters:
    ///   - groupSet: Groups containing the repos to act upon, or nil to act on all repos
    ///   - perform: Closure to perform on each repo
    ///   - repo:  Repo to act upon
    func concurrentlyForEach(in groupSet: [RepoGroup]?,
                             perform: @escaping (_ repo: Repo) -> Void) {
        let opQ = OperationQueue()
        opQ.maxConcurrentOperationCount = AppSettings.numConcurrentJobs

        for group in groups {
            if groupSet == nil || (groupSet?.contains(group) ?? false) {
                for repo in group.repos {
                    opQ.addOperation {
                        perform(repo)
                    }
                }
            }
        }
        opQ.waitUntilAllOperationsAreFinished()
    }

    /// Perform action on each repo in the given groups, or on all repos if the
    /// group set is nil. The actions are not executed concurrently.
    /// - Parameters:
    ///   - groupSet: Groups containing the repos to act upon, or nil to act on all repos
    ///   - groupFunc: Closure to perform for each group
    ///   - repoGroup:  Group to act upon
    ///   - repoFunc: Closure to perform on each repo
    ///   - repo:  Repo to act upon
    func forEach(in groupSet: [RepoGroup]? = nil,
                 group groupFunc: ((_ repoGroup: RepoGroup) -> Void)? = nil,
                 perform repoFunc: @escaping (_ repo: Repo) -> Void) {
        for group in groups {
            if groupSet == nil || (groupSet?.contains(group) ?? false) {
                groupFunc?(group)
                for repo in group.repos {
                    repoFunc(repo)
                }
            }
        }
    }

    // MARK: - Utility

    /// Get the length of the longest repo name in the collection
    /// - Returns: Length of longest repo name
    func lengthOfLongestRepoName() -> Int {
        var longest = 0

        for group in groups {
            for repo in group.repos {
                if repo.name.count > longest {
                    longest = repo.name.count
                }
            }
        }
        return longest
    }

    /// Get the length of the longest branch name in the collection
    /// - Returns: Length of longest repo name
    func lengthOfLongestBranchName() -> Int {
        var longest = 0

        for group in groups {
            for repo in group.repos {
                if repo.status.branch.count > longest {
                    longest = repo.status.branch.count
                }
            }
        }
        return longest
    }

    func purgeEmptyGroups() {
        groups.removeAll(where: { $0.repos.count == 0 } )
        _ = save()
    }



}

// MARK: - Private

extension RepoCollection {

    // MARK: - Save/Load

    private func load() -> Bool {
        guard FileManager.default.fileExists(atPath: storageFileURL.path) else {
            return true
        }

        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: storageFileURL)
            let result = try decoder.decode([RepoGroup].self, from: data)
            groups.removeAll()
            groups.append(contentsOf: result)

            return true
        }
        catch {
            print("Cannot decode: \(error)")
        }

        return true
    }

    private func save() -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let data = try encoder.encode(groups)
            try data.write(to: storageFileURL)
            return true
        }
        catch {
            print("Cannot encode: \(error)")
        }

        return false
    }

    private func createConfigStorageFolder() {
        do {
            let url = storageFileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }
        catch {
            print("Cannot create storage")
        }
    }

    private func addDefaultGroup() {
        groups.append(RepoGroup(name: Self.DefaultGroupName))
    }

    private func sort() {
        groups.sort { (lhs, rhs) -> Bool in
            lhs.name.localizedCompare(rhs.name) == .orderedAscending
        }
    }
}
