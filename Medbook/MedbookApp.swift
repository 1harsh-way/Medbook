//
//  MedbookApp.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI

@main
struct MedbookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: [User.self,Country.self,Books.self])
    }
}
