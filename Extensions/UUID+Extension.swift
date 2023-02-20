//
//  UUID+Extension.swift
//  RepoStatus
//
//  Created by Simon Beavis on 18/02/23.
//

import Foundation

extension UUID: RawRepresentable {
    public var rawValue: String {
        self.uuidString
    }

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        self.init(uuidString: rawValue)
    }
}


