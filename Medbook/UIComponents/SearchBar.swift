//
//  SearchBar.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI

struct SearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchText:String
    var startSearch = false
    var searchAction:(()->Void)
    var body: some View {
        HStack {
            Button{
                searchAction()
            }label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(colorScheme == .dark ? .gray : .black)
            }.padding(.leading)
                .padding(.vertical)
            TextField("Search", text: $searchText)
                .foregroundColor(colorScheme == .dark ? .gray : .black)
                .autocorrectionDisabled()
                .onChange(of: searchText){
                    searchAction()
                }
                .onSubmit {
                    searchAction()
                }
            
            Button{
                searchText = ""
            }label: {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }.padding(.leading)
                .padding(.vertical)
                .padding(.trailing)
            
        }
        .background(.gray.opacity(0.2))
        .buttonBorderShape(.capsule)
        .cornerRadius(10)
    }
}
