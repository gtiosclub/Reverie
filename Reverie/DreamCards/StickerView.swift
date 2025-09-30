//
//  StickerView.swift
//  Reverie
//
//  Created by Jacoby Melton on 9/30/25.
//

import SwiftUI

struct StickerView: View {
    // Maybe change from list of stickers to list of card model objects or something & get name + image from there
    let stickers: [Image]
    
    func makePages(stickers: [Image], size: Int) -> [[Image]] {
        var pages: [[Image]] = []
        var page: [Image] = []
        for (i, sticker) in stickers.enumerated() {
            if (i % size == 0 && i != 0) {
                pages.append(page)
                page = []
            }
            page.append(sticker)
        }
        while (page.count < 6) {
            page.append(Image(systemName: "cloud.circle.fill")) // fill page with blank images
        }
        pages.append(page)
        return pages
    }
    
    
    var body: some View {
        let pages: [[Image]] = makePages(stickers: stickers, size: 6)
        TabView {
            ForEach(pages.indices, id: \.self) { i in
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        ForEach(pages[i][0..<(pages[i].count / 2)].indices, id: \.self) { j in
                            CharacterView(sticker: pages[i][j])
                        }
                    }
                    GridRow {
                        ForEach(pages[i][(pages[i].count / 2)...].indices, id: \.self) { j in
                            CharacterView(sticker: pages[i][j])
                        }
                    }
                }
            }
        }
        .tabViewStyle(.page)
        
            
        
    }
}

struct CharacterView: View {
    let sticker: Image
    var body: some View {
        VStack {
            Button(action: {
                // Click on sticker action
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 105, height: 105)
    
                    sticker
                        .resizable()
                        .modifier(StickerFormat())
                }
            }
            
            
            Text("Name")
                .foregroundColor(.white)
        }
    }
}

struct StickerFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .foregroundColor(.white.opacity(0.7))
            .padding(5)
    }
}


#Preview {
    StickerView(stickers: [Image("MoonCloud"), Image("AIFly"),
                           Image("MoonCloud"), Image("AIFly"),
                           Image("MoonCloud"), Image("AIFly"),
                           Image("MoonCloud"), Image("AIFly")])
}
