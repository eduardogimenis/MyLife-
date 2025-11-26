import Foundation
import SwiftData

@Model
final class Person {
    @Attribute(.unique) var name: String
    var emoji: String
    
    @Relationship(inverse: \LifeEvent.people) var events: [LifeEvent]?
    
    init(name: String, emoji: String) {
        self.name = name
        self.emoji = emoji
    }
}
