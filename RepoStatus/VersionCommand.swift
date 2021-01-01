//
//  VersionCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 31/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct Version: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "version",
            abstract: "Display version information")
        
        func run() {
            print(VersionNumberString)
        }
    }
}
