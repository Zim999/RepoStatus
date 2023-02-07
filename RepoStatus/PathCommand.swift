//
//  PathCommand.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 8/04/22.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct Path: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Show file system paths for repos")

        @Argument(help: "Display status for this repo, or group if group option is used, only")
        var name: String?

        @Flag(name: [.customLong("group"), .customShort("g")],
              help: "Shows paths for all repos in the group")
        var group = false

        func run() throws {
            try perform()
        }

        func validate() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            if let name = name {
                if group && !collection.contains(name) {
                    throw ValidationError("No group with that name exists")
                }
            }
        }

        private func perform() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            var repos: [RepoGroup]? = nil

            if let name = name,
               let group = collection.group(named: name) {
                repos = [group]
            }

            // ... This needs to be done better
            collection.forEach(in: repos,
                               group: {
                                    if !group && name != nil && $0.repo(named: name!) != nil {
                                        print($0.name)
                                    }
                               },
                               perform: {
                                    if !group {
                                        if name == nil || name == $0.name {
                                            print($0.url)
                                        }
                                    }
                                    else {
                                        print($0.url)
                                    }
                               }
            )
        }
    }
}
