//
//  ContentView.swift
//  historic city tours
//
//  Created by Tim Bachmann on 03.03.2024.
//

import SwiftUI
import OpenAPIClient

struct ContentView: View {
    @State private var selectedTab: Tab = .browse
    @State private var showingGeneratePanel = false
    @State private var generateQuery = ""
    @State private var generatingTour = false
    @State private var showGeneratedTour = false
    @State private var generatedTour: TourResponse? = nil
    @EnvironmentObject var multimediaObjectData: MultimediaObjectData
    let pub = NotificationCenter.default.publisher(for: Notification.Name("ARExplorer"))
    
    public enum Tab {
        case map, browse, ar, empty, settings
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                Group {
                    NavigationStack() {
                        BrowseTab(selectedTab: $selectedTab)
                            .navigationTitle("Tours")
                        NavigationLink(isActive: $showGeneratedTour, destination: {
                            TourDetailView(selectedTab: $selectedTab, tour: $generatedTour.safeBinding(defaultValue: TourResponse()))
                        }, label: {
                            EmptyView()
                        })
                    }
                        .tabItem {
                            Label("Browse", systemImage: "globe")
                        }
                        .tag(Tab.browse)
                    NavigationStack() {
                        MapTab(selectedTab: $selectedTab)
                    }
                        .tabItem {
                            Label("Map", systemImage: "map")
                        }
                        .tag(Tab.map)
                    Spacer()
                        .tabItem {
                            EmptyView()
                        }
                        .tag(Tab.empty)
                    NavigationStack() {
                        ARTab(selectedTab: $selectedTab)
                    }
                        .tabItem {
                            Label("AR", systemImage: "arkit")
                        }
                        .tag(Tab.ar)
                    NavigationStack() {
                        SettingsTab()
                    }
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(Tab.settings)
                }
            }
            .onReceive(pub) { data in
                 if data.object is UNNotificationContent {
                     selectedTab = .ar
                 }
            }
            Button {
                $showingGeneratePanel.wrappedValue.toggle()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 52, height: 52)
                    .tint(Color.white)
            }
            .frame(width: 52, height: 52)
            .background(Color.fireOrange)
            .clipShape(Circle())
            .shadow(radius: 2)
            .sheet(isPresented: $showingGeneratePanel) {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    ZStack(alignment: .bottomTrailing) {
                        Text("powered by [vitrivr](https://vitrivr.org/)")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.top, 8)
                        VStack(alignment: .center, spacing: 12) {
                            TextField("What are you interested in?", text: $generateQuery)
                                .padding(7)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                                .padding(.horizontal, 16)
                            Button(action: {
                                if $generateQuery.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                    generateTour(query: $generateQuery.wrappedValue)
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                    Text("Generate Tour")
                                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                }
                            })
                            .frame(width: 200.0, height: 40.0, alignment: .center)
                            .background(Color.fireOrange)
                            .cornerRadius(8, corners: .allCorners)
                            .padding(.vertical, 8)
                            .disabled($generatingTour.wrappedValue)
                        }
                        .padding(.vertical, 12)
                    }
                    .padding()
                }
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == Tab.empty {
                self.selectedTab = oldValue
           }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MultimediaObjectData())
}

extension ContentView {
    func generateTour(query: String) {
        if $generatingTour.wrappedValue == false {
            $generatingTour.wrappedValue = true
            multimediaObjectData.generateTour(query: $generateQuery.wrappedValue) { (generatedTour, error) in
                $generatedTour.wrappedValue = generatedTour
                $selectedTab.wrappedValue = .browse
                $showGeneratedTour.wrappedValue = true
                $generatingTour.wrappedValue = false
                $showingGeneratePanel.wrappedValue = false
                $generateQuery.wrappedValue = ""
            }
        }
    }
}

extension UITabBarController {
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 0
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

extension Binding {
    func safeBinding<T>(defaultValue: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>.init {
            self.wrappedValue ?? defaultValue
        } set: { newValue in
            self.wrappedValue = newValue
        }
    }
}
