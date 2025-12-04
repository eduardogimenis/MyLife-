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
    
    @Published var showSkipPrompt = false
    private var inactivityTimer: Timer?
    
    // Call this when Setup Wizard completes
    func triggerPostSetupTour() {
        showTourPrompt = true
    }
    
    func startTour() {
        showTourPrompt = false
        currentStep = .settingsHighlightCategories
        navigateToSettings = true
        startInactivityTimer()
    }
    
    func endTour() {
        currentStep = nil
        navigateToSettings = false
        stopInactivityTimer()
    }
    
    func startInactivityTimer() {
        stopInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.showSkipPrompt = true
            }
        }
    }
    
    func resetInactivityTimer() {
        if currentStep != nil {
            startInactivityTimer()
        }
    }
    
    func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
}
