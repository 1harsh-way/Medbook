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
    @Query var savedbooks: [Books]
    @State var searchText:String = ""
    @State var goToBookMark:Bool =  false
    @State var goToLanding:Bool = false
    @State var sortBy:sortOptions = .title
    @State var currentPage = 1
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
                    HStack{
                        Text("Sort By:")
                        Picker("", selection: $sortBy){
                            ForEach(sortOptions.allCases,id: \.self){ option in
                                Text(option.rawValue)
                            }
                        }.pickerStyle(.segmented)
                            .onChange(of: sortBy){ newValue in
                                getSortedData(type: newValue)
                            }
                    }.padding(.horizontal)
                    VStack(spacing: 12) {
                        List {
                            ForEach(
                                Array(getSortedData(type: sortBy).enumerated()),
                                id: \.0
                            ) { i, element in
                                BookComponent(
                                    bookData: element,
                                    index: 10
                                )
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(colorScheme == .dark ? .gray : .white)
                                        .padding(10)
                                )
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing){
                                    ZStack{
                                        Button {
                                            addToBookMark(book: element, model: modelContext)
                                        }label: {
                                            Image(systemName: "bookmark.fill")
                                                .tint(.pink)
                                        }
                                    }.tint(.clear)
                                }
                                .onAppear {
                                    paginateBooks(index: i)
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
            
        }
        .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: CustomButtonView(goToBookMark: $goToBookMark))
            .navigationBarItems(leading: LogoAndTitleView())
            .navigationDestination(isPresented: $goToBookMark){BookmarkScreen(bookData: savedbooks)}
            .navigationDestination(isPresented: $goToLanding){LaunchScreen()}
    }
    func search(){
        if searchText.count > 2{
            self.currentPage = 1
            books.removeAll()
            self.getBooks()
        }
    }
    
    func paginateBooks(index: Int) {
        guard index + 1 == books.count else { return }
        getBooks(isPagination: true)
    }
    
    func getBooks(isPagination: Bool = false) {
        guard searchText.count > 3 else {
            self.books = searchText.isEmpty ? [] : self.books
            return
        }
        let params: [String : Any] = [
            "title" : searchText,
            "limit" : 10,
            "offset" : isPagination ? books.count : 0
        ]
        fetchData(params: params) { booksModel in
            if isPagination {
                self.books.append(contentsOf: booksModel?.docs ?? [])
            } else {
                
                self.books = booksModel?.docs ?? []
            }
        }
    }
    
    func fetchData(params: [String: Any], completion: @escaping ((_ booksModel: BookApiResponse?) -> ())) {
        showLoading = true
        guard searchText.count >= 3 else {
            books = []
            return
        }
        
        var queryItems = [URLQueryItem]()
        
        var urlBuilder = URLComponents(string:"https://openlibrary.org/search.json")
        for (key, value) in params{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            queryItems.append(queryItem)
        }
        urlBuilder?.queryItems = queryItems
        guard let url = urlBuilder?.url else {
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching books: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                return
            }
            do {
                let response = try JSONDecoder().decode(BookApiResponse.self, from: data)
                DispatchQueue.main.async {
                    self.books.append(contentsOf: response.docs)
                    showLoading = false
                }
            } catch {
                print("Error decoding books: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func addFilter(type: sortOptions) {
        DispatchQueue.main.async { [self] in
            books.sort { (book1, book2) in
                switch type {
                case .title:
                    return book1.title < book2.title
                case .average:
                    return book1.ratingsAverage > book2.ratingsAverage
                case .hits:
                    return book1.ratingsCount > book2.ratingsCount
                }
            }
        }
    }
    
    func getSortedData(type: sortOptions) -> [Books] {
        withAnimation {
            switch type {
            case .title:
                self.books.sorted(by: {($0.title) < ($1.title)})
            case .average:
                self.books.sorted(by: {($0.ratingsAverage) > ($1.ratingsAverage)})
            case .hits:
                self.books.sorted(by: {$0.ratingsCount > $1.ratingsCount})
            }
        }
    }
    func addToBookMark(book:Books, model: ModelContext){
        if let existingBooks = savedbooks.first(where: { $0.title == book.title}){
            modelContext.delete(existingBooks)
        }
        else {
            let x = Books(title: book.title, ratingsAverage: book.ratingsAverage, ratingsCount: Int(Int16(book.ratingsCount )), authorName: [book.authorName.joined(separator: ",")], coverImage: Int(Int32(book.coverImage )))
            model.insert(x)
        }
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
    @Environment(\.dismiss) var dismiss
    @Binding var goToBookMark:Bool
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
                dismiss()
            }) {
                Image(systemName: "delete.backward")
                    .imageScale(.large)
                    .tint(.pink)
            }
        }
    }
}

