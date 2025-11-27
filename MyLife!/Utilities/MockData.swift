import Foundation
import SwiftData

struct MockData {
    static func generateSampleEvents() -> [LifeEvent] {
        let calendar = Calendar.current
        let now = Date()
        
        // Helper to create date from components
        func date(year: Int, month: Int, day: Int) -> Date {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return calendar.date(from: components) ?? now
        }
        
        let currentYear = calendar.component(.year, from: now)
        
        return [
            LifeEvent(title: "Born", date: date(year: currentYear - 30, month: 5, day: 15), isApproximate: false, category: .event, locationName: "Hospital"),
            LifeEvent(title: "Elementary School", date: date(year: currentYear - 25, month: 9, day: 1), endDate: date(year: currentYear - 20, month: 6, day: 15), isApproximate: true, category: .education),
            LifeEvent(title: "Family Trip to Disney", date: date(year: currentYear - 20, month: 7, day: 10), isApproximate: false, category: .travel, locationName: "Orlando, FL"),
            LifeEvent(title: "High School Graduation", date: date(year: currentYear - 12, month: 5, day: 20), isApproximate: false, category: .education),
            LifeEvent(title: "Moved to College Dorm", date: date(year: currentYear - 12, month: 8, day: 25), isApproximate: true, category: .living, locationName: "University Campus"),
            LifeEvent(title: "First Internship", date: date(year: currentYear - 10, month: 6, day: 1), endDate: date(year: currentYear - 10, month: 8, day: 30), isApproximate: false, category: .work, locationName: "Tech Corp"),
            LifeEvent(title: "Graduated College", date: date(year: currentYear - 8, month: 5, day: 15), isApproximate: false, category: .education),
            LifeEvent(title: "Backpacking across Europe", date: date(year: currentYear - 7, month: 6, day: 1), endDate: date(year: currentYear - 7, month: 8, day: 1), isApproximate: true, category: .travel, notes: "Best summer ever!"),
            LifeEvent(title: "First Full-time Job", date: date(year: currentYear - 6, month: 9, day: 1), endDate: date(year: currentYear - 4, month: 8, day: 31), isApproximate: false, category: .work, locationName: "Startup Inc"),
            LifeEvent(title: "Moved to New City", date: date(year: currentYear - 6, month: 9, day: 15), isApproximate: false, category: .living, locationName: "New York, NY"),
            LifeEvent(title: "Adopted a Dog", date: date(year: currentYear - 4, month: 3, day: 10), isApproximate: false, category: .relationship, notes: "Named him Buddy"),
            LifeEvent(title: "Promotion to Senior", date: date(year: currentYear - 2, month: 11, day: 1), isApproximate: true, category: .work),
            LifeEvent(title: "Got Married", date: date(year: currentYear, month: 5, day: 27), isApproximate: false, category: .relationship, locationName: "City Hall")
        ]
    }
}
