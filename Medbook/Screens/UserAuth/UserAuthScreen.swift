//
//  UserAuthScreen.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI
import SwiftData

struct UserAuthScreen: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var model = UserAuthViewModel()
    @ObservedObject var apiManager = APIManager()
    @Query var user: [User]
    @Query var countrydata: [Country]
    @Binding var isSignupScreen: Bool
    @State var showsAlert: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Welcome")
                    .padding(.leading)
                    .font(.title)
                    .fontWeight(.bold)
                Text(isSignupScreen ? "Sign up to continue" : "Login to continue")
                    .padding(.leading)
                    .font(.title2)
                TextField("Email", text: $model.email)
                    .autocapitalization(.none)
                    .padding(.vertical, 10)
                    .keyboardType(.emailAddress)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke((model.isValidEmail || model.email.isEmpty) ? Color.gray : Color.pink, lineWidth: 1)
                            .frame(height: 1)
                            .padding(.top, 44)
                    )
                    .padding()
                    .onChange(of: model.email) {
                        if isSignupScreen{model.isValidEmailFormat(model.email)
                            model.validateUserSignupState()}
                    }
                SecureField("Password", text: $model.password)
                    .padding(.bottom, 10)
                    .overlay(Rectangle().frame(height: 2)
                        .foregroundColor(.gray), alignment: .bottom)
                    .padding()
                    .onChange(of: model.password) {
                        model.validateUserSignupState()
                    }
                
                if isSignupScreen{
                    VStack(alignment: .leading, spacing: 30) {
                        CheckBoxView(title: "At least 8 characters", isChecked: $model.isLengthValid)
                        CheckBoxView(title: "Contains an uppercase letter", isChecked: $model.isUppercaseValid)
                        CheckBoxView(title: "Contains a special character", isChecked: $model.isSpecialCharValid)
                    }
                    .padding()
                    Picker("Select a country", selection: $apiManager.defaultCountryIndex) {
                        ForEach(0..<countrydata.count, id: \.self) { index in
                            Text(countrydata[index].country).tag(index)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 140)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        if isSignupScreen {
                            let x = await apiManager.signUp(email: model.email, password: model.password, model: modelContext, user: user)
                                model.isShowingDetailView = true
                        }
                        else{
                            model.isUserReadyToSignUp = true
                            let x = await apiManager.login(email: model.email, password: model.password, model: modelContext, user: user)
                            switch x {
                            case SignUpResult.completed:
                                model.isShowingDetailView = true
                            case SignUpResult.failed:
                                showsAlert = true
                            }
                        }
                    }
                }) {
                    Text("Let's go")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 42)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme == .dark ? .white :.black, lineWidth: 2)
                        )
                }
                .disabled(!model.isUserReadyToSignUp)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $model.isShowingDetailView){LibraryScreen()}
        .onAppear {apiManager.fetchCountryData(model: modelContext, countrydata: countrydata)
            apiManager.fetchDefaultCountry(countryData: countrydata)
        }
        .alert(isPresented: self.$showsAlert) {
            Alert(title: Text("email or password incorrect"))
        }
    }
}

struct CheckBoxView: View {
    var title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .resizable()
                .font(Font.title.weight(.bold))
                .frame(width: 20, height: 20)
            Text(title)
                .font(.system(size: 18))
        }
    }
}
