//
//  VocaPinWidget.swift
//  VocaPinWidget
//
//  Created by Bill Zhang on 8/23/25.
//

import WidgetKit
import SwiftUI

struct VocaPinWidget: Widget {
    let kind: String = "VocaPinWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NoteProvider()) { entry in
            VocaPinWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("VocaPin Notes")
        .description("View your sticky notes on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    VocaPinWidget()
} timeline: {
    NoteEntry(date: .now, note: SampleNote.sample)
}
