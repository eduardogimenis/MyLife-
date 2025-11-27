import Foundation
import SwiftData
import SwiftUI

@Model
final class LifeEvent {
    var title: String
    var date: Date
    var endDate: Date?
    var isApproximate: Bool
    var categoryRawValue: String
    var notes: String?
    var locationName: String?
    var photoID: String?
    var photoIDs: [String] = []
    var externalLink: URL?
    
    @Relationship var categoryModel: Category?
    @Relationship var people: [Person]?
    
    var category: EventCategory {
        get { EventCategory(rawValue: categoryRawValue) ?? .event }
        set { categoryRawValue = newValue.rawValue }
    }
    
    init(title: String, date: Date, endDate: Date? = nil, isApproximate: Bool = false, category: EventCategory = .event, notes: String? = nil, locationName: String? = nil, photoID: String? = nil, photoIDs: [String]? = nil, externalLink: URL? = nil, categoryModel: Category? = nil, people: [Person]? = nil) {
        self.title = title
        self.date = date
        self.endDate = endDate
        self.isApproximate = isApproximate
        self.categoryRawValue = category.rawValue
        self.notes = notes
        self.locationName = locationName
        self.photoID = photoID
        self.photoIDs = photoIDs ?? (photoID != nil ? [photoID!] : [])
        self.externalLink = externalLink
        self.categoryModel = categoryModel
        self.people = people
    }
}

enum EventCategory: String, CaseIterable, Codable {
    case work = "Work"
    case education = "Education"
    case living = "Living"
    case travel = "Travel"
    case event = "Event"
    case relationship = "Relationship"
    
    var color: SwiftUI.Color {
        switch self {
        case .work: return Color.theme.work
        case .education: return Color.blue // Fallback or add to theme
        case .living: return Color.theme.living
        case .travel: return Color.theme.travel
        case .event: return Color.theme.event
        case .relationship: return Color.pink // Fallback or add to theme
        }
    }
}
