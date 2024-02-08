//
//  ReFeedView.swift
//  PADO
//
//  Created by 강치우 on 2/6/24.
//

import SwiftUI

struct ReFeedView: View {
    @State private var isLoading = true
    @Binding var selectedFilter: FeedFilter
    
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var surfingVM: SurfingViewModel
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var followVM: FollowViewModel
    @StateObject var scrollDelegate: ScrollViewModel = .init()
    
    let updateHeartData = UpdateHeartData()
    
    var body: some View {
        NavigationStack {
            ZStack {
            CustomRefreshView(showsIndicator: false,
                              lottieFileName: "Loading",
                              scrollDelegate: scrollDelegate) {
                    if selectedFilter == .following {
                        LazyVStack(spacing:0) {
                            ForEach(feedVM.followingPosts.indices, id: \.self) { index in
                                FeedCell(feedVM: feedVM,
                                         surfingVM: surfingVM,
                                         profileVM: profileVM,
                                         updateHeartData: updateHeartData,
                                         post: feedVM.followingPosts[index])
                                .id(index)
                                .onAppear {
                                    if index == feedVM.followingPosts.count - 1{
                                        Task {
                                            await feedVM.fetchFollowMorePosts()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        LazyVStack(spacing:0) {
                            ForEach(feedVM.todayPadoPosts.indices, id: \.self) { index in
                                FeedCell(feedVM: feedVM,
                                         surfingVM: surfingVM,
                                         profileVM: profileVM,
                                         updateHeartData: updateHeartData,
                                         post: feedVM.todayPadoPosts[index])
                                .id(index)
 
                            }
                        }
                        .onAppear {
                            Task {
                                await feedVM.fetchTodayPadoPosts()
                            }
                        }
                    }
            } onRefresh: {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if selectedFilter == FeedFilter.following {
                    feedVM.findFollowingUsers()
                } else {
                    Task{
                        await feedVM.fetchTodayPadoPosts()
                    }
                }
            }
                VStack {
                    if scrollDelegate.scrollOffset < 5 {
                        FeedHeaderCell(selectedFilter: $selectedFilter)
                            .transition(.opacity.combined(with: .scale))
                    } else if !scrollDelegate.isEligible {
                        FeedRefreshHeaderCell()
                            .transition(.opacity.combined(with: .scale))
                    }
                    Spacer()
                }
                .padding(.top, 10)
                .animation(.easeInOut, value: scrollDelegate.scrollOffset)
                
            }
        }
    }
}
