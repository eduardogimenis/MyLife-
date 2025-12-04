import Foundation
import CoreLocation

actor GeocodingService {
    static let shared = GeocodingService()
    private let geocoder = CLGeocoder()
    private var cache: [String: String] = [:] // "lat,long" -> "City, Country"
    
    private var detailsCache: [String: (city: String?, country: String?)] = [:]
    
    func reverseGeocode(location: CLLocation) async -> String? {
        let details = await reverseGeocodeDetails(location: location)
        var result = ""
        if let city = details.city {
            result += city
        }
        if let country = details.country {
            if !result.isEmpty { result += ", " }
            result += country
        }
        return result.isEmpty ? nil : result
    }

    func reverseGeocodeDetails(location: CLLocation) async -> (city: String?, country: String?) {
        let key = "\(String(format: "%.3f", location.coordinate.latitude)),\(String(format: "%.3f", location.coordinate.longitude))"
        
        if let cached = detailsCache[key] {
            return cached
        }
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let details = (city: placemark.locality, country: placemark.country)
                detailsCache[key] = details
                return details
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }
        
        return (nil, nil)
    }
}
