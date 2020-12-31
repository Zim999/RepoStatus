//
//  KeyCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct Key: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "key",
            abstract: "Display description of status flags")
        
        func run() throws {
            print("Status flags:")
            print("\t+ = Files added")
            print("\tM = Files modified")
            print("\t? = New untracked files")
            print("\tS = Has stashed changes")
            print("\t↑ = Ahead of remote")
            print("\t↓ = Behind remote")
        }
    }
}

