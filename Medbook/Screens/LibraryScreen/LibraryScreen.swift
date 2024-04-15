//
//  LibraryScreen.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import SwiftUI
import SwiftData

enum sortOptions:String,CaseIterable{
    case title = "Title"
    case average = "Average"
    case hits = "Hits"
}

struct LibraryScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State var books:[Books] = []
    @State var searchText:String = ""
    @State var goToBookMark:Bool =  false
    @State var goToLanding:Bool = false
    
    @State var showToast:Bool = false
    @State var message:String = ""
    @State var sortBy:sortOptions = .title
    
    @State var currentPage = 1
    @State var limit = 10
    @State var showLoading = false
    
    var body: some View {
        GeometryReader { screen in
            VStack (alignment: .leading){
                Text("Which topic interests \nyou today?")
                    .multilineTextAlignment(.leading)
                    .font(.system(.title,weight: .semibold))
                    .padding()
                
                SearchBar(searchText: $searchText,searchAction: {search()})
                    .padding()
                Spacer()
                if !books.isEmpty {
                    VStack {
                        HStack{
                            Text("Sort By:")
                            Picker("", selection: $sortBy){
                                ForEach(sortOptions.allCases,id: \.self){ option in
                                    Text(option.rawValue)
                                }
                            }.pickerStyle(.segmented)
                                .onChange(of: sortBy){ newValue in
                                    addFilter(type: newValue)
                                }
                        }.padding(.horizontal)
                        List {
                            ForEach(books, id: \.authorName) { book in
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
                                                addToBookMark(book, model: modelContext)
                                            }label: {
                                                Image(systemName: "bookmark.fill")
                                            }
                                        }.tint(.clear)
                                    }
                                    .onAppear {
                                        fetchMoreDataIfNeeded(currentItemIndex: books.firstIndex(where: { $0.id == book.id }) ?? 0)
                                    }
                            }
                        }
                    }
                    
                }
                else{
                    if showLoading {
                        VStack{
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .foregroundColor(.blue)
                        }.frame(minWidth: screen.size.width)
                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: CustomButtonView(goToBookMark: $goToBookMark,logOutAction: {logout()}))
            .navigationBarItems(leading: LogoAndTitleView())
            .navigationDestination(isPresented: $goToBookMark){BookmarkScreen()}
            .navigationDestination(isPresented: $goToLanding){LaunchScreen()}
            
        }
    }
    func search(){
        if searchText.count >= 3{
            self.currentPage = 1
            books.removeAll()
            fetchData()
        }
    }
    
    func logout(){
        UserDefaults.standard.removeObject(forKey: "userInfo")
        UserDefaults.standard.removeObject(forKey: "defaultCountry")
        goToLanding.toggle()
    }
    
    func fetchData(){
        showLoading = true
        let offset = (currentPage - 1) * limit
        guard let url = URL(string: "https://openlibrary.org/search.json?title=\(searchText.lowercased())&limit=\(limit)&offset=\(offset)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let books = try JSONDecoder().decode(BookApiResponse.self, from: data)
                    self.books = books.docs
                    showLoading = false
                } catch {
                }
            }
        }.resume()
    }
    
    func fetchMoreDataIfNeeded(currentItemIndex: Int) {
        if currentItemIndex == books.count - 1 {
            currentPage += 1
            fetchData()
        }
    }
    
    func addFilter(type:sortOptions){
        DispatchQueue.main.async{ [self] in
            books.sort(by: {
                switch type {
                case .title:
                    return $0.title < $1.title
                case .average:
                    return $0.ratingsAverage > $1.ratingsAverage
                case .hits:
                    return $0.ratingsCount > $1.ratingsCount
                }
            })
        }
    }
    func addToBookMark(_ thebook:Books, model: ModelContext){
        
        let x = Books(title: thebook.title, ratingsAverage: thebook.ratingsAverage, ratingsCount: Int(Int16(thebook.ratingsCount )), authorName: [thebook.authorName.joined(separator: ",")], coverImage: Int(Int32(thebook.coverImage )))
        model.insert(x)
    }
}

struct LogoAndTitleView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            Image(systemName: "book.fill")
                .resizable()
                .foregroundColor(colorScheme == .dark ? .gray : .black)
                .frame(width: 30, height: 30)
            Text("MedBook")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading,3)
        }
    }
}

struct CustomButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    @Binding var goToBookMark:Bool
    var logOutAction:(()->Void)
    var body: some View {
        HStack{
            Button(action: {
                goToBookMark.toggle()
            }) {
                Image(systemName: "bookmark.fill")
                    .imageScale(.large)
                    .foregroundColor(colorScheme == .dark ? .gray : .black)
            }
            Button(action: {
                logOutAction()
            }) {
                Image(systemName: "delete.backward")
                    .imageScale(.large)
                    .tint(.pink)
            }
        }
    }
}

