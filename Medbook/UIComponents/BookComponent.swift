//
//  BookComponent.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI
struct BookComponent: View {
    var book:Books?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .center){
            if let coverImage = book?.coverImage,let url = URL(string:"https://covers.openlibrary.org/b/id/\(coverImage)-S.jpg"){
                ImageCache(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height:70)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                        .frame(width: 70, height:70)
                }
            }else{
                Image(systemName: "globe")
            }
            VStack(alignment: .leading){
                Text(String(book?.title ?? ""))
                    .padding(.bottom,3)
                
                HStack{
                    Text(String(book?.authorName.first ?? ""))
                        .lineLimit(1)
                        .font(.system(size:14,weight: .light))
                        .foregroundColor(.gray)
                    
                    HStack{
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("\(book?.ratingsAverage ?? 0,specifier:"%.2f")")
                            .font(.system(size:15,weight: .light))
                    }
                    HStack{
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.yellow)
                        Text("\(book?.ratingsCount ?? 0)")
                            .font(.system(size:15,weight: .light))
                    }
                }
            }
            
        }.frame(minHeight: 80 ,alignment: .leading)
    }
}
