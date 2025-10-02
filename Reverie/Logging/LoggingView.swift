//
//  LoggingView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct LoggingView: View {
    @State private var dream = ""
    @State private var title = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack() {
                    HStack {
                        NavigationLink {
                            HomeView()
                        }
                        label: {
                            HStack{
                                Image(systemName: "chevron.backward")
                                    .foregroundStyle(.black)
                                Text("Back")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Spacer()
                        NavigationLink {
                            // TODO: Add navigation link
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .padding(6)
                                .background(Circle().fill(.gray.opacity(0.9)))
                                .padding(.vertical, 4)
                                .opacity(title.isEmpty || dream.isEmpty ? 0 : 1)
                        }
                    }
                    HStack {
                        TextField("Dream Name", text: $title)
                            .font(.title)
                            .bold()
                        Spacer()
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                    }
                    
                    TextField("Start new dream entry...", text: $dream, axis: .vertical)
                        .padding(.vertical)
                    Spacer()
                    Button {
                        Task {
                            do {
                                try await getOverallAnalysis(dream_description: dream)
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    } label: {
                        Text("Get Overall Analysis")
                    }
                    Spacer()
                }
                .padding()
                TabbarView()
            }
        }
    }
}

#Preview {
    LoggingView()
}
