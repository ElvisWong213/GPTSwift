//
//  KeyboardShortcuts+Extensions.swift
//  GPTSwift
//
//  Created by Elvis on 29/12/2023.
//

#if os(macOS)
import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toogleFloatWindow = Self("Toggle Float Windos", default: .init(.space, modifiers: [.command, .option]))
}
#endif
