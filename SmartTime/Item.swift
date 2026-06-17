//
//  Item.swift
//  SmartTime
//
//  Created by Shini on 17/6/26.
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
