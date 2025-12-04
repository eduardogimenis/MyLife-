import SwiftUI
import SwiftData
import Photos

struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: ThemeManager
    // Simplified Query to avoid predicate freeze
    @Query(sort: \DraftEvent.date, order: .reverse) private var drafts: [DraftEvent]
    
    @State private var isScanning = false
    @State private var scanProgress: Double = 0.0
    
    var body: some View {
        ZStack {
            themeManager.backgroundView()
                .onAppear { print("DEBUG: InboxView appeared") }
            
            VStack {
                if isScanning {
                    VStack(spacing: 10) {
                        ProgressView(value: scanProgress)
                            .tint(themeManager.accentColor)
                        Text("Scanning Library...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                }
                
                if drafts.isEmpty {
                    ContentUnavailableView(
                        "No New Memories",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Scan your library to find hidden gems.")
                    )
                } else {
                    List {
                        // Filter manually for now if needed, or just show all
                        ForEach(drafts) { draft in
                            if draft.statusRaw == "pending" {
                                ZStack {
                                    HStack(spacing: 12) {
                                        if let firstAssetID = draft.assetIdentifiers.first {
                                            AsyncPhotoView(photoID: firstAssetID)
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(8)
                                                .clipped()
                                        } else {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(8)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(draft.locationName ?? "Unknown Location")
                                                .font(.headline)
                                                .foregroundColor(themeManager.contrastingTextColor)
                                            Text(draft.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.subheadline)
                                                .foregroundColor(themeManager.contrastingTextColor.opacity(0.7))
                                        }
                                        Spacer()
                                        Text("\(draft.assetIdentifiers.count) photos")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    NavigationLink(destination: ReviewClusterView(draft: draft)) {
                                        EmptyView()
                                    }
                                    .opacity(0) // Invisible link over the row
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            
            
            if showingRefreshAlert {
                RefreshAlertView(
                    isPresented: $showingRefreshAlert,
                    onConfirm: {
                        refreshDatabase()
                    }
                )
            }
        }
        .navigationTitle("Memories Inbox")
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    withAnimation {
                        showingRefreshAlert = true
                    }
                } label: {
                    Label("Refresh Database", systemImage: "arrow.clockwise")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    startScan()
                } label: {
                    Label("Scan", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isScanning)
            }
        }
        .alert("Scan Status", isPresented: $showingScanAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(scanAlertMessage)
        }
    }
    
    @State private var showingScanAlert = false
    @State private var scanAlertMessage = ""
    @State private var showingRefreshAlert = false
    
    private func startScan() {
        Task {
            let status = await PhotoClusterService.shared.requestAuthorization()
            if status == .authorized || status == .limited {
                isScanning = true
                await PhotoClusterService.shared.scanLibrary(modelContainer: modelContext.container)
                isScanning = false
                
                // Check if we found anything (simple check for now)
                if drafts.isEmpty {
                    scanAlertMessage = "Scan complete. No new memories found matching the criteria."
                    showingScanAlert = true
                }
            } else {
                scanAlertMessage = "Photo library access denied. Please enable it in Settings."
                showingScanAlert = true
            }
        }
    }
    
    private func refreshDatabase() {
        Task {
            await PhotoClusterService.shared.resetAnalysisHistory(modelContainer: modelContext.container)
        }
    }
}

struct RefreshAlertView: View {
    @Binding var isPresented: Bool
    var onConfirm: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 20) {
                Text("Refresh Database?")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Do you wish to refresh the already analyzed photos database?")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary.opacity(0.8))
                
                Text("WARNING: Repeat events may be suggested if you have already added them to your timeline.")
                    .font(.caption)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    Divider()
                        .frame(height: 44)
                    
                    Button {
                        withAnimation {
                            isPresented = false
                            onConfirm()
                        }
                    } label: {
                        Text("Yes")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(0) // Bottom corners are handled by parent
            }
            .padding(.top, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Material.thick)
                    .shadow(radius: 20)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(40)
        }
        .transition(.opacity)
        .zIndex(100)
    }
}

#Preview {
    InboxView()
        .environmentObject(ThemeManager())
}
