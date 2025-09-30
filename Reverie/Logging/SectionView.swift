import SwiftUI

struct SectionView: View {
    var body: some View {
        NavigationStack {
            HStack {
                VStack (alignment: .leading) {
                    HStack {
                        Text("Cave Diving")
                            .font(.title)
                            .fontWeight(.bold)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal,8)
                            .padding(.vertical,12)
                            .cornerRadius(6)
                            .foregroundColor(.white)
                        Text("September 14th, 2025")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    HStack{
                        Text("Love")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.horizontal,10)
                            .background(Color(white: 0.7))
                            .cornerRadius(15)
                        Text("Falling")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.horizontal,10)
                            .background(Color(white: 0.7))
                            .cornerRadius(15)
                        Text("Being Chased")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .padding(.horizontal,10)
                            .background(Color(white: 0.7))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 18)
                    HStack {
                        Text("Dream description preview Dream description preview Dream description preview Dream description preview Dream description preview")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .lineLimit(1)
                            .padding(.horizontal, 18)
                            .padding(.vertical,10)
                    }
                }
                HStack {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(.horizontal,10)
                }
            }
            .background(Color(white: 0.4))
            .cornerRadius(10)
            .padding(.horizontal, 10)
            .padding(.vertical)
        }
    }
}
#Preview {
    SectionView()
}
