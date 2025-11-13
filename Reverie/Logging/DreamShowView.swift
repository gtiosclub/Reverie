import SwiftUI

struct DreamShowView: View {
    let dream: DreamModel
    @State private var expanded = false
    @State private var glowPulse = false
    @State private var showInfo = false

    
    var body: some View {
        VStack {
            ScrollView {
                Text(dream.loggedContent)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            
            
            
            
            if dream.finishedDream != "None"{
                Spacer()

                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 22))
                            .padding(.trailing, -2)
                            .padding(.leading, 5)
                        
                        Text("Finish my dream")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        if expanded {
                            Button(action: {
                                withAnimation {
                                    showInfo.toggle()
                                }
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 21))
                                    .opacity(showInfo ? 1: 0.6)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 5)
                            .padding(.leading, 2)
                        }
                        Spacer()

                        Image(systemName: expanded ? "chevron.down" :"chevron.up")
                            .foregroundColor(.white)
                        
                    }
                    .padding(11)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 6)
                    .padding(.bottom, expanded ? 5 : 0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showInfo = false
                            expanded.toggle()
                        }
                    }
                    
                    if showInfo {
                        
                        HStack(alignment: .top, spacing: 0) {
                            Spacer().frame(width: 10)
                            Text("Using your description of your dream, we created a potential ending to the story.")
                                .font(.system(size: 13))
                                
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.leading)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            Spacer().frame(width: 20)
                        }
                        .padding(.bottom, 17)
                        .padding(.top, -10)
                        
                        
                    }
                    if expanded {

                        
                        ScrollView {
                            Text(dream.finishedDream)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.leading, 15)
                                .padding(.bottom)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxHeight: 400)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 46/255, green: 39/255, blue: 137/255),
                            Color(red: 64/255, green: 57/255, blue: 155/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(30)
                .shadow(
                    color: Color(red: 60/255, green: 53/255, blue: 151/255)
                        .opacity(glowPulse ? 0.9 : 0.4),
                    radius: glowPulse ? 12 : 6
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
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
                        .shadow(color: .white.opacity(0.25), radius: 1)
                )
                .padding(.horizontal)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowPulse.toggle()
                    }
                }
                .animation(.easeInOut, value: expanded)
            }        }
    }
}

#Preview {
    DreamShowView(dream: DreamModel(
        userID: "1",
        id: "1",
        title: "Cave Diving",
        date: Date(),
        loggedContent: "This is a logged dream example. You can scroll through it here.",
        generatedContent: "Example",
        tags: [.mountains, .rivers],
        image: ["Test"],
        emotion: .happiness,
        finishedDream: """
        The quiet beauty of early morning often goes unnoticed, yet it holds a kind of magic that no other time of day can match. As the first rays of sunlight spill over the horizon, the world awakens slowly, shaking off the stillness of the night. The air feels crisp and pure, carrying the faint scent of grass, earth, and dew. Birds begin to stir, filling the silence with soft melodies that seem to welcome the dawn itself. Trees stand tall and calm, their leaves glistening like tiny mirrors reflecting the light of a new day. In these precious moments, time feels slower, more forgiving — as if nature is offering a quiet invitation to begin again. Whether it’s the gentle steam rising from a warm cup of tea, the distant hum of a city coming to life, or the golden light touching everything it meets, morning reminds us that renewal is constant, and every sunrise brings with it the hope of something new.
        """))
}
