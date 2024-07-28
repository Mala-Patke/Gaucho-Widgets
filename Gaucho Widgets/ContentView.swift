//
//  ContentView.swift
//  Gaucho Widgets
//
//  Created by Ali Shahid on 7/27/24.
//

import SwiftUI

enum DiningHalls : String {
    case Carillo, Portola, DeLaGuerra
}


struct ContentView: View {
    @State private var selectedDiningHall : DiningHalls = .DeLaGuerra
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    Picker("Preferred Dining Hall", selection: $selectedDiningHall) {
                        Text("Carillo").tag(DiningHalls.Carillo)
                        Text("Portola").tag(DiningHalls.Portola)
                        Text("De La Guerra").tag(DiningHalls.DeLaGuerra)
                    }
                }
                Text("This is just a test app lmao, the real fun is in the widget")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
