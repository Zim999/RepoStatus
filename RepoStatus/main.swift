//
//  main.swift
//  RepoStatusCommand
//
//  Created by Simon Beavis on 10/5/20.
//

import Foundation
import ArgumentParser

let VersionNumberString = "0.1.0"

RepoStatusCommand.main()

struct RepoStatusCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "RepoStatus",
        abstract: "Display status of Git repositories",
        version: VersionNumberString,
        subcommands: [Status.self,
                      Config.self,
                      Key.self,
                      AddGroup.self,
                      AddRepo.self,
                      RemoveGroup.self,
                      RemoveRepo.self,
                      Pull.self],
        defaultSubcommand: Status.self)
}

