//
//  MarkdownCodeSyntaxHightlighter.swift
//  GPTSwift
//
//  Created by Elvis on 26/12/2023.
//

import Foundation
import Splash
import MarkdownUI
import SwiftUI

struct MarkdownCodeSyntaxHightlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>
    
    init(theme: Splash.Theme) {
        self.syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }
    
    func highlightCode(_ content: String, language: String?) -> Text {
        guard language?.lowercased() == "swift" else {
            return Text(content)
        }
        
        return self.syntaxHighlighter.highlight(content)
    }
}

extension CodeSyntaxHighlighter where Self == MarkdownCodeSyntaxHightlighter {
    static func splash() -> Self {
        MarkdownCodeSyntaxHightlighter(theme: .wwdc18(withFont: Font(size: 16)))
    }
}
