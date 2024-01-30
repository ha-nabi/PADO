//
//  SelectCell.swift
//  PADO
//
//  Created by 강치우 on 1/20/24.
//

import Lottie
import SwiftUI

struct HeartCommentCell: View {
    @State var heartOnOff: Bool = false
    
    @Binding var isShowingReportView: Bool
    @Binding var isShowingCommentView: Bool
    
    @ObservedObject var feedVM: FeedViewModel
    @ObservedObject var commentVM: CommentViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Button {
                    heartOnOff.toggle()
                } label: {
                    if heartOnOff {
                        VStack {
                            Image("heart_fill")
                        }
                    } else {
                        Image("heart")
                    }
                }
                // 하트 눌렀을 때 +1 카운팅 되게 하는 로직 추가
                Text("\(feedVM.selectedFeedHearts)")
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .shadow(radius: 1, y: 1)
            }
            
            VStack {
                Button {
                    isShowingCommentView.toggle()
                } label: {
                    Image("chat")
                }
                .sheet(isPresented: $isShowingCommentView) {
                    CommentView(commentVM: commentVM, feedVM: feedVM)
                        .presentationDetents([.fraction(0.99), .fraction(0.8)])
                        .presentationDragIndicator(.visible)
                }
                // 댓글이 달릴 때 마다 +1 카운팅 되게 하는 로직 추가
                Text(String(commentVM.comments.count))
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
                            .fontWeight(.medium)
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

