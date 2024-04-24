//
//  BookComponent.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI

struct BookComponent: View {
    var bookData: Books?
    @State var showAnimation: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    var index: Int
    var body: some View {
            VStack(alignment: .center) {
                HStack(spacing: 18) {
                    AsyncImage(url: URL(string:"https://covers.openlibrary.org/b/id/\(bookData?.coverImage ?? 0)-S.jpg")){ image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 65, height:65)
                            .cornerRadius(8)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 70, height:70)
                    }
                    VStack(alignment: .leading) {
                        Text(bookData?.title ?? "")
                            .lineLimit(1)
                            .foregroundColor(.black)
                        HStack {
                            Text(bookData?.authorName.first ?? "")
                                .lineLimit(1)
                                .font(.system(size:14,weight: .light))
                                .foregroundColor(colorScheme == .dark ? .black :.gray)
                            Spacer()
                            HStack{
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(bookData?.ratingsAverage ?? 0,specifier:"%.1f")")
                                    .font(.system(size:15,weight: .light))
                            }
                            HStack{
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .foregroundColor(.yellow)
                                Text("\(bookData?.ratingsCount ?? 0)")
                                    .font(.system(size:15,weight: .light))
                            }
                            .fixedSize()
                            .padding(.trailing, 6)
                        }
                    }
                }
                .padding(.all, 10)
                .opacity(showAnimation ? 1 : 0)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.3).delay(Double(index) * 0.05)) {
                        showAnimation = true
                    }
                }
            }
    }
}
