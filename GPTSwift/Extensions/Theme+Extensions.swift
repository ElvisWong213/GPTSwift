//
//  Theme+Extensions.swift
//  GPTSwift
//
//  Created by Elvis on 26/12/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

extension Theme {
    public static let customMarkdownTheme = Theme()
        .text {
            ForegroundColor(.white)
        }
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            ForegroundColor(.yellow)
            FontWeight(.bold)
        }
        .codeBlock { content in
            ScrollView(.horizontal) {
                content
                    .padding()
            }
            .background(.black.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .markdownMargin(top: .em(1), bottom: .em(1))
        }
        .blockquote { content in
            content.label
              .padding()
              .markdownTextStyle {
                  FontStyle(.italic)
                BackgroundColor(nil)
              }
              .overlay(alignment: .leading) {
                Rectangle()
                      .fill(.white)
                  .frame(width: 4)
              }
              .background(.white.opacity(0.15))
        }
}
