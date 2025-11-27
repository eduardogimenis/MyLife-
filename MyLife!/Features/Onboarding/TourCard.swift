import SwiftUI

struct TourCard: View {
    let title: String
    let description: String
    let iconName: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(Color.theme.accent)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            Button(action: action) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.theme.accent)
                    .cornerRadius(10)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.cardBackground)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TourCard(
            title: "Timeline",
            description: "Your life story in a continuous stream. Visualize your history in a beautiful list.",
            iconName: "clock.arrow.circlepath",
            buttonTitle: "Next",
            action: {}
        )
    }
}
