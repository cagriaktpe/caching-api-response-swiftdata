//
//  ContentView.swift
//  CachingAPIResponseSwiftData
//
//  Created by Tunde Adegoroye on 24/07/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var photos: [Photo] = []
    
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
                    try await fetchPhotos()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

struct Photo: Codable {
    let albumId: Int
    let id: Int
    let title: String
    let url: URL
    let thumbnailUrl: URL
}

extension ContentView {
    func fetchPhotos() async throws {
        let url = URL(string: "https://jsonplaceholder.typicode.com/photos")!
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let photos = try! JSONDecoder().decode([Photo].self, from: data)
        
        self.photos = photos
    }
}
