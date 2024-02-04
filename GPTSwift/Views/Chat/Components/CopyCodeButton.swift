//
//  CopyCodeButton.swift
//  GPTSwift
//
//  Created by Elvis on 04/02/2024.
//

import Foundation
import SwiftUI

struct CopyCodeButton: View {
    @State private var isCopy: Bool = false
    let value: String
    
    var body: some View {
        Button {
            isCopy = CopyService.copy(value)
            if isCopy {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isCopy = false
                }
            }
        } label: {
            Label(isCopy ? "Copied" : "Copy Code" , systemImage: isCopy ? "checkmark" : "doc.on.doc")
        }
        .disabled(isCopy)
        .font(.subheadline)
        .buttonStyle(.plain)
        .foregroundStyle(.blue)
        .transition(.opacity)
        .animation(.easeIn(duration: 0.4), value: isCopy)
    }
}

#Preview {
    CopyCodeButton(value: "")
}
