//
//  BrowseTab.swift
//  historic city tours
//
//  Created by Tim Bachmann on 06.05.2024.
//

import SwiftUI
import OpenAPIClient

struct BrowseTab: View {
    @Binding var selectedTab: ContentView.Tab
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    @State private var searchText = ""
    
    @State private var TagColors: Array<Color> = [
        Color.tag1,
        Color.tag2,
        Color.tag3,
        Color.tag4,
        Color.tag5,
    ]
    
    var body: some View {
        ZStack {
            if $multimediaObjectData.tours.isEmpty {
                Image("dreamer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .allowsHitTesting(false)
            }
                
            List {
                ForEach(searchResults.filter{ result in result.generated == false }) { tour in
                    NavigationLink(destination: {
                        TourDetailView(selectedTab: $selectedTab, tour: tour)
                    }, label: {
                        VStack(alignment: .leading, spacing: 6.0) {
                            Text(tour.title.wrappedValue ?? "Tour")
                            HStack {
                                ForEach(tour.tags.wrappedValue ?? [], id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 4.0)
                                        .padding(.vertical, 2.0)
                                        .font(.system(size: 12))
                                        .background(TagColors[Int.random(in: 0..<TagColors.count)])
                                        .cornerRadius(3.0, corners: .allCorners)
                                }
                                Spacer()
                            }
                        }
                        
                    })
                }
                
                Section(header: Text("Generated Tours")) {
                    ForEach(searchResults.filter{ result in result.generated == true }) { tour in
                        NavigationLink(destination: {
                            TourDetailView(selectedTab: $selectedTab, tour: tour)
                        }, label: {
                            VStack(alignment: .leading, spacing: 6.0) {
                                Text(tour.title.wrappedValue ?? "Tour")
                                HStack {
                                    ForEach(tour.tags.wrappedValue ?? [], id: \.self) { tag in
                                        Text(tag)
                                            .padding(.horizontal, 4.0)
                                            .padding(.vertical, 2.0)
                                            .font(.system(size: 12))
                                            .background(TagColors[Int.random(in: 0..<TagColors.count)])
                                            .cornerRadius(3.0, corners: .allCorners)
                                    }
                                    Spacer()
                                }
                            }
                            
                        })
                    }
                }.headerProminence(.increased)
            }
            .scrollContentBackground(.hidden)
            .background(Color.sand)
            .refreshable {
                multimediaObjectData.refreshTours()
                multimediaObjectData.refreshMultimediaObjects()
            }
            .searchable(text: $searchText)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundColor(Color.accentColor)
                })
            }
        }
        .background {
            Color.sand
                .ignoresSafeArea()
        }
        .toolbarBackground(Color.sand, for: .navigationBar)
    }
    
    var searchResults: Binding<[TourResponse]> {
            if searchText.isEmpty {
                return $multimediaObjectData.tours
            } else {
                return $multimediaObjectData.tours.filter {
                    $0.title?.contains(searchText) ?? false ||
                    $0.source?.contains(searchText) ?? false ||
                    $0.author?.contains(searchText) ?? false
                }
            }
        }
}

extension Binding where Value: MutableCollection, Value: RangeReplaceableCollection, Value.Element: Identifiable {
  func filter(_ isIncluded: @escaping (Value.Element)->Bool) -> Binding<[Value.Element]> {
    return Binding<[Value.Element]>(
      get: {
        self.wrappedValue.filter(isIncluded)
      },
      set: { newValue in
        newValue.forEach { newItem in
          guard let i = self.wrappedValue.firstIndex(where: { $0.id == newItem.id }) else {
            self.wrappedValue.append(newItem)
            return
          }
          self.wrappedValue[i] = newItem
        }
      }
    )
  }
}
