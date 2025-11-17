import SwiftUI

struct SectionView: View {
    let line: Bool
    let title: String
    let date: String
    let tags: [DreamModel.Tags]
    let description: String
    
    init(
        title: String,
        date: String,
        tags: [DreamModel.Tags],
        description: String,
        line: Bool = true
    ) {
        self.title = title
        self.date = date
        self.tags = tags
        self.description = description
        self.line = line
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 27) {
                        Text(title)
                            .font(.custom("InstrumentSans-Regular", size: 18))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .dreamGlow()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(tags, id: \.self) { tag in
                                    Image(systemName: DreamModel.tagImages(tag: tag))
                                        .foregroundColor(DreamModel.tagColors(tag: tag))
                                        .font(.headline)
                                    //                                        .dreamGlow()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.leading, -9)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.top, 10)
            .padding(.bottom, 16)
            .padding(.horizontal, 20)
            
            if line {
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 1)
                //  .padding(.leading, 5)
            }
        }
        .background(Color.clear)
    }
}

#Preview {
    ZStack {
        Color(red: 12/255, green: 8/255, blue: 32/255)
            .ignoresSafeArea()
        VStack(spacing: 0) {
            SectionView(
                title: "Cave Diving",
                date: "September 14",
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
