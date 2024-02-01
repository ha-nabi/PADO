//
//  ContentView.swift
//  PADO
//
//  Created by 최동호 on 1/2/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var width = UIScreen.main.bounds.width
    @State var menu = "feed"
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @StateObject var surfingVM = SurfingViewModel()
    @StateObject var feedVM = FeedViewModel()
    @StateObject var followVM = FollowViewModel()
    @StateObject var searchVM = SearchViewModel()
    @StateObject var profileVM = ProfileViewModel()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                TabView(selection: $viewModel.showTab) {
                    FeedView(feedVM: feedVM,
                             surfingVM: surfingVM,
                             profileVM: profileVM)
                        .tabItem {
                            Image(viewModel.showTab == 0 ? "home_light" : "home_gray")
                                
                            Text("홈")
                        }
                        .onAppear { viewModel.showTab = 0 }
                        .tag(0)
                    
                    MainSearchView(searchVM: searchVM,
                                   profileVM: profileVM,
                                   followVM: followVM)
                        .tabItem {
                            Image(viewModel.showTab == 1 ? "search_light" : "search_gray")
                            
                            Text("검색")
                        }
                        .onAppear { viewModel.showTab = 1 }
                        .tag(1)
                    SurfingView(surfingVM: surfingVM,
                                feedVM: feedVM,
                                profileVM: profileVM)
                        .tabItem {
                            Text("")
                            
                            Image(viewModel.showTab == 2 ? "tab_added" : "tab_add")
                        }
                        .onAppear { viewModel.showTab = 2 }
                        .tag(2)
                    TodayView()
                        .tabItem {
                            Image(viewModel.showTab == 3 ? "today_light" : "today_gray")
                            
                            Text("오늘 파도")
                        }
                        .onAppear { viewModel.showTab = 3 }
                        .tag(3)
                    ProfileView(profileVM: profileVM, followVM: followVM)
                        .tabItem {
                            Image(viewModel.showTab == 4 ? "profile_light" : "profile_gray")
                            
                            Text("프로필")
                        }
                        .onAppear { viewModel.showTab = 4 }
                        .tag(4)
                }
                .tint(.white)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            Task {
                followVM.profileFollowId = userNameID
                followVM.initializeFollowFetch()
                await profileVM.fetchPostID(id: userNameID)
            }
        }
    }
    // 터치 했을 때 진동 울리게 하는 haptics vibration 싱글톤
    class HapticManager {
        
        static let instance = HapticManager()
        
        // notification 함수
        func simpleSuccess() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        // impact 함수
        func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}

