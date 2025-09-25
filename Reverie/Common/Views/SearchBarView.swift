import SwiftUI

struct SearchBarView: View {
    @State var searchText: String = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 6)
            TextField("Search", text: $searchText)
        }
        .padding(.vertical, 4)
        .background(.white)
        .cornerRadius(12)
        .padding(.horizontal, 10)
    }
}

#Preview {
    SearchBarView()
}
