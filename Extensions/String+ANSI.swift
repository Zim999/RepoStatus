//
//  String+ANSI.swift
//  RepoStatus
//
//  Created by Simon Beavis on 31/12/20.
//

import Foundation

extension String {
    enum Colour: Int {
        case black = 0
        case maroon
        case green
        case olive
        case navy
        case purple
        case teal
        case silver
        case grey
        case red
        case lime
        case yellow
        case blue
        case fuchsia
        case aqua
        case white
        case chartreuse2 = 112
        case greenYellow = 154
        case darkOliveGreen2 = 155
        case red3 = 160
        case yellow2 = 190
        case orange = 214
    }
    
    func normal() -> String {
        return "\u{001B}[0m" + self
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
    
    func colour(_ colourCode: Colour) -> String {
        return "\u{001B}[38;5;\(colourCode.rawValue)m" + self
    }
    
    func background(_ colourCode: Colour) -> String {
        return "\u{001B}[48;5;\(colourCode.rawValue)m" + self
    }
}
