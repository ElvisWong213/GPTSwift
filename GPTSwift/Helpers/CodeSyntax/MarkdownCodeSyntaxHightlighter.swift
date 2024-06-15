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
        var output = Text(content)
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            do {
                guard let language = language?.lowercased() else {
                    throw SyntaxHighlightingError.UnsupportedFormatError
                }
                output = try SyntaxHighlightingMarkdownUI.shared.output(content, language: language)
            } catch {
                print(error)
            }
            group.leave()
        }
        _ = group.wait(timeout: .now() + 1)
        
        return output
    }
}

extension CodeSyntaxHighlighter where Self == MarkdownCodeSyntaxHightlighter {
    static func syntaxHighlightingMarkdownUI() -> Self {
        MarkdownCodeSyntaxHightlighter()
    }
}
