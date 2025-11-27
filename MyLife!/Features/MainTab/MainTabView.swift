import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var tourManager: TourManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedTab = 0
    @State private var tourStep = 0
    
    init() {
        // Make TabBar transparent
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Make NavigationBar transparent
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TimelineView()
                    .tabItem {
                        Label("Timeline", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(0)
                
                GalleryView()
                    .tabItem {
                        Label("Gallery", systemImage: "photo.stack")
                    }
                    .tag(1)
                
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .tint(themeManager.accentColor)
            .background(themeManager.backgroundView())
            
            // Contextual Tour Overlay
            if !hasSeenOnboarding {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Prevent dismissing by tapping background, force user to interact with card
                    }
                
                VStack {
                    Spacer()
                    
                    switch tourStep {
                    case 0:
                        TourCard(
                            title: "Welcome to MyLife!",
                            description: "The private place for your life's story. Capture memories, milestones, and the people who matter most.",
                            iconName: "heart.text.square",
                            buttonTitle: "Start Tour"
                        ) {
                            withAnimation {
                                tourStep = 1
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                    case 1:
                        TourCard(
                            title: "Timeline",
                            description: "Your life story in a continuous stream. Visualize your history in a beautiful list.",
                            iconName: "clock.arrow.circlepath",
                            buttonTitle: "Next"
                        ) {
                            withAnimation {
                                selectedTab = 1
                                tourStep = 2
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                    case 2:
                        TourCard(
                            title: "Gallery",
                            description: "All your memories in one place. Browse your photos by year, category, or people.",
                            iconName: "photo.stack",
                            buttonTitle: "Next"
                        ) {
                            withAnimation {
                                selectedTab = 2
                                tourStep = 3
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                    case 3:
                        TourCard(
                            title: "Search",
                            description: "Find any moment instantly. Filter by text, category, or the people involved.",
                            iconName: "magnifyingglass",
                            buttonTitle: "Finish"
                        ) {
                            withAnimation {
                                hasSeenOnboarding = true
                                selectedTab = 0 // Return to timeline to start using the app
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                    default:
                        EmptyView()
                    }
                }
                .padding(.bottom, 60) // Lift above tab bar slightly
            }
            // Contextual Tour Prompt
            if tourManager.showTourPrompt {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { } // Block touches
                
                VStack(spacing: 20) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Setup Complete!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Would you like to learn how to customize your experience with Categories and People?")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button("No thanks") {
                            withAnimation {
                                tourManager.showTourPrompt = false
                            }
                        }
                        .foregroundColor(.secondary)
                        
                        Button("Show me") {
                            withAnimation {
                                tourManager.startTour()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(radius: 10)
                )
                .padding(40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: tourManager.navigateToSettings) { _, newValue in
            if newValue {
                selectedTab = 3
            }
        }
    }
    
    
    #Preview {
        MainTabView()
    }
}
