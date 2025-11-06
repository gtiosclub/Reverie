import SwiftUI

struct SectionView: View {
    let title: String
    let date: String
    let tags: [DreamModel.Tags]
    let description: String
    var body: some View {
        
            ZStack{
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            Text(title)
                                .font(.title)
                                .fontWeight(.bold)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 15)
                                .cornerRadius(6)
                                .foregroundColor(.white)
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        Image(systemName: DreamModel.tagImages(tag: tag))
                                            .foregroundColor(DreamModel.tagColors(tag: tag))
                                            .font(.headline)
                                            .padding(.horizontal,5)
                                            .cornerRadius(15)
                                            .shadow(radius: 3)
                                    }
                                }
                                
                            }
                            .frame(maxWidth: 150)
                        }
                        .padding(.top, 10)
                        
                        Text(date)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.leading, 20)
                        
                        HStack {
                            Text(description)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .lineLimit(1)
                                .padding(.horizontal, 18)
                                .padding(.vertical,10)
                        }
                    }
                    
                }
                
                HStack{
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(.horizontal,10)
                }
            }
            .background(Color(white: 0.5))
            .cornerRadius(10)
            .padding(.horizontal, 10)
            .padding(.vertical)
            .frame(maxWidth: 384)
        }
    }
#Preview {
    SectionView(
        title: "Cave Diving",
        date: "September 14th, 2024",
        tags: [.love, .falling],
        description: "Dream description preview Dream description preview Dream description preview Dream description preview"
    )
}
