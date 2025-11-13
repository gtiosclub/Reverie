//
//  DreamModel.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/4/25.
//

import Foundation
import FoundationModels
import SwiftUI


class DreamModel: Decodable {
    var id: String
    var userID: String
    var title: String
    var date: Date
    var loggedContent: String
    var generatedContent: String
    var tags: [Tags]
    var image: [String?]
    var emotion: Emotions
    var finishedDream: String = "None"
    
    @Generable
    enum Tags: String, Codable, CaseIterable {
        case mountains, rivers, forests, animals, school, water, nature, fire, city, home, work, love, family, friends, authority, strangers, travel, chase, fight, death, fantasy, past, future, search, falling, flying, food, health, trapped, money, celebration, teeth, rooms, disasters
    }
    
    @Generable
    enum Emotions: String, Codable, CaseIterable {
        case happiness, sadness, anger, fear, embarrassment, anxiety, neutral
        
        var swiftUIColor: Color {
            switch self {
            case .happiness: return .yellow
            case .sadness: return .blue
            case .anger: return .red
            case .fear: return .purple
            case .embarrassment: return .pink
            case .anxiety: return .orange
            default: return .gray
            }
        }
    }
    
    static func emotionColors(emotion: Emotions) -> Color {
        switch emotion {
        case .happiness: return Color(hex: "#E0C341")
        case .sadness: return Color(hex: "#3089D3")
        case .anger: return Color(hex: "#CD3838")
        case .fear: return Color(hex: "#9B32EC")
        case .embarrassment: return Color(hex: "#77A437")
        case .anxiety: return Color(hex: "#B96531")
        case .neutral: return Color(hex: "#D9D9D9")
        }
    }

    static func tagImages(tag: Tags) -> String {
        switch(tag) {
        case .mountains: return "mountain.2.fill"
        case .rivers: return "water.waves"
        case .forests: return "tree.fill"
        case .school: return "graduationcap.fill"
        case .flying: return "bird.fill"
        case .food: return "carrot.fill"
        case .animals: return "pawprint.fill"
        case .health: return "stethoscope.circle.fill"
        case .trapped: return "lock.fill"
        case .money: return "dollarsign.bank.building.fill"
        case .celebration: return "party.popper.fill"
        case .teeth: return "mouth.fill"
        case .rooms: return "door.left.hand.open"
        case .disasters: return "tornado"
        case .strangers: return "person.line.dotted.person.fill"
        case .travel: return "airplane"
        case .chase: return "figure.run"
        case .fight: return "figure.archery"
        case .death: return "exclamationmark.octagon.fill"
        case .fantasy: return "wand.and.sparkles"
        case .past: return "arrow.left.circle.fill"
        case .future: return "arrow.right.circle.fill"
        case .search: return "magnifyingglass.circle.fill"
        case .falling: return "figure.fall"
        case .water: return "drop.fill"
        case .nature: return "leaf.fill"
        case .fire: return "flame.fill"
        case .city: return "building.2.fill"
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .love: return "heart.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .friends: return "person.2.fill"
        case .authority: return "crown.fill"
        }
    }

