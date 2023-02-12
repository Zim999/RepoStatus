//
//  ErrorMessageView.swift
//  RepoStatusUI
//
//  Created by Simon Beavis on 12/02/23.
//

import Foundation
import SwiftUI

struct ErrorMessageView: View {
    enum Kind {
        case error
        case warning
    }
    
    var message: String
    var kind = Kind.error
    
    var body: some View {
        Text(message)
            .padding(4)
            .padding([.leading, .trailing], 8)
            .foregroundColor(textColour())
            .background(backgroundColour())
            .cornerRadius(8)
    }
    
    func textColour() -> Color {
        kind == .warning ? .warningText : .errorText
    }
    
    func backgroundColour() -> Color {
        kind == .warning ? .warningBackground : .errorBackground
    }
}

struct ErrorMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorMessageView(message: "Error Here")
            .frame(width: 300)
    }
}
