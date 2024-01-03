//
//  View+Extensions.swift
//  GPTSwift
//
//  Created by Elvis on 29/12/2023.
//

import Foundation
import SwiftUI

#if os(macOS)
extension View {
    func floatingPanel<Content: View>(isPresented: Binding<Bool>, isUpdatedSetting: Binding<Bool>, contentRect: CGRect = CGRect(x: 0, y: 0, width: 600, height: 512), @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FloatingPanelModifier(isPresented: isPresented, isUpdatedSetting: isUpdatedSetting, contentRect: contentRect, view: content))
    }
}
#endif
