//
//  FileManager+Extension.swift
//  RepoStatus
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

extension FileManager {
    /// Test whether the given URL is an existing directory
    /// - Parameter url: URL to test
    /// - Returns: true if the URL is a directory, and it exists, else false
    public func directoryExists(_ url : URL) -> Bool {
        var isDir = ObjCBool(false)
        return fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }
}
