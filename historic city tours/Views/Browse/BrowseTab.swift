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
                                .redacted(reason: $multimediaObjectData.isLoading.wrappedValue ? .placeholder : [])
                            HStack {
                                ForEach(tour.tags.wrappedValue ?? [], id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 4.0)
                                        .padding(.vertical, 2.0)
                                        .font(.system(size: 12))
                                        .background(Color.tag)
                                        .cornerRadius(3.0, corners: .allCorners)
                                        .redacted(reason: $multimediaObjectData.isLoading.wrappedValue ? .placeholder : [])
                                }
                                Spacer()
                            }
                        }
                        
                    })
                    .disabled($multimediaObjectData.isLoading.wrappedValue)
                }
                
                Section(header: Label("Generated Tours", systemImage: "wand.and.stars")) {
                    ForEach(searchResults.filter{ result in result.generated == true }) { tour in
                        NavigationLink(destination: {
                            TourDetailView(selectedTab: $selectedTab, tour: tour)
                        }, label: {
                            VStack(alignment: .leading, spacing: 6.0) {
                                Text(tour.title.wrappedValue ?? "Tour")
                                    .redacted(reason: $multimediaObjectData.isLoading.wrappedValue ? .placeholder : [])
                                HStack {
                                    ForEach(tour.tags.wrappedValue ?? [], id: \.self) { tag in
                                        Text(tag)
                                            .padding(.horizontal, 4.0)
                                            .padding(.vertical, 2.0)
                                            .font(.system(size: 12))
                                            .background(Color.tag)
                                            .cornerRadius(3.0, corners: .allCorners)
                                            .redacted(reason: $multimediaObjectData.isLoading.wrappedValue ? .placeholder : [])
                                    }
                                    Spacer()
                                }
                            }
                            
                        })
                        .disabled($multimediaObjectData.isLoading.wrappedValue)
                    }
                }.headerProminence(.increased)
            }
            .refreshable {
                multimediaObjectData.refreshTours()
                multimediaObjectData.refreshMultimediaObjects()
            }
            .searchable(text: $searchText)
        }
        .onAppear(perform: {
            requestNotificationAuthorization()
        })
        .onChange(of: $multimediaObjectData.activeTour.wrappedValue) { oldTour, newTour in
            multimediaObjectData.createNotifications(oldTour: oldTour, newTour: newTour)
        }
    }
    
    var searchResults: Binding<[TourResponse]> {
        if searchText.isEmpty {
            return $multimediaObjectData.tours
        } else {
            return $multimediaObjectData.tours.filter {
                $0.title?.contains(searchText) ?? false ||
                $0.source?.contains(searchText) ?? false ||
                $0.author?.contains(searchText) ?? false ||
                $0.tags?.contains(where: { $0.contains(searchText.lowercased()) }) ?? false
            }
        }
    }
}

extension BrowseTab {
    
    /**
     Requests authorization to send notifications
     */
    func requestNotificationAuthorization() {
        
        let nc = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        nc.requestAuthorization(options: options) { granted, _ in
            print("\(#function) Permission granted: \(granted)")
            guard granted else { return }
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
