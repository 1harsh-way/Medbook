//
//  ContentView.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSignupView = false
    var body: some View {
        NavigationStack{
            if let _ = APIManager().getSession() {
                LibraryScreen()
            }else{
                LaunchScreen()
            }
        }.onAppear {
            if let _ = APIManager().getSession() {
                LibraryScreen()
            }
        }
    }
}
