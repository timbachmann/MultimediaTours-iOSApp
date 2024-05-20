//
//  ContentView.swift
//  historic city tours
//
//  Created by Tim Bachmann on 03.03.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .browse
    @State private var showingGeneratePanel = false
    @State private var generateQuery = ""
    
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
                        MapTab(selectedTab: $selectedTab)
                    }
                        .tabItem {
                            Label("AR", systemImage: "arkit")
                        }
                        .tag(Tab.ar)
                    NavigationStack() {
                        MapTab(selectedTab: $selectedTab)
                    }
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(Tab.settings)
                }
                .toolbarBackground(Color.forest, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)
            }
            Button {
                $showingGeneratePanel.wrappedValue.toggle()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 58, height: 58)
                    .tint(Color.white)
            }
            .frame(width: 58, height: 58)
            .background(Color.fireOrange)
            .clipShape(Circle())
            .shadow(radius: 2)
            .sheet(isPresented: $showingGeneratePanel) {
                ZStack {
                    Color.sand.edgesIgnoringSafeArea(.all)
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

extension UITabBarController {
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 0
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
