//
//  RepoCollection.swift
//  GitMon
//
//  Created by Simon Beavis on 10/6/20.
//

import Foundation

/// To be implemented by all items in a RepoCollection (individual Repo and RepoGroup objects)
protocol RepoCollectionItem {
    var uuid: UUID { get }
    var name: String { get }

    func pull() -> Bool
}

/// Holds a list of RepoGroups, each containing Repo objects
class RepoCollection {
    /// Posted when the status of any Repo has changed
    static let repoCollectionChanged = Notification.Name("RepoCollectionChanged")

    private var storageFileURL: URL
    
    // MARK: - Properties
    
    /// Groups in the collection
    var groups = [RepoGroup]()
    
    /// Is the collection empty
    var isEmpty: Bool {
        return groups.count == 0
    }

    // MARK: - Public

    init(from url: URL) {
        storageFileURL = url
        createConfigStorageFolder()
        
        if load() && groups.count == 0 {
            addDefaultGroup()
        }
    }
    
    /// Refresh all groups and repos in the collection. The refresh is done on a background queue.
    /// When the refresh is complete a __repoCollectionChanged__ notification is sent to the
    /// default notification centre
    func refreshAsync() {
        DispatchQueue.global(qos: .background).async {
            self.groups.forEach { $0.refresh() }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: RepoCollection.repoCollectionChanged,
                                                object: self,
                                                userInfo: nil)
            }
        }
    }
    
    /// Add a group to the collection
    /// - Parameter group: Group to add
    func add(_ group: RepoGroup) {
        groups.append(group)
        groups.sort { (lhs, rhs) -> Bool in
            return lhs.name < rhs.name
        }
        _ = save()
    }
    
    func add(_ repo: Repo, to repoGroup: RepoGroup) {
        repoGroup.add(repo)
        _ = save()
    }
    
    /// Remove a group from the collection
    /// - Parameter group: Group to remove
    func remove(_ group: RepoGroup) {
        if let idx = groups.firstIndex(of: group) {
            groups.remove(at: idx)
            _ = save()
        }
    }
    
    func remove(_ repo: Repo, from repoGroup: RepoGroup) {
        repoGroup.remove(repo)
        _ = save()
    }
    
    /// Finds the item, RepoGroup or Repo, in the collection, with the
    /// specifid UUID.
    /// - Parameter uuid: Identifier of the item to find
    /// - Returns: The item, or nil if no item with the UUID is in the collection
    func item(with uuid: UUID) -> RepoCollectionItem? {
        for group in groups {
            if group.uuid == uuid {
                return group
            }
            for repo in group.repos {
                if repo.uuid == uuid {
                    return repo
                }
            }
        }

        return nil
    }

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

    /// Tests whether the collection contain the specified group
    /// - Parameter group: Group to test
    /// - Returns: True if the collection contains the group, false if it does not
    func contains(_ group: RepoGroup) -> Bool {
        return groups.contains { existingGroup in
            existingGroup.name == group.name
        }
    }
    
    /// Tests whether the collection contains a group with the specified name
    /// - Parameter groupName: Group name to test
    /// - Returns: True if the collection contains a group with the name, false if it does not
    func contains(_ groupName: String) -> Bool {
        return groups.contains { existingGroup in
            existingGroup.name == groupName
        }
    }
    
    func group(named groupName: String) -> RepoGroup? {
        for group in groups {
            if group.name == groupName {
                return group
            }
        }
        return nil
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
    
    func load() -> Bool {
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
    
    func save() -> Bool {
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

    
    // MARK: - Private

    private func addDefaultGroup() {
        groups.append(RepoGroup(name: "Default"))
    }
}
