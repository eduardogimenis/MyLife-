import SwiftUI
import SwiftData

struct SetupWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    enum Step {
        case birth
        case career
        case family
        case living
        case retirement
        case completion
    }
    
    @State private var currentStep: Step = .birth
    
    // Data Holders
    @State private var birthDate = Date()
    @State private var linkedinURL: URL?
    @State private var spouseName = ""
    @State private var spouseAnniversary = Date()
    @State private var hasSpouse = false
    @State private var currentCity = ""
    @State private var moveInDate = Date()
    @State private var isRetired = false
    @State private var retirementDate = Date()
    
    // Helper to calculate age
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Bar (Simplified)
                ProgressView(value: progressValue)
                    .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case .birth:
                            birthStep
                        case .career:
                            careerStep
                        case .family:
                            familyStep
                        case .living:
                            livingStep
                        case .retirement:
                            retirementStep
                        case .completion:
                            completionStep
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack {
                    if currentStep != .birth && currentStep != .completion {
                        Button("Back") {
                            goBack()
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if currentStep != .completion {
                        Button(currentStep == .retirement ? "Finish" : "Next") {
                            goNext()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("View Timeline") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
    }
    
    // MARK: - Steps Views
    
    var birthStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.child")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Let's start at the beginning.")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("When is your birthday?")
                .foregroundColor(.secondary)
            
            DatePicker("Birthday", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
        }
    }
    
    var careerStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase.fill")
                .font(.system(size: 60))
                .foregroundColor(.brown)
            
            Text("Career & Education")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Import your history from LinkedIn to instantly populate your timeline.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                // In a real app, this would open file importer
                // For now, we'll simulate it or just skip
            } label: {
                Label("Import LinkedIn Data", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text("Or skip this step to enter manually later.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    var familyStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text("Family & Relationships")
                .font(.title2)
                .fontWeight(.bold)
            
            Toggle("I have a spouse/partner", isOn: $hasSpouse)
                .padding()
                .background(Color.theme.cardBackground)
                .cornerRadius(10)
            
            if hasSpouse {
                VStack(alignment: .leading) {
                    TextField("Partner's Name", text: $spouseName)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker("Anniversary", selection: $spouseAnniversary, displayedComponents: .date)
                }
                .padding()
                .background(Color.theme.cardBackground)
                .cornerRadius(10)
            }
        }
    }
    
    var livingStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Where do you live?")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading) {
                TextField("Current City", text: $currentCity)
                    .textFieldStyle(.roundedBorder)
                
                DatePicker("Move-in Date", selection: $moveInDate, displayedComponents: .date)
            }
            .padding()
            .background(Color.theme.cardBackground)
            .cornerRadius(10)
        }
    }
    
    var retirementStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Retirement")
                .font(.title2)
                .fontWeight(.bold)
            
            if age > 55 {
                Toggle("I am retired", isOn: $isRetired)
                    .padding()
                    .background(Color.theme.cardBackground)
                    .cornerRadius(10)
                
                if isRetired {
                    DatePicker("Retirement Date", selection: $retirementDate, displayedComponents: .date)
                        .padding()
                        .background(Color.theme.cardBackground)
                        .cornerRadius(10)
                }
            } else {
                Text("You are young! Skipping this step.")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var completionStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your timeline has been created.")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Logic
    
    var progressValue: Double {
        switch currentStep {
        case .birth: return 0.1
        case .career: return 0.3
        case .family: return 0.5
        case .living: return 0.7
        case .retirement: return 0.9
        case .completion: return 1.0
        }
    }
    
    var stepTitle: String {
        switch currentStep {
        case .birth: return "Birth"
        case .career: return "Career"
        case .family: return "Family"
        case .living: return "Living"
        case .retirement: return "Retirement"
        case .completion: return "Done"
        }
    }
    
    func goNext() {
        withAnimation {
            switch currentStep {
            case .birth:
                saveBirthEvent()
                currentStep = .career
            case .career:
                // Handle import if implemented
                currentStep = .family
            case .family:
                saveFamilyEvent()
                currentStep = .living
            case .living:
                saveLivingEvent()
                currentStep = .retirement
            case .retirement:
                saveRetirementEvent()
                currentStep = .completion
            case .completion:
                break
            }
        }
    }
    
    func goBack() {
        withAnimation {
            switch currentStep {
            case .birth: break
            case .career: currentStep = .birth
            case .family: currentStep = .career
            case .living: currentStep = .family
            case .retirement: currentStep = .living
            case .completion: currentStep = .retirement
            }
        }
    }
    
    // MARK: - Saving
    
    func saveBirthEvent() {
        let event = LifeEvent(
            title: "Born",
            date: birthDate,
            isApproximate: false,
            category: .relationship, // Using Relationship as a proxy for 'Life/Family'
            notes: "The beginning of my journey."
        )
        // Link category
        if let cat = fetchCategory(name: "Relationship") {
            event.categoryModel = cat
        }
        modelContext.insert(event)
    }
    
    func saveFamilyEvent() {
        if hasSpouse && !spouseName.isEmpty {
            let event = LifeEvent(
                title: "Anniversary with \(spouseName)",
                date: spouseAnniversary,
                isApproximate: false,
                category: .relationship
            )
            if let cat = fetchCategory(name: "Relationship") {
                event.categoryModel = cat
            }
            modelContext.insert(event)
        }
    }
    
    func saveLivingEvent() {
        if !currentCity.isEmpty {
            let event = LifeEvent(
                title: "Moved to \(currentCity)",
                date: moveInDate,
                isApproximate: false,
                category: .living,
                locationName: currentCity
            )
            if let cat = fetchCategory(name: "Living") {
                event.categoryModel = cat
            }
            modelContext.insert(event)
        }
    }
    
    func saveRetirementEvent() {
        if isRetired {
            let event = LifeEvent(
                title: "Retirement",
                date: retirementDate,
                isApproximate: false,
                category: .work,
                notes: "A new chapter begins."
            )
            if let cat = fetchCategory(name: "Work") {
                event.categoryModel = cat
            }
            modelContext.insert(event)
        }
    }
    
    func fetchCategory(name: String) -> Category? {
        let descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.name == name })
        return try? modelContext.fetch(descriptor).first
    }
}

#Preview {
    SetupWizardView()
}