    static func tagColors(tag: Tags) -> Color {
        switch tag {
        case .mountains: return Color(hex: "#724227")
        case .rivers: return Color(hex: "#779ECB")
        case .forests: return Color(hex: "#45773E")
        case .school: return Color(hex: "#5B5BE3")
        case .flying: return Color(hex: "#99D1FF")
        case .food: return Color(hex: "#DF8852")
        case .animals: return Color(hex: "#C19A6B")
        case .health: return Color(hex: "#D15B5B")
        case .trapped: return Color(hex: "#585DB2")
        case .money: return Color(hex: "#DDF2D1")
        case .celebration: return Color(hex: "#E1CB6A")
        case .teeth: return Color(hex: "#E5F99D")
        case .rooms: return Color(hex: "#93F3E3")
        case .disasters: return Color(hex: "#8690FF")
        case .strangers: return Color(hex: "#DBA5F2")
        case .travel: return Color(hex: "#C4EDFB")
        case .chase: return Color(hex: "#E971A7")
        case .fight: return Color(hex: "#C23B22")
        case .death: return Color(hex: "#C23B22")
        case .fantasy: return Color(hex: "#D291BC")
        case .past: return Color(hex: "#97693C")
        case .future: return Color(hex: "#E9936E")
        case .search: return Color(hex: "#F6C8A0")
        case .falling: return Color(hex: "#9956AF")
        case .water: return Color(hex: "#7CBAEC")
        case .nature: return Color(hex: "#A6D58D")
        case .fire: return Color(hex: "#F2B255")
        case .city: return Color(hex: "#D4D4D4")
        case .home: return Color(hex: "#FFB700")
        case .work: return Color(hex: "#8E8E8E")
        case .love: return Color(hex: "#FEBDCE")
        case .family: return Color(hex: "#83ACFF")
        case .friends: return Color(hex: "#B19ED1")
        case .authority: return Color(hex: "#F8F288")  
        }
    }
    
    
    static func tagDescription(tag: Tags) -> String {
        switch(tag) {
            
        case .mountains:
            "Mountains in dreams are powerful symbols often representing challenges, aspirations, and personal growth. They embody the journey toward achieving goals, spiritual elevation, or overcoming obstacles. Climbing a mountain signifies ambition, perseverance, and the effort required to reach success, while standing atop one symbolizes achievement, clarity, and a broader perspective."
        case .rivers:
            "Rivers in dreams often symbolize the flow of life, emotions, and personal transformation. They represent movement, change, and the passage of time. A calm, clear river may reflect inner peace or emotional balance, while a turbulent or murky river can signal confusion, emotional struggle, or life’s unpredictability. Rivers remind the dreamer that life is constantly flowing, urging acceptance and adaptability."
        case .forests:
            "Forests in dreams often symbolize the mystery of the subconscious mind, representing both exploration and uncertainty. They can reflect a journey into the unknown, a place where hidden thoughts, fears, and desires reside. Entering a forest may signify self-discovery, transformation, or confronting aspects of oneself that have been neglected. Depending on the mood of the dream, forests can feel either magical and healing or dark and disorienting."
        case .animals:
            "Animals in dreams often represent the instinctual, emotional, and intuitive aspects of the self. They embody raw, natural forces within us, and desires, fears, or qualities that may be suppressed in waking life. The behavior, species, and emotional tone of the animal reveal how we relate to our instincts. Dreaming of animals invites us to reconnect with authenticity, vitality, and the natural intelligence that guides us beneath reason."
        case .school:
            "Schools in dreams often symbolize learning, growth, and self-evaluation. They represent life’s lessons, both formal and personal, and the process of acquiring wisdom through experience. Dreaming of being in school can reflect feelings of testing, judgment, or the desire for self-improvement. It often mirrors situations in waking life where the dreamer feels they are being graded or must prove their abilities."
        case .water:
            "Water is one of the most universal and powerful dream symbols, representing the emotional and subconscious realms. It reflects the flow of feelings, intuition, and the deeper layers of the psyche. The condition of the water, whether calm, turbulent, clear, or murky, reveals the dreamer’s emotional state. Water’s presence often points to cleansing, transformation, or the need to embrace emotional truth."
        case .nature:
            "Nature in dreams often symbolizes harmony, renewal, and connection with the self and the world. It represents the natural cycles of life, growth, and balance between body, mind, and spirit. Dreaming of being surrounded by nature reflects a desire for peace, grounding, or a return to simplicity. It can also signal healing and reconnection with instincts that have been forgotten in daily life."
        case .fire:
            "Fire in dreams often symbolizes passion, transformation, and destruction leading to renewal. It represents intense energy, emotion, and the power of change. Depending on the dream’s tone, fire can be both creative and destructive. It may signify inner strength, purification, or emotional turmoil that needs to be acknowledged and controlled. Fire reminds the dreamer of life’s dual forces: creation and dissolution."
        case .city:
            "Cities in dreams often symbolize society, ambition, and the structure of one’s waking life. They represent the collective world, such as the environment of work, relationships, and social expectations. Dreaming of a city can reflect how you navigate complexity, connection, and responsibility. It may also point to your sense of belonging, independence, or overwhelm within a busy or demanding environment."
        case .home:
            "Dreams of home often symbolize the self, inner security, and emotional foundation. A home represents comfort, belonging, and personal identity. It is the space that mirrors one’s inner world, revealing how grounded or unsettled the dreamer feels. Dreaming of a home can point to the desire for safety, self-understanding, or reconnection with parts of life that provide stability and warmth."
        case .work:
            "Work in dreams symbolizes purpose, responsibility, and self-worth. It reflects how the dreamer engages with goals, effort, and the desire for achievement or recognition. Dreaming of work often points to questions of balance, motivation, or fulfillment in daily life. It can also represent the inner drive to create, contribute, and find meaning through discipline and perseverance."
        case .love:
            "Love in dreams symbolizes connection, unity, and emotional fulfillment. It reflects the longing for harmony between the inner and outer self, as well as the desire to be seen, accepted, and understood. Dreaming of love often represents openness, healing, and the integration of opposites within the psyche. It embodies the creative force of compassion and reminds the dreamer of the transformative power of genuine emotional connection."
        case .family:
            "Family in dreams symbolizes identity, belonging, and the foundations of emotional life. It represents the relationships and patterns that shape one’s sense of self. Dreaming of family often reflects inner dynamics, inherited beliefs, or unresolved feelings connected to support and acceptance. It can also signify the integration of different aspects of the psyche, reminding the dreamer of the importance of connection, roots, and unconditional love."
        case .friends:
            "Friends in dreams symbolize connection, trust, and aspects of the self reflected through others. They represent companionship, understanding, and the exchange of emotional support. Dreaming of friends often points to qualities the dreamer values or wishes to develop, as well as the need for belonging and authenticity in relationships. Friends in dreams remind the dreamer of mutual growth, empathy, and the shared journey toward self-awareness."
        case .authority:
            "Authority in dreams symbolizes power, control, and the structure of inner and outer order. It represents the forces that guide, restrict, or challenge the dreamer’s autonomy. Dreaming of authority often reflects one’s relationship with rules, responsibility, and self-discipline. It can signify the internal struggle between obedience and independence, reminding the dreamer to find balance between respecting boundaries and asserting personal truth."
        case .strangers:
            "Strangers in dreams symbolize the unknown aspects of the self and new possibilities of growth. They often represent hidden emotions, untapped potential, or qualities that the dreamer has yet to recognize. Encountering a stranger can reflect curiosity, uncertainty, or fear of change, depending on the feeling within the dream. Strangers remind the dreamer that every unknown face mirrors a part of the inner world waiting to be understood or integrated."
        case .travel:
            "Travel in dreams symbolizes movement, change, and the journey of personal transformation. It reflects the dreamer’s passage through different stages of life, growth, or understanding. Traveling may signify a search for purpose, freedom, or new experiences beyond familiar limits. It often represents the soul’s desire for exploration and renewal, reminding the dreamer that growth comes through stepping into the unknown."
        case .chase:
            "A chase in dreams symbolizes avoidance, pursuit, and confrontation with fear or desire. It reflects an inner conflict where the dreamer is either fleeing from unresolved emotions or striving toward something deeply desired but not yet attained. Being chased often reveals anxiety or pressure in waking life, while chasing another may signify ambition or obsession. The chase represents the tension between escape and engagement, urging the dreamer to face what is being avoided within."
        case .fight:
            "A fight in dreams symbolizes inner conflict, resistance, and the struggle for power or resolution. It represents the clash between opposing forces within the self, such as fear and courage. Dreaming of fighting can reveal repressed anger, frustration, or the need to defend personal boundaries. It reflects the process of confronting challenges and integrating strength, reminding the dreamer that conflict often precedes growth and self-mastery."
        case .death:
            "Death in dreams symbolizes transformation, endings, and the renewal of the self. It rarely foretells physical death but instead marks the close of one phase and the beginning of another. Dreaming of death reflects the process of letting go of identities, attachments, or patterns that no longer serve growth. It signifies profound change and rebirth, reminding the dreamer that every ending holds the seed of new life and deeper awareness."
        case .fantasy:
            "Fantasy in dreams symbolizes imagination, desire, and the creative potential of the unconscious mind. It represents the freedom to explore ideas or emotions beyond the limits of reality. Dreaming of fantastical worlds or beings reflects the dreamer’s wish for escape, inspiration, or transformation. It reveals hidden hopes and possibilities, reminding the dreamer that imagination is both a refuge and a pathway to self-discovery."
        case .past:
            "The past in dreams symbolizes memory, reflection, and the influence of former experiences on the present self. It represents unfinished emotions, lessons, or attachments that continue to shape one’s identity. Dreaming of the past often signals a need for understanding, healing, or closure. It invites the dreamer to integrate old experiences with current awareness, reminding them that growth comes from accepting and learning from what has been."
        case .future:
            "The future in dreams symbolizes hope, potential, and the unfolding path of destiny. It reflects the dreamer’s aspirations, fears, and expectations about what lies ahead. Dreaming of the future often reveals inner guidance or anxiety about change and uncertainty. It represents the creative power of intention, reminding the dreamer that the future is shaped by present choices and the vision one holds within."
        case .search:
            "A search in dreams symbolizes the quest for meaning, truth, or self-understanding. It reflects the dreamer’s desire to find something missing, whether clarity, purpose, or emotional fulfillment. Dreaming of searching often reveals inner restlessness or the awareness of unrealized potential. It represents the spiritual and psychological journey toward wholeness, reminding the dreamer that what is sought outwardly often resides within."
        case .falling:
            "Falling in dreams symbolizes loss of control, vulnerability, and surrender to the unknown. It reflects feelings of insecurity, fear of failure, or a sudden change that challenges stability. The descent often represents a release from ego or resistance, allowing deeper emotions or truths to surface. Falling reminds the dreamer of the need to trust the process of letting go, as only through surrender can new balance and understanding emerge."
        case .flying:
            "Flying in dreams symbolizes freedom, transcendence, and the awakening of personal power. It represents liberation from limitations, whether emotional, mental, or spiritual. Dreaming of flight reflects confidence, creativity, and the desire to rise above obstacles or boundaries. It embodies the soul’s longing for expansion and higher perspective, reminding the dreamer that true freedom begins within the mind and spirit."
        case .food:
            "Food in dreams symbolizes nourishment, desire, and the intake of emotional or spiritual energy. It represents what sustains the dreamer physically, mentally, and emotionally. Dreaming of food reflects the need for fulfillment, balance, or satisfaction in some area of life. It can also signify the absorption of new ideas or experiences, reminding the dreamer that true nourishment comes not only from what is consumed but from what feeds the soul."
        case .health:
            "Health in dreams symbolizes balance, vitality, and the harmony between body, mind, and spirit. It reflects the dreamer’s awareness of well-being and inner alignment. Dreaming of health often points to the need for restoration, self-care, or emotional healing. It represents the natural drive toward wholeness, reminding the dreamer that true health arises from living in harmony with one’s thoughts, feelings, and deeper truth."
        case .trapped:
            "Being trapped in dreams symbolizes restriction, fear, and the struggle for freedom. It reflects feelings of confinement within circumstances, relationships, or inner limitations. Dreaming of being trapped often reveals suppressed emotions, indecision, or resistance to change. It represents the tension between security and liberation, reminding the dreamer that release comes through awareness, courage, and the willingness to confront what holds them back."
        case .money:
            "Money in dreams symbolizes value, energy, and the exchange of personal power. It reflects the dreamer’s sense of self-worth, confidence, and ability to manifest desires. Dreaming of money often relates to security, opportunity, or fear of loss, depending on how it appears. It represents the flow of giving and receiving in life, reminding the dreamer that true wealth arises from inner abundance and the recognition of one’s own worth."
        case .celebration:
            "Celebration in dreams symbolizes joy, achievement, and the harmony of self-expression. It reflects emotional fulfillment, unity, and recognition of personal or collective success. Dreaming of celebration often signifies the integration of growth, healing, or the completion of an important cycle. It represents gratitude and renewal, reminding the dreamer to honor life’s milestones and the moments of connection that nourish the spirit."
        case .teeth:
            "Teeth in dreams symbolize strength, confidence, and the ability to express or defend oneself. They represent personal power and communication, as well as the process of growth and change. Dreaming of teeth falling out or breaking often reflects vulnerability, loss of control, or anxiety. Teeth remind the dreamer of the connection between vitality and self-expression, highlighting the need to face transitions with courage and authenticity."
        case .rooms:
            "Rooms in dreams symbolize the inner dimensions of the self and the different aspects of one’s mind or life. Each room represents a distinct emotional or psychological space, reflecting memories, desires, or hidden potential. Discovering new rooms often signifies personal growth or the awakening of unexplored qualities. Rooms remind the dreamer that the inner world is vast and layered, inviting exploration, healing, and self-understanding."
        case .disasters:
            "Disasters in dreams symbolize overwhelming change, emotional turmoil, and the breakdown of old structures. They reflect feelings of chaos, fear, or loss of control in waking life. Dreaming of natural or personal catastrophes often signals deep transformation, where destruction clears the way for renewal. Disasters remind the dreamer that upheaval, though frightening, can reveal hidden strength and the potential for rebuilding with greater clarity and purpose."
        }
    }

    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: [String], emotion: Emotions) {
        self.userID = userID
        self.id = id
        self.title = title
        self.date = date
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
        self.finishedDream = "None"
    }
    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: [String], emotion: Emotions, finishedDream: String) {
        self.userID = userID
        self.id = id
        self.title = title  
        self.date = date
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
        self.finishedDream = finishedDream
    }
}

extension DreamModel.Emotions {
    var displayName: String { rawValue.capitalized }
    
    var detailDescription: String {
        switch self {
        case .happiness:
            return "Filled with warmth, optimism, and an uplifted spirit."
        case .sadness:
            return "Characterized by sorrow, heartbreak, grief, and despair."
        case .anger:
            return "Fueled by frustration, restlessness, and emotional intensity."
        case .fear:
            return "Rooted in unease, looming danger, and heightened senses."
        case .embarrassment:
            return "Sparked by self-consciousness, vulnerability, and awkward moments."
        case .anxiety:
            return "Marked by worry, tension, and racing thoughts."
        case .neutral:
            return "Balanced with calm observation and grounded emotions."
        }
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
    
    static let profileContainer = Color(hex: "#1D1C3A")
}
