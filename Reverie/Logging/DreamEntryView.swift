//
//  DreamEntryView.swift
//  Reverie
//
//  Created by Neel Sani on 10/2/25.
//

import SwiftUI

struct DreamEntryView: View {
    let dream: DreamModel
    @State private var goBack = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text(dream.date.formatted())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.darkGray))
                
                Picker("Dream Tabs", selection: $selectedTab) {
                                    Text("Logged").tag(0)
                                    Text("Generated").tag(1)
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.darkGray))
                
                TabView(selection: $selectedTab) {
                    ScrollView {
                        Text(dream.loggedContent)
                            .foregroundColor(.white)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    .background(Color(.darkGray))
                    .tag(0)
                    
                    ScrollView {
                        Text(dream.generatedContent)
                            .foregroundColor(.white)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    .background(Color(.darkGray))
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // hides the dots
                .animation(.easeInOut, value: selectedTab)
                
               
//                Color(.darkGray).frame(height: 40).opacity(0)
//               
//                ScrollView {
//                    Text(dream.loggedContent)
//                        .foregroundColor(.white)
//                        .padding(.horizontal)
//                        .padding(.bottom, 24)
//                        .multilineTextAlignment(.leading)
//                }
//                .background(Color(.darkGray))
            }
            .background(Color(.darkGray))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        goBack = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Archive")
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $goBack) {
                DreamArchiveView()
            }
        }
    }
}
#Preview {
    DreamEntryView(dream: DreamModel.init(userID: "1", id: "1", title: "Test", date: Date(), loggedContent: "Test", generatedContent: "Test", tags: [.mountains, .rivers], image: "Test", emotion: .happiness))
}
