//
//  ContentView.swift
//  CachingAPIResponseSwiftData
//
//  Created by Tunde Adegoroye on 24/07/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("lastFetched") private var lastFetched: Double = Date.now.timeIntervalSince1970
    
    @Query(sort: \Photo.id) private var photos: [Photo]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(photos, id: \.id) { item in
                    VStack(alignment: .leading) {
                        AsyncImage(url: item.url) { image in
                            image
                                .resizable()
                                
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        
                            
                        Text(item.title)
                            .font(.caption)
                            .bold()
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    .padding(.bottom)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10,
                                                style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                    
                   
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Posts")
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .task {
                do {
                    if hasExceedLimit() || photos.isEmpty {
                        print("Fetching data")
                        try await fetchPhotos()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Photo.self])
}

@Model
class Photo: Codable {
    @Attribute(.unique)
    var id: Int?
    
    var albumId: Int
    var title: String
    var url: URL
    var thumbnailUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case albumId
        case title
        case url
        case thumbnailUrl
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int?.self, forKey: .id)
        self.albumId = try container.decode(Int.self, forKey: .albumId)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(URL.self, forKey: .url)
        self.thumbnailUrl = try container.decode(URL.self, forKey: .thumbnailUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        // TODO: Implement
    }
}

extension ContentView {
    func fetchPhotos() async throws {
        let url = URL(string: "https://jsonplaceholder.typicode.com/photos")!
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let photos = try! JSONDecoder().decode([Photo].self, from: data)
        
        photos.forEach {
            modelContext.insert($0)
        }
        
        lastFetched = Date.now.timeIntervalSince1970
    }
    
    func hasExceedLimit() -> Bool {
        let timeLimit = 1
        let currentTime = Date.now
        let lastFetchedTime = Date(timeIntervalSince1970: lastFetched)
        
        guard let differenceInMins = Calendar.current.dateComponents([.second], from: lastFetchedTime, to: currentTime).second else {
            return false
        }
        
        return differenceInMins > timeLimit
    }
}
