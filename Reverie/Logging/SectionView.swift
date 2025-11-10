import SwiftUI

struct SectionView: View {
    let title: String
    let date: String
    let tags: [DreamModel.Tags]
    let description: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text(title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .dreamGlow()

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(tags, id: \.self) { tag in
                                    Image(systemName: DreamModel.tagImages(tag: tag))
                                        .foregroundColor(DreamModel.tagColors(tag: tag))
                                        .font(.headline)
                                        .dreamGlow()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.title3)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
                .padding(.leading, -1)
        }
        .background(Color.clear)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 0) {
            SectionView(
                title: "Cave Diving",
                date: "September 14th, 2024",
                tags: [.love, .falling, .animals, .authority, .chase, .disasters, .celebration, .fantasy, .fight, .food, .nature],
                description: "Dream description preview Dream description preview Dream description preview Dream description preview"
            )
            SectionView(
                title: "Pizza Pizza",
                date: "October 22",
                tags: [.friends, .food],
                description: "Dreaming about pizza with friends."
            )
        }
        .padding(.horizontal)
    }
}
