//
//  CopyService.swift
//  GPTSwift
//
//  Created by Elvis on 04/02/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class CopyService {
    static func copy(_ value: String) -> Bool {
#if os(iOS)
        UIPasteboard.general.setValue(value, forPasteboardType: UTType.plainText.identifier)
        return UIPasteboard.general.string != nil
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        return pasteboard.string(forType: .string) != nil
#endif
    }
}
