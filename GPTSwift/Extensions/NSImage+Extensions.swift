//
//  NSImage+Extensions.swift
//  GPTSwift
//
//  Created by Elvis on 25/12/2023.
//

import Foundation

#if os(macOS)
import AppKit

extension NSImage {
    /// Resize image while keeping the aspect ratio.
    /// - Parameters:
    ///   - width: A new width in pixels
    ///   - height: A new height in pixels
    /// - Returns: Resized image
    func resize(_ width: Int, _ height: Int) -> NSImage {
        // Get new ratio
        let ratioX = CGFloat(width) / self.size.width
        let ratioY = CGFloat(height) / self.size.height
        let ratio = ratioX < ratioY ? ratioX : ratioY
        
        // Calculate output image new size
        let newHeight = self.size.height * ratio
        let newWidth = self.size.width * ratio
        let newSize = NSSize(width: newWidth, height: newHeight)
        let newImage = NSImage(size: newSize)
        
        // Resize image
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize), from: NSZeroRect, operation: .copy, fraction: 1)
        newImage.unlockFocus()
        newImage.size = newSize
        
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}
#endif
