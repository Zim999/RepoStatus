//
//  Attribute.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 4/04/23.
//

import Foundation

/// Attributes of the current repo status
enum Attribute {
    case newUntrackedFiles
    case modifiedFiles
    case addedFiles
    case deletedFiles
    case renamedFiles
    case copiedFiles
}

typealias AttributeSet = Set<Attribute>
