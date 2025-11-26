import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        TabView {
            OnboardingPage(
                imageName: "clock.arrow.circlepath",
                title: "Welcome to MyLife!",
                description: "Your personal timeline for life's most important moments. Visualize your history in a beautiful, continuous stream."
            )
            
            OnboardingPage(
                imageName: "square.and.arrow.down",
                title: "Import Your Data",
                description: "Easily bring in your history from LinkedIn, Instagram, or any CSV file. Your data belongs to you."
            )
            
            OnboardingPage(
                imageName: "magnifyingglass",
                title: "Rediscover Memories",
                description: "Search, filter, and explore your past. Tap 'Get Started' to begin your journey.",
                showButton: true,
                action: {
                    isPresented = false
                }
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    var showButton: Bool = false
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(Color.theme.accent)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Spacer()
            
            if showButton {
                Button(action: { action?() }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.accent)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            } else {
                // Spacer to balance the layout against the button on the last page
                Spacer()
                    .frame(height: 50)
            }
        }
    }
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}
