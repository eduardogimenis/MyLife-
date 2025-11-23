//
//  Item.swift
//  MyLife!
//
//  Created by Eduardo de Castilhos Gimenis on 11/23/25.
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
