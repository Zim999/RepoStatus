//
//  ExpansionState.swift
//  RepoStatusUI
//
//  Created by Simon Beavis on 11/02/23.
//

import Foundation

struct ExpansionState: RawRepresentable {
    var ids: Set<UUID>
    
    let current = 2021

    init?(rawValue: String) {
        ids = Set(rawValue.components(separatedBy: ",").compactMap({ UUID(uuidString: $0) }))
    }

    init() {
        ids = []
    }

    var rawValue: String {
        ids.map({ "\($0)" }).joined(separator: ",")
    }

    var isEmpty: Bool {
        ids.isEmpty
    }

    func contains(_ id: UUID) -> Bool {
        ids.contains(id)
    }

    mutating func insert(_ id: UUID) {
        ids.insert(id)
    }

    mutating func remove(_ id: UUID) {
        ids.remove(id)
    }

    subscript(id: UUID) -> Bool {
        get {
            // Expand the current year by default
            ids.contains(id)
        }
        set {
            if newValue {
                ids.insert(id)
            } else {
                ids.remove(id)
            }
        }
    }
}
