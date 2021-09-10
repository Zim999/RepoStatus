//
//  AppSettings.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 10/09/21.
//

import Foundation

struct AppSettings {
    static var configStoreFileURL: URL {
        return configStoreFolderURL.appendingPathComponent("repostatus.json")
    }

    // MARK: - Private

    private static var configStoreFolderURL: URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/RepoStatus")
    }    
}
