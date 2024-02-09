//
//  MarkdownCodeSyntaxHightlighter.swift
//  GPTSwift
//
//  Created by Elvis on 26/12/2023.
//

import Foundation
import MarkdownUI
import SwiftUI
import SyntaxHighlightingMarkdownUI

struct MarkdownCodeSyntaxHightlighter: CodeSyntaxHighlighter {
    func highlightCode(_ content: String, language: String?) -> Text {
        guard let language = language else {
            return Text(content)
        }
        do {
            return try SyntaxHighlightingMarkdownUI.shared.output(content, language: language)
        } catch {
            print(error)
            return Text(content)
        }
    }
}

extension CodeSyntaxHighlighter where Self == MarkdownCodeSyntaxHightlighter {
    static func syntaxHighlightingMarkdownUI() -> Self {
        MarkdownCodeSyntaxHightlighter()
    }
}
