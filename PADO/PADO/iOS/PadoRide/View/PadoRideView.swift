//
//  PadoRideView.swift
//  PADO
//
//  Created by 황성진 on 2/7/24.
//

import SwiftUI

struct PadoRideView: View {
    // MARK: - PROPERTY
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var followVM: FollowViewModel
    @ObservedObject var padorideVM: PadoRideViewModel
    
    // MARK: - BODY
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        
                        Text("파도타기")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.leading, 40)
                        
                        Spacer()
                        
                        if padorideVM.selectedImage.isEmpty {
                            Button {
                            } label: {
                                Text("다음")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.trailing, 18)
                            }
                        } else {
                            Button {
                                padorideVM.downloadSelectedImage()
                                padorideVM.isShowingEditView = true
                            } label: {
                                Text("다음")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.trailing, 18)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if !padorideVM.postsData.isEmpty {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack {
                                ForEach(followVM.surfingIDs, id: \.self) { surfingID in
                                    SufferInfoCell(surfingID: surfingID)
                                    
                                    if padorideVM.postsData[surfingID] != [] {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack {
                                                SufferPostCell(padorideVM: padorideVM,
                                                               suffingPost: padorideVM.postsData[surfingID],
                                                               surfingID: surfingID)
                                            }
                                        }
                                    } else {
                                        HStack {
                                            NoItemView(itemName: "파도타기 할 수 있는 유저가 없습니다")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if followVM.followingIDs.isEmpty {
                            Spacer()
                            
                            Text("팔로잉한 사람이 없습니다")
                                .font(.system(size: 16, weight: .bold))
                            
                            FeedGuideView(feedVM: feedVM)
                            
                            Spacer()
                        } else if followVM.surfingIDs.isEmpty {
                            Spacer()
                            
                            SurfingGuideView()
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $padorideVM.isShowingEditView) {
                PadoRideEditView(padorideVM: padorideVM)
            }
        }
        .onAppear {
            Task {
                await padorideVM.preloadPostsData(for: followVM.surfingIDs)
            }
        }
    }
}
