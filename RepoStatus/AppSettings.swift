//
//  AppSettings.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 10/09/21.
//

import Foundation

struct AppSettings {
    static var collectionStoreFileURL: URL {
        return configStoreFolderURL.appendingPathComponent("collection.json")
    }

    static var configFolderURL: URL {
        return configStoreFolderURL
    }

    static var numConcurrentJobs: Int {
        // ... Make this a configurable option
        return 10
    }

    // MARK: - Private

    private static var configStoreFolderURL: URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/RepoStatus")
    }    
}
