//
//  Git.swift
//  RepoStatus
//
//  Created by Simon Beavis on 31/12/20.
//

import Foundation

struct Git {
    public static var fetchCommand = "git fetch"

    public static var pullCommand = "git branch & git pull -q"

    public static var statusCommand = "git status --porcelain=1 -b"

    public static var stashListCommand = "git stash list"
}
