import SwiftUI
import Combine

enum TourStep: Equatable {
    case settingsHighlightCategories
    case insideCategories
    case settingsHighlightPeople
    case insidePeople
}

@MainActor
class TourManager: ObservableObject {
    static let shared = TourManager()
    
    @Published var showTourPrompt = false
    @Published var currentStep: TourStep?
    @Published var navigateToSettings = false
    
    // Call this when Setup Wizard completes
    func triggerPostSetupTour() {
        showTourPrompt = true
    }
    
    func startTour() {
        showTourPrompt = false
        currentStep = .settingsHighlightCategories
        navigateToSettings = true
    }
    
    func endTour() {
        currentStep = nil
        navigateToSettings = false
    }
}
