//
//  SelectCell.swift
//  PADO
//
//  Created by 강치우 on 1/20/24.
//

import Lottie
import SwiftUI

struct HeartCommentCell: View {

    
    @Binding var isShowingReportView: Bool
    @Binding var isShowingCommentView: Bool
    
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var surfingVM: SurfingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
            VStack {
                if feedVM.selectedFeedCheckHeart {
                    Button {
                        Task {
                            await feedVM.deleteHeart()
                            feedVM.selectedFeedCheckHeart = await feedVM.checkHeartExists()
                        }
                    } label: {
                        Image("heart_fill")
                    }
                } else {
                    Button {
                        Task {
                            await feedVM.addHeart()
                            feedVM.selectedFeedCheckHeart = await feedVM.checkHeartExists()
                        }
                    } label: {
                        Image("heart")
                    }
                }
                
                // 하트 눌렀을 때 +1 카운팅 되게 하는 로직 추가
                Text("\(feedVM.selectedFeedHearts)")
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                    .shadow(radius: 1, y: 1)
            }
            
            VStack(spacing: 10) {
                Button {
                    isShowingCommentView.toggle()
                } label: {
                    Image("chat")
                }
                .sheet(isPresented: $isShowingCommentView) {
                    CommentView(feedVM: feedVM,
                                surfingVM: surfingVM)
                    .presentationDetents([.fraction(0.99), .fraction(0.8)])
                    .presentationDragIndicator(.visible)
                }
                // 댓글이 달릴 때 마다 +1 카운팅 되게 하는 로직 추가
                Text(String(feedVM.selectedCommentCounts))
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .shadow(radius: 1, y: 1)
            }
            
            VStack {
                Button {
                    isShowingReportView.toggle()
                } label: {
                    VStack {
                        Text("...")
                            .font(.system(size: 32))
                            .fontWeight(.regular)
                            .foregroundStyle(.white)
                        
                        Text("")
                    }
                }
                .sheet(isPresented: $isShowingReportView) {
                    ReportSelectView(isShowingReportView: $isShowingReportView)
                        .presentationDetents([.medium, .fraction(0.8)]) // 모달높이 조절
                        .presentationDragIndicator(.visible)
                }
            }
            .padding(.top, -15)
        }
    }
}

