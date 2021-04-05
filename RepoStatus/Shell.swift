//
//  Shell.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/19/20.
//

import Foundation

/// Shell command support
struct Shell {
    /// Run a shell command in the directory specified by URL
    /// - Parameters:
    ///   - command: The command, with parameters to run
    ///   - url: URL of the directory where the command is run
    /// - Returns: Output from the command
    ///   - Exit code
    ///   - Output of the command
    static func run(_ command: String, at url: URL) -> (Int32, String?) {
        let command = command.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard command != "",
              FileManager.default.directoryExists(url) else {
            return (-1, nil)
        }

        let task = Process()
        let pipe = Pipe()
        let output: String?

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.currentDirectoryURL = url
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        output = String(data: data, encoding: .utf8)!

        task.waitUntilExit()
//        while task.isRunning {
//            Thread.sleep(forTimeInterval: 0.001)
//        }

        let exitCode = task.terminationStatus

        return (exitCode, output)
    }
}
