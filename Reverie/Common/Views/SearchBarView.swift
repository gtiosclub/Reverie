import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $searchText)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .padding()
    }
}

#Preview {
    SearchBarView()
}
