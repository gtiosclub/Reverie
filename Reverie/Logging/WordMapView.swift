import SwiftUI
import UIKit

struct WordItem: Identifiable {
    let id = UUID()
    let text: String
    let count: Int
}

struct PlacedWord: Identifiable {
    let id = UUID()
    let item: WordItem
    let fontSize: CGFloat
    let position: CGPoint
    let size: CGSize
}

struct WordMap: View {
    let keywords: [String]
    let minFont: CGFloat = 22
    let maxFont: CGFloat = 56
    let maxAttemptsPerWord = 2000
    let spiralStep: CGFloat = 2.0
    let paddingAroundWords: CGFloat = 4.0
    
    @State private var placed: [PlacedWord] = []
    
    private func counts(from keywords: [String]) -> [WordItem] {
        var m: [String: Int] = [:]
        for k in keywords { m[k, default: 0] += 1 }
        return m.map { WordItem(text: $0.key, count: $0.value) }
                .sorted { $0.count > $1.count }
    }
    
    private func measure(_ text: String, fontSize: CGFloat) -> CGSize {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let s = (text as NSString).size(withAttributes: attrs)
        return CGSize(width: ceil(s.width) + paddingAroundWords, height: ceil(s.height) + paddingAroundWords)
    }
    
    private func rectCentered(at center: CGPoint, size: CGSize) -> CGRect {
        CGRect(x: center.x - size.width/2, y: center.y - size.height/2, width: size.width, height: size.height)
    }
    
    // spiral placement and collision check
    private func computeLayout(in size: CGSize) -> [PlacedWord] {
        let items = counts(from: keywords)
        guard !items.isEmpty else { return [] }
        let counts = items.map { $0.count }
        let wmin = counts.min() ?? 1
        let wmax = counts.max() ?? 1
        let denom = (wmax - wmin) == 0 ? 1.0 : Double(wmax - wmin)
        
        var result: [PlacedWord] = []
        let center = CGPoint(x: size.width/2, y: size.height/2)
        
        for item in items {
            // map count -> font size
            let normalized = CGFloat((Double(item.count - wmin) / denom))
            let fontSize = minFont + normalized * (maxFont - minFont)
            let measured = measure(item.text, fontSize: fontSize)
            
            // attempt spiral placements
            var placedWord: PlacedWord? = nil
            var t: CGFloat = 0
            var attempts = 0
            while attempts < maxAttemptsPerWord {
                attempts += 1
                let r = spiralStep * t
                let theta = t * 0.45
                let dx = r * cos(theta)
                let dy = r * sin(theta)
                let candidateCenter = CGPoint(x: center.x + dx, y: center.y + dy)
                let rect = rectCentered(at: candidateCenter, size: measured)
                
                // must be inside bounds
                if rect.minX < 0 || rect.minY < 0 || rect.maxX > size.width || rect.maxY > size.height {
                    t += 1.0
                    continue
                }
                
                // collision check against already placed
                var collision = false
                for p in result {
                    if rect.intersects(rectCentered(at: p.position, size: p.size).insetBy(dx: -2, dy: -2)) {
                        collision = true
                        break
                    }
                }
                
                if !collision {
                    placedWord = PlacedWord(item: item, fontSize: fontSize, position: candidateCenter, size: measured)
                    break
                }
                
                t += 1.0
            }
            
            // if not placed (rare), try to place somewhere near center grid-ish
            if let pw = placedWord {
                result.append(pw)
            } else {
                // fallback: search grid for any free spot
                var found = false
                let step: CGFloat = 8
                for y in stride(from: paddingAroundWords, to: size.height - paddingAroundWords, by: step) {
                    if found { break }
                    for x in stride(from: paddingAroundWords, to: size.width - paddingAroundWords, by: step) {
                        let rect = rectCentered(at: CGPoint(x: x, y: y), size: measured)
                        if rect.minX < 0 || rect.minY < 0 || rect.maxX > size.width || rect.maxY > size.height { continue }
                        var coll = false
                        for p in result {
                            if rect.intersects(rectCentered(at: p.position, size: p.size).insetBy(dx: -2, dy: -2)) {
                                coll = true; break
                            }
                        }
                        if !coll {
                            result.append(PlacedWord(item: item, fontSize: fontSize, position: CGPoint(x: x, y: y), size: measured))
                            found = true
                            break
                        }
                    }
                }
                // drop at center if not found (will overlap minimally)
                if !found {
                    result.append(PlacedWord(item: item, fontSize: fontSize, position: center, size: measured))
                }
            }
        }
        
        return result
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                // placed words
                ForEach(placed) { p in
                    Text(p.item.text)
                        .font(.system(size: p.fontSize, weight: .semibold))
                        .foregroundColor(color(for: p.item.count))
                        .position(p.position)
                }
            }
            .onAppear {
                placed = computeLayout(in: geo.size)
            }
            .onChange(of: geo.size) { newSize in
                placed = computeLayout(in: newSize)
            }
        }
        .frame(width: 380, height: 420)
    }
    
    // simple palette
    private func color(for count: Int) -> Color {
        let palette: [Color] = [
            Color(red: 0.39, green: 0.68, blue: 0.90),
            Color(red: 0.56, green: 0.80, blue: 0.67),
            Color(red: 0.99, green: 0.86, blue: 0.48),
            Color(red: 0.98, green: 0.65, blue: 0.62),
            Color(red: 0.75, green: 0.66, blue: 0.91)
        ]
        return palette[count % palette.count]
    }
}

struct WordMap_Previews: PreviewProvider {
    static var sample = [ // random words for now
        "lucid","flying","ocean","teeth","chase","lucid","lucid","flying","memory",
        "falling","music","house","door","shadow","friend","ocean","ocean","chase",
        "memory","memory","memory","dream","dream"
    ]
    static var previews: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.2)
            WordMap(keywords: sample)
        }
        .ignoresSafeArea()
    }
}
