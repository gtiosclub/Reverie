import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date = Date()
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry() }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        completion(Timeline(entries: [SimpleEntry()], policy: .never))
    }
}

struct LoggingWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack {
            Image("WidgetBackground")
                .resizable()
                .scaledToFill()
                .clipped()
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: "reverie://logging"))
    }
}


struct LoggingWidget: Widget {
    let kind = "LoggingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LoggingWidgetEntryView(entry: entry)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    LoggingWidget()
} timeline: {
    SimpleEntry()
}
