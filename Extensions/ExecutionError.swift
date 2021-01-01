//
//  ExecutionError.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

public struct ExecutionError: Error, CustomStringConvertible {
    /// The error message represented by this instance, this string is presented to
    /// the user when a `ExecutionError` is thrown from either; `run()`,
    /// `validate()` or a transform closure.
    public internal(set) var message: String
    
    /// Creates a new validation error with the given message.
    public init(_ message: String) {
        self.message = message
    }
    
    public var description: String {
        message
    }
}

