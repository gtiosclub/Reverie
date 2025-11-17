//
//  SaveDreamView.swift
//  Reverie
//
//  Created by Anoushka Gudla on 9/23/25.
//

import SwiftUI
import Foundation

struct SaveDreamView: View {
    @State private var navigateToDreamEntry = false
    @State private var createdDream: DreamModel?
    @State private var showTagDropdown = false
    @State private var selectedDate = Date()
    @State private var showPicker = false
    @State private var title = ""

    @Environment(\.presentationMode) var presentationMode
    
    @State var newDream: DreamModel
    @State private var searchText: String = ""

    @State private var searchBarY: CGFloat = 0

    struct InnerTagView: View {
        var tag: DreamModel.Tags
        var imageName: String
        var color: Color
        var added: Bool
        
        var body: some View {
            HStack(spacing: 5) {
                Image(systemName: imageName)
                    .foregroundColor(color)
                Text(tag.rawValue.capitalized)
                    .foregroundStyle(Color.white)
                    .font(.system(size:14))
                Image(systemName: added ? "xmark" : "plus")
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .frame(height: 20)

            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(red: 44/255, green: 44/255, blue: 61/255))
            )
        }
    }
    
    var filteredTags: [DreamModel.Tags] {
        DreamModel.Tags.allCases.filter { tag in
            (!newDream.tags.contains(tag)) &&
            (searchText.isEmpty ||
             tag.rawValue.localizedCaseInsensitiveContains(searchText))
        }
    }

    

    var dropdownView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(filteredTags, id: \.self) { tag in
                    Button(action: {
                        newDream.tags.append(tag)
                        searchText = ""
                    }) {
                        InnerTagView(
                            tag: tag,
                            imageName: DreamModel.tagImages(tag: tag),
                            color: DreamModel.tagColors(tag: tag),
                            added: false
                        )
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .padding(.leading, 50)
                    .padding(.trailing, 10)
                    .padding(.vertical, 4)
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(maxHeight: 450)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.clear)
                .darkGloss()
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )
        )
        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 8)
    }

    
    var body: some View {

        ZStack(alignment: .topLeading) {
            BackgroundView()
                    .ignoresSafeArea()
            
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 5/255, green: 7/255, blue: 20/255),
                                        Color(red: 17/255, green: 18/255, blue: 32/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 55, height: 55)

                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.8),
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.6),
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.8)
                                            ]),
                                            center: .center,
                                            startAngle: .degrees(0),
                                            endAngle: .degrees(360)
                                        ),
                                        lineWidth: 0.5
                                    )
                                    .blendMode(.screen)
                            )

                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(.leading, -4)
                            .bold(true)
                    }
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
                
                Spacer()

                Text(newDream.title)
                    .foregroundColor(.white)
                    .font(.custom("InstrumentSans-SemiBold", size: 18))
                    .multilineTextAlignment(.center)
                    .dreamGlow()

                Spacer()
                
                Button(action: {
                    Task {
                        await saveDream()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 42/255, green: 35/255, blue: 133/255),
                                        Color(red: 64/255, green: 57/255, blue: 155/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 55, height: 55)

                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.8),
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.6),
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.8)
                                            ]),
                                            center: .center,
                                            startAngle: .degrees(0),
                                            endAngle: .degrees(360)
                                        ),
                                        lineWidth: 0.5
                                    )
                                    .blendMode(.screen)
                            )
                            .glassEffect()

                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 10) {
                    

                    Text("Edit Date")
                        .padding(.bottom, 4)
                    
                    Button(action: {
                        showPicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color(red: 112/255, green: 124/255, blue: 247/255))
                            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 112/255, green: 124/255, blue: 247/255))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.4))
                                .fill(Color(red: 30/255, green: 29/255, blue: 55/255))
                        )
                    }
                    .popover(isPresented: $showPicker, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                        VStack {
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .accentColor(Color(red: 112/255, green: 124/255, blue: 247/255))
                        }
                        .padding(16)
                        .frame(width: 340)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 1/255, green: 1/255, blue: 20/255))
                        )
                        .presentationCompactAdaptation(.none)
                    }
                    .padding(.bottom, 18)


                    
                    Text("Add Themes")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.bottom, 5)

                    HStack() {

                        let activeWidth: CGFloat = showTagDropdown ? 330 : 373

                        ZStack {
                            Capsule()
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.8),
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.8)
                                        ]),
                                        center: .center,
                                        startAngle: .degrees(0),
                                        endAngle: .degrees(360)
                                    ),
                                    lineWidth: 1
                                )
                                .frame(
                                    width: activeWidth,
                                    height: 52.5
                                )
                                .blendMode(.screen)
                                .shadow(color: .white.opacity(0.25), radius: 1)

                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.8))

                                TextField("Search or add tags", text: $searchText)
                                    .foregroundColor(.white)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)

                                Spacer()
                            }
                            .padding(15)
                            .cornerRadius(30)
                            .background(
                                Color.black.opacity(0.25)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .glassEffect(.regular)
                            )
                            .frame(width: activeWidth, alignment: .leading)

                            .background(
                                GeometryReader { geo in
                                    Color.clear.onAppear {
                                        searchBarY = geo.frame(in: .named("stack")).minY
                                    }
                                }
                            )
                            .onTapGesture {
                                withAnimation {
                                    showTagDropdown.toggle()
                                }
                            }
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            .padding(.trailing, 1)
                        }

                        if showTagDropdown {
                            Button {
                                withAnimation {
                                    searchText = ""
                                    showTagDropdown = false
                                }
                            } label: {
                                ZStack {
                                    Capsule()
                                        .strokeBorder(
                                            AngularGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.8),
                                                    Color.white.opacity(0.1),
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.1),
                                                    Color.white.opacity(0.8)
                                                ]),
                                                center: .center,
                                                startAngle: .degrees(0),
                                                endAngle: .degrees(360)
                                            ),
                                            lineWidth: 1
                                        )
                                        .frame(width: 50, height: 50)
                                        .blendMode(.screen)
                                        .shadow(color: .white.opacity(0.25), radius: 1)

                                    Image(systemName: "xmark")
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.system(size: 22))
                                }
                            }
                            .cornerRadius(30)
                            .background(
                                Color.black.opacity(0.25)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .glassEffect(.regular)
                            )
                        }
                    }
                    .padding(.leading, 30)
                    .frame(width: 370)

                    


                    if !newDream.tags.isEmpty {
                        WrappingTagsView(tags: newDream.tags) { tag in
                            Button(action: {
                                if let index = newDream.tags.firstIndex(of: tag) {
                                    newDream.tags.remove(at: index)
                                }
                            }) {
                                InnerTagView(
                                    tag: tag,
                                    imageName: DreamModel.tagImages(tag: tag),
                                    color: DreamModel.tagColors(tag: tag),
                                    added: true
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10)
                        .transition(.opacity)
                    }
                }
                
                Spacer()
            }
            .padding()
            .padding(.top, 60)
            

            if showTagDropdown {
                dropdownView
                    .frame(width: 400)
                    .offset(y: searchBarY + 60)
                    .padding(.horizontal)
                    .scaleEffect(showTagDropdown ? 1 : 0.97)
                    .opacity(showTagDropdown ? 1 : 0)
                    .animation(.easeInOut(duration: 0.18), value: showTagDropdown)
                
            }


            NavigationLink(
                destination: DreamEntryView(dream: createdDream ?? newDream, backToArchive: true),
                isActive: $navigateToDreamEntry
            ) {
                EmptyView()
            }
            .hidden()

        }
        .navigationBarBackButtonHidden(true)
        .coordinateSpace(name: "stack")


        .onChange(of: showTagDropdown) { open in
        if !open { searchText = "" }
    }
    .preferredColorScheme(.dark)
}
    
    func saveDream() async {
        do {
            newDream = try await FirebaseDreamService.shared.fetchDream(dreamID: "FTg5JuchpAgW553xcf9F")!
            newDream.date = selectedDate
            var createdDreamID = try await FirebaseDreamService.shared.createDreamWithImage(dream: newDream)
//            var createdDreamID = try await FirebaseDreamService.shared.createDream(dream: newDream)
            
            createdDream = try await FirebaseDreamService.shared.fetchDream(dreamID: createdDreamID)
            FirebaseLoginService.shared.currUser?.dreams.append(createdDream!)
//            FirebaseDCService.shared.generateImage(for: createdDream!) // COMMMENT THIS OUT WHEN HARD CODING
//            FirebaseDCService.shared.generateImageForDC(for: createdDream!) // COMMMENT THIS OUT WHEN HARD CODING
            navigateToDreamEntry = true
            
            updateTagDescriptions(tags: newDream.tags)
        } catch {
            print("Failed to save dream: \(error)")
        }
    }
}

#Preview {
    SaveDreamView(
        newDream: DreamModel(
            userID: "idk",
            id: "idk",
            title: "idk",
            date: Date(),
            loggedContent: "",
            generatedContent: "",
            tags: [],
            image: [""],
            emotion: .happiness,
            finishedDream: "None"
        )
    )
}

struct WrappingTagsView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let tags: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(tags: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.tags = tags
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(minHeight: 0)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags), id: \.self) { tag in
                content(tag)
                    .padding(.trailing, spacing)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if tag == tags.last {
                            width = 0
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if tag == tags.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
}
