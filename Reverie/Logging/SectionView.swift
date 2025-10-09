import SwiftUI

struct SectionView: View {
    let title: String
    let date: String
    let tags: [String]
    let description: String
    var body: some View {

            HStack {
                VStack (alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal,8)
                            .padding(.vertical,12)
                            .cornerRadius(6)
                            .foregroundColor(.white)
                        Text(date)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .padding(.horizontal,10)
                                    .background(Color(white: 0.7))
                                    .cornerRadius(15)
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    HStack {
                        Text(description)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .lineLimit(1)
                            .padding(.horizontal, 18)
                            .padding(.vertical,10)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.horizontal,10)
            }
            .background(Color(white: 0.4))
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
        tags: ["Love", "Falling", "Being Chased", "Scared"],
        description: "Dream description preview Dream description preview Dream description preview Dream description preview"
    )
}
