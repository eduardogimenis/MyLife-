import Foundation
import SwiftData

struct MockData {
    static func generateSampleEvents() -> [LifeEvent] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            LifeEvent(title: "Born", date: calendar.date(byAdding: .year, value: -30, to: now)!, isApproximate: false, category: .event, locationName: "Hospital"),
            LifeEvent(title: "Started Elementary School", date: calendar.date(byAdding: .year, value: -25, to: now)!, isApproximate: true, category: .education),
            LifeEvent(title: "Family Trip to Disney", date: calendar.date(byAdding: .year, value: -20, to: now)!, isApproximate: false, category: .travel, locationName: "Orlando, FL"),
            LifeEvent(title: "High School Graduation", date: calendar.date(byAdding: .year, value: -12, to: now)!, isApproximate: false, category: .education),
            LifeEvent(title: "Moved to College Dorm", date: calendar.date(byAdding: .year, value: -12, to: now)!, isApproximate: true, category: .living, locationName: "University Campus"),
            LifeEvent(title: "First Internship", date: calendar.date(byAdding: .year, value: -10, to: now)!, isApproximate: false, category: .work, locationName: "Tech Corp"),
            LifeEvent(title: "Graduated College", date: calendar.date(byAdding: .year, value: -8, to: now)!, isApproximate: false, category: .education),
            LifeEvent(title: "Backpacking across Europe", date: calendar.date(byAdding: .year, value: -7, to: now)!, isApproximate: true, category: .travel, notes: "Best summer ever!"),
            LifeEvent(title: "Started First Full-time Job", date: calendar.date(byAdding: .year, value: -6, to: now)!, isApproximate: false, category: .work, locationName: "Startup Inc"),
            LifeEvent(title: "Moved to New City", date: calendar.date(byAdding: .year, value: -6, to: now)!, isApproximate: false, category: .living, locationName: "New York, NY"),
            LifeEvent(title: "Adopted a Dog", date: calendar.date(byAdding: .year, value: -4, to: now)!, isApproximate: false, category: .relationship, notes: "Named him Buddy"),
            LifeEvent(title: "Promotion to Senior", date: calendar.date(byAdding: .year, value: -2, to: now)!, isApproximate: true, category: .work),
            LifeEvent(title: "Got Married", date: calendar.date(byAdding: .month, value: -6, to: now)!, isApproximate: false, category: .relationship, locationName: "City Hall")
        ]
    }
}
