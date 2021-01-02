//
//  String+ANSI.swift
//  RepoStatus
//
//  Created by Simon Beavis on 31/12/20.
//

import Foundation

extension String {
    func normal() -> String {
        return "\u{001B}[0m" + self
    }

    func reset() -> String {
        return self + "\u{001B}[0m"
    }

    func resetColour() -> String {
        return self + "\u{001B}[39m\u{001B}[39m"
    }

    func bold() -> String {
        return "\u{001B}[1m" + self
    }
    
    func dim() -> String {
        return "\u{001B}[2m" + self
    }
    
    func underlined() -> String {
        return "\u{001B}[4m" + self
    }
    
    func colour(_ colour: ANSIColour) -> String {
        return "\u{001B}[38;5;\(colour.rawValue)m" + self
    }

    func background(_ colour: ANSIColour) -> String {
        return "\u{001B}[48;5;\(colour.rawValue)m" + self
    }

    func colours(_ foreColour: ANSIColour, _ backColour: ANSIColour) -> String {
        return "\u{001B}[38;5;\(foreColour.rawValue);48;5;\(backColour.rawValue)m" + self
    }
    
    func forward(_ numChars: Int) -> String {
        return self + "\u{001B}[\(numChars)C"
    }

    func backward(_ numChars: Int) -> String {
        return self + "\u{001B}[\(numChars)D"
    }

    func up(_ numLines: Int) -> String {
        return self + "\u{001B}[\(numLines)A"
    }

    func down(_ numLines: Int) -> String {
        return self + "\u{001B}[\(numLines)B"
    }

    func clearLine() -> String {
        return "\u{001B}[2K"
    }
}
