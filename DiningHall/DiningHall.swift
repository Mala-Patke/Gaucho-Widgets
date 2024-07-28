//
//  DiningHall.swift
//  DiningHall
//
//  Created by Ali Shahid on 7/28/24.
//

import WidgetKit
import SwiftUI
import Intents
import Foundation
import AppIntents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> DiningHallMenuEntry {
        DiningHallMenuEntry(name: "loading...", meal: "loading...", items: [menuResult(station: "loading...", items: [menuItem(name: "loading...")])])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (DiningHallMenuEntry) -> ()) {
        Task {
            do {
                let res = try await getDiningHallData()
                completion(res)
            } catch {
                print("Epic DHD fail snapshot")
            }
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<DiningHallMenuEntry>) -> ()) {
        Task {
            do {
                let menu = try await getMenu("de-la-guerra", "dinner")
                let time = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                let res = DiningHallMenuEntry(name: "DLG", meal: "dinner", items: menu)
                
                let timeline = Timeline(entries: [res], policy: .after(time))
                completion(timeline)
            } catch {
                print("Epic DHD fail timeline at \(Date())")
            }
        }
    }
}

struct menuNavUp : AppIntent {
    static var title : LocalizedStringResource = "Next"
    static var description = IntentDescription("Increments menu index")
    
    func perform() async throws -> some IntentResult {
        DiningHallMenuEntry.index += 1
        print(DiningHallMenuEntry.index)
        return .result()
    }
}

struct menuNavDown : AppIntent {
    static var title : LocalizedStringResource = "Back"
    static var description = IntentDescription("Decrements menu index")
    
    func perform() async throws -> some IntentResult {
        if(DiningHallMenuEntry.index == 0) { return .result() }
            
        DiningHallMenuEntry.index -= 1
        print(DiningHallMenuEntry.index)
        return .result()
    }
}

// Source: https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct DiningHallEntryView : View {
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        HStack {
            VStack {
                Text(entry.name)
                    .lineLimit(1)
                    .font(.largeTitle)
                    .scaledToFill()
                Text(entry.meal)
                    .lineLimit(1)
                    .scaledToFill()
                    .minimumScaleFactor(0.75)
                HStack {
                    Button(intent: menuNavDown()) {
                        Image(systemName: "chevron.left.circle.fill")
                    }.if(DiningHallMenuEntry.index == 0) {
                        view in view.hidden()
                    }
                    
                    Button(intent: menuNavUp()) {
                        Image(systemName: "chevron.right.circle.fill")
                    }.if(DiningHallMenuEntry.index >= entry.items.count-1) {
                        view in view.hidden()
                    }
                }
            }
            VStack {
                Text(entry.items[DiningHallMenuEntry.index].station)
                    .bold()
                VStack(alignment: .leading){
                    ForEach(entry.items[DiningHallMenuEntry.index].items) { item in
                        Text("-" + item.name)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }

                }
            }.textScale(Text.Scale.secondary)
        }
        .frame(
            minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: Alignment.center
            
        )//.background(.red)
        .containerBackground(for: .widget) {}
    }
}

struct DiningHall: Widget {
    let kind: String = "DiningHall"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            DiningHallEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        #if os(iOS)
            .supportedFamilies([.systemMedium, .systemLarge])
        #else
            .supportedFamilies([])
        #endif
    }
}

struct DiningHall_Previews: PreviewProvider {
    static var previews: some View {
        DiningHallEntryView(entry: DiningHallMenuEntry(
            name: "DLG", meal: "Lunch", items: [
                menuResult(station: "Station1", items: [
                    menuItem(name: "menuItem1isreallyreallyreallylong"),
                    menuItem(name: "menuItem2"),
                    menuItem(name: "menuItem3"),
                    menuItem(name: "menuItem4"),
                    menuItem(name: "menuItem5"),
                    menuItem(name: "menuItem6"),
                    menuItem(name: "menuItem7"),
                    menuItem(name: "menuItem8"),
                ]),
                menuResult(station: "Station2", items: [
                    menuItem(name: "menuItem1"),
                    menuItem(name: "menuItem2"),
                    menuItem(name: "menuItem3")
                ]),
                menuResult(station: "Station3", items: [
                    menuItem(name: "menuItem1"),
                    menuItem(name: "menuItem2"),
                    menuItem(name: "menuItem3")
                ]),
            ])).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
