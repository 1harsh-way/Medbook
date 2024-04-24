//
//  LaunchScreen.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI

struct LaunchScreen: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(spacing: 200) {
            VStack(alignment: .leading) {
                Text("MedBook")
                    .font(.title)
                    .fontWeight(.bold)
                Image(colorScheme == .dark ? "dark_home" : "home")
                    .resizable()
                    .scaledToFit()
            }
            HStack {
                NavigationLink(
                    destination: UserAuthScreen(isSignupScreen: .constant(true)),
                    label: {
                        Text("Signup")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.headline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 42)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                            )
                    })
                
                NavigationLink(
                    destination: UserAuthScreen(isSignupScreen: .constant(false)),
                    label: {
                        Text("Login")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.headline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 42)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme == .dark ? .white : .black, lineWidth: 2)
                            )
                    })
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(.black)
            .navigationBarBackButtonHidden()
            .onAppear() {
                UserDefaults.standard.removeObject(forKey: "userInfo")
                UserDefaults.standard.removeObject(forKey: "defaultCountry")
            }
    }
}

