//
//  BookmarkScreen.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI
import SwiftData

struct BookmarkScreen: View {
    @Query var bookdata: [Books]
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            ForEach(bookdata , id: \.title) { book in
                BookComponent(book: book)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(colorScheme == .dark ? .gray : .white)
                            .padding(10)
                    )
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing){
                        ZStack{
                            Button {
                                removeBook(title: book.title, books: bookdata, modelContext: modelContext)
                            }label: {
                                Image(systemName: "bookmark.fill")
                            }
                        }.tint(colorScheme == .dark ? .gray :.black)
                    }
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.large)
        .toolbar{
            ToolbarItem(placement:.navigationBarLeading){
                Button{
                    presentationMode.wrappedValue.dismiss()
                }label: {
                    Image(systemName: "chevron.left")
                        .tint(colorScheme == .dark ? .gray :.black)
                }
            }
        }
    }
    func removeBook(title: String, books: [Books],modelContext: ModelContext){
        for book in books {
            if (book.title == title){
                modelContext.delete(book)
            }
        }
    }
}
