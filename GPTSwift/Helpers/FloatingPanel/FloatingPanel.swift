//
//  FloatingPanel.swift
//  GPTSwift
//
//  Created by Elvis on 29/12/2023.
//

#if os(macOS)
import Foundation
import SwiftUI

class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    init(view: () -> Content,
         contentRect: NSRect,
         styleMask style: NSWindow.StyleMask = [.nonactivatingPanel, .resizable, .closable, .fullSizeContentView],
         backing backingStoreType: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         isPresented: Binding<Bool>) {
        
        self._isPresented = isPresented
        
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.isFloatingPanel = true
        self.level = .floating
        
        self.collectionBehavior.insert(.fullScreenAuxiliary)
        
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
                
        self.isMovableByWindowBackground = true
        
//        self.hidesOnDeactivate = true
        
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
        self.animationBehavior = .utilityWindow
                
        self.contentView = NSHostingView(rootView:
            view()
            .ignoresSafeArea()
            .environment(\.floatingPanel, self)
        )
    }
    
    override func resignMain() {
        super.resignMain()
        close()
    }
    
    override func close() {
        super.close()
        isPresented = false
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get {
            self[FloatingPanelKey.self]
        }
        set {
            self[FloatingPanelKey.self] = newValue
        }
    }
}


struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    
    var contentRect: CGRect = CGRect(x: 0, y: 0, width: 624, height: 512)

    @ViewBuilder let view: () -> PanelContent
    
    @State var panel: FloatingPanel<PanelContent>?

    func body(content: Content) -> some View {
        content
            .onAppear() {
                createPanel()
            }
            .onDisappear() {
                panel?.close()
                panel = nil
            }
            .onChange(of: isPresented) { oldValue, newValue in
                if newValue {
                    present()
                } else {
                    panel?.close()
                }
            }
    }
    
    func createPanel() {
        panel = FloatingPanel(view: view, contentRect: contentRect, isPresented: $isPresented)
        panel?.center()
    }
    
    func present() {
        if isPresented && panel != nil {
            panel?.orderFront(nil)
            panel?.makeKey()
        }
    }
}

#endif
