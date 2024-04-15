//
//  APIManager.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI
import SwiftData

@frozen public enum SignUpResult {
    case completed
    case failed
}

class APIManager: ObservableObject {
    @Published var defaultCountryIndex: Int = 0
    @Published var countries: [Country] = []
    
    func setSession(email: String) {
        UserDefaults.standard.set(email, forKey: "userInfo")
    }
    func getSession() -> String? {
        return UserDefaults.standard.string(forKey: "userInfo")
    }
    
    
    func signUp(email: String, password: String, model: ModelContext, user: [User]){
        if !user.isEmpty {
            for users in user {
                if (users.email == email && users.password == password){
                    setSession(email: email)
                }
                else{
                    let data = User(email: email, password: password)
                    model.insert(data)
                    setSession(email: email)
                }
            }
        }

    }
    
    func login(email: String, password: String, model: ModelContext, user: [User]) async -> SignUpResult{
        if !user.isEmpty {
            for users in user {
                if (users.email == email && users.password == password){
                    setSession(email: email)
                    return SignUpResult.completed
                }
            }
        }
        return SignUpResult.failed
    }
    
    func fetchCountryData(model: ModelContext, countrydata: [Country]) {
        if !countrydata.isEmpty {
        } else {
            guard let url = URL(string: "https://api.first.org/data/v1/countries") else {
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let countriesData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let data = countriesData["data"] as? [String: [String: String]] {
                        DispatchQueue.main.async {
                            self.countries = data.map { Country(country: $0.value["country"] ?? "", code: $0.key) }
                                .sorted(by: { $0.country < $1.country })
                            for country in self.countries {
                                let itemToStore = Country(country: country.country, code: country.code)
                                model.insert(itemToStore)
                            }
                        }
                    }
                }
            }.resume()
        }
    }
    
    func fetchDefaultCountry(countryData: [Country]) {
        if UserDefaults.standard.string(forKey: "defaultCountry") == nil {
            guard let url = URL(string: "http://ip-api.com/json") else {
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                        DispatchQueue.main.async {
                            if json?["countryCode"] is String {
                                for (index, country) in countryData.enumerated() {
                                    if country.code == "IN" {
                                        self.defaultCountryIndex = index
                                        UserDefaults.standard.set(index, forKey: "defaultCountry")
                                        break
                                    }
                                }
                                
                            }
                        }
                    } catch {
                    }
                }
            }.resume()
        }
        else {
            defaultCountryIndex = Int(UserDefaults.standard.string(forKey: "defaultCountry") ?? "") ?? 0
        }
    }
}




