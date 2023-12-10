//
//  Item.swift
//  GPTSwift
//
//  Created by Elvis on 10/12/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
