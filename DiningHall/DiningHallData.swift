//
//  DiningHallData.swift
//  Gaucho Widgets
//
//  Created by Ali Shahid on 8/23/24.
//

import Foundation
import WidgetKit

struct queryResult : Decodable {
    let name: String
    let code: String
}

// I think what this means is the entire app will shit itself if DLG has 2 of the same menu items lmao
struct rawMenuResult : Decodable {
    let name: String
    let station: String
}

struct menuItem : Identifiable, Codable, Hashable {
    let name : String
    var id : String {name}
}

struct menuResult : Decodable, Identifiable {
    let station : String
    var items : [menuItem]
    
    var id : String { station }
}

struct DiningHallMenuEntry : TimelineEntry {
    let date : Date = Date()

    static var index = 0
    
    let name: String
    let meal: String
    let items: [menuResult]
}

func authenticate(_ url: String) -> String {
    return url + "?ucsb-api-key=\(ProcessInfo.processInfo.environment["ucsb_api_key"] ?? "")"
}

func getBaseURL() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let today = formatter.string(from: Date())
    
    return "https://api.ucsb.edu/dining/menu/v1/\(today)"
}

func request<T: Decodable>(_ url: String = "") async throws -> [T] {
    let url = getBaseURL() + url + "?ucsb-api-key=ggIRhyX4PtIErTud08HRsKLSYqSOjrlF"
    let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
    return try JSONDecoder().decode([T].self, from: data)
}

func getOpenDiningHalls() async throws -> [queryResult] {
    return try await request()
}

func mealsAt(_ hall: String) async throws -> [queryResult] {
    return try await request("/\(hall)")
}

func getMenu(_ hall: String, _ meal: String) async throws -> [menuResult] {
    let rawMenu : [rawMenuResult] = try await request("/\(hall)/\(meal)")
    var menuItems : [menuResult] = []
    
    for item in rawMenu {
        var stationItem = menuItems.first {rawItem in rawItem.station == item.station}
        
        if(stationItem == nil) {
            menuItems.append(menuResult(station: item.station, items: [menuItem(name: item.name)]))
        } else {
            stationItem?.items.append(menuItem(name: item.name))
            
            if let i = menuItems.firstIndex(where: {rawItem in rawItem.station == stationItem?.station}) {
                menuItems[i] = stationItem!
            }
        }
    }
    
    return menuItems
}

func getDiningHallData() async throws -> DiningHallMenuEntry  {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let today = formatter.string(from: Date())
    
    var url = "https://api.ucsb.edu/dining/menu/v1/\(today)"
    
    //Get list of dining halls open today. For the demo, we just care about the first
    let openHalls : [queryResult] = try await request()

    //Get today's meals. For the demo, we care about the second one
    //TODO: Modularize this lmao. Use a function to combine authenticate with urlsession. Use generic return type.
    url = url + "/\(openHalls[0].code)"
    let (openMealsData, _) = try await URLSession.shared.data(from: URL(string: authenticate(url))!)
    let openMeals = try JSONDecoder().decode([queryResult].self, from: openMealsData)
    
    //Get the meal items at said meal
    //TODO: Modularize this lmao
    url = url + "/\(openMeals[1].code)"
    let (menuData, _) = try await URLSession.shared.data(from: URL(string: authenticate(url))!)
    let menu = try JSONDecoder().decode([menuResult].self, from: menuData)
    
    
    return DiningHallMenuEntry(
        name: openHalls[0].name,
        meal: openMeals[1].name,
        items: menu
    )
}
