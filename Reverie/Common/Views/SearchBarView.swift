import SwiftUI

struct SearchBarView: View {
    @State var searchText: String = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $searchText)
        }
        .padding()
        .background(Color(.systemGray4))
        .cornerRadius(12)
        .padding()
    }
}

#Preview {
    SearchBarView()
}
