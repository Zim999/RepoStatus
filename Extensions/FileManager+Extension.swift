//
//  FileManager+Extension.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

extension FileManager {
    public func directoryExists(_ url : URL) -> Bool {
        var isDir = ObjCBool(false)
        return fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }
}
