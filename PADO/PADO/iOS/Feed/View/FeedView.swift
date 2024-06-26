//
//  ReFeedView.swift
//  PADO
//
//  Created by 강치우 on 2/6/24.
//

import Lottie
import SwiftUI

protocol FeedDelegate {
    func feedRefresh() async
    func openPostit()
}

struct FeedView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    @StateObject var scrollDelegate: ScrollViewModel = .init()
    
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var notiVM: NotificationViewModel
    
    var delegate: FeedDelegate

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    CustomRefreshView(showsIndicator: false,
                                      lottieFileName: LottieType.wave.rawValue,
                                      scrollDelegate: scrollDelegate) {
                        if viewModel.selectedFilter == .following {
                            LazyVStack(spacing: 0) {
                                if feedVM.postFetchLoading {
                                    LottieView(animation: .named(LottieType.loading.rawValue))
                                        .looping()
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .containerRelativeFrame([.horizontal,.vertical])
                                } else if feedVM.followFetchLoading {
                                    EmptyView()
                                } else if feedVM.followingPosts.isEmpty {
                                    FeedGuideView(title: "인기 팔로워",
                                                  content: "계정을 팔로우하여 최신 게시물을\n여기서 확인하세요.",
                                                  popularUsers: feedVM.popularUsers)
                                        .containerRelativeFrame([.horizontal,.vertical])
                                } else {
                                    ForEach(feedVM.followingPosts.indices, id: \.self) { index in
                                        FeedCell(post: $feedVM.followingPosts[index])
                                        .id(index)
                                        .task {
                                            if index == feedVM.followingPosts.indices.last {
                                                await feedVM.fetchFollowMorePosts()
                                            }
                                        }
                                    }
                                    .scrollTargetLayout()
                                }
                            }
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(feedVM.todayPadoPosts.indices, id: \.self) { index in
                                    FeedCell(post: $feedVM.todayPadoPosts[index])
                                }
                            }
                        }
                    } onRefresh: {
                        await delegate.feedRefresh()
                    }
                    .onChange(of: viewModel.scrollToTop) {
                        withAnimation {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                    .onChange(of: viewModel.selectedFilter) {
                        withAnimation {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                }
                VStack {
                    if scrollDelegate.scrollOffset < 5 {
                        FeedHeaderCell(notiVM: notiVM,
                                       openPostit: { delegate.openPostit() })
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
