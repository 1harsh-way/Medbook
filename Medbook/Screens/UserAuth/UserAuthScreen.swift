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
    @State var alertText: String = ""

    @State private var isSecured: Bool = true
    
    var body: some View {
        Group {
            if (APIManager().getSession() != nil) {
                LibraryScreen()
            } else {
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
                        
                        ZStack(alignment: .trailing) {
                                        if isSecured {
                                            SecureField("Password", text: $model.password)
                                                .padding(.bottom, 10)
                                                .overlay(Rectangle().frame(height: 2)
                                                    .foregroundColor(.gray), alignment: .bottom)
                                                .padding()
                                                .onChange(of: model.password) {
                                                    model.validateUserSignupState()
                                                }
                                        } else {
                                            TextField("Password", text: $model.password)
                                                .padding(.bottom, 10)
                                                .overlay(Rectangle().frame(height: 2)
                                                    .foregroundColor(.gray), alignment: .bottom)
                                                .padding()
                                                .onChange(of: model.password) {
                                                    model.validateUserSignupState()
                                                }
                                        }
                                    Button(action: {
                                        isSecured.toggle()
                                    }) {
                                        Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                            .accentColor(.gray)
                                    }.padding(.trailing, 12)
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
                                let x = await apiManager.commonLogin(email: model.email, password: model.password, model: modelContext, user: user, signUp: isSignupScreen)
                                switch x {
                                case SignUpResult.completed:
                                    apiManager.setSession(email: model.email)
                                    model.isShowingDetailView = true
                                    
                                case SignUpResult.failed(let error):
                                    switch error{
                                    case .incorrectPassword:
                                        showsAlert = true
                                        alertText = "Password is incorrect"
                                    case .noData:
                                        showsAlert = true
                                        alertText = "User does not exists"
                                    case .userAlreadyExists:
                                        showsAlert = true
                                        alertText = "User already exists, Please log in"
                                    case .userDoesNotExist:
                                        showsAlert = true
                                        alertText = "User does not exists"
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
                }   .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(isPresented: $model.isShowingDetailView){LibraryScreen()}
                    .onAppear {apiManager.fetchCountryData(model: modelContext, countrydata: countrydata)
                        apiManager.fetchDefaultCountry(countryData: countrydata)
                    }
                    .alert(isPresented: self.$showsAlert) {
                        Alert(title: Text(alertText))
                        
                    }

                
            }
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
