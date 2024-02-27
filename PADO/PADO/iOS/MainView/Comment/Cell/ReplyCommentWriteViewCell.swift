//
//  ReplyCommentWriteViewCell.swift
//  PADO
//
//  Created by 최동호 on 2/27/24.
//


import Kingfisher
import Lottie
import SwiftUI

struct ReplyCommentWriteViewCell: View {
    let index: Int
    let replyCommentID: String
    
    @ObservedObject var commentVM: CommentViewModel
    
    @State private var isUserLoaded = false
    @State private var isShowingCommentWriteView: Bool = false
    @State private var isShowingLoginPage: Bool = false
    @State var buttonOnOff: Bool = false
    @State var isShowingReportView: Bool = false
    @State private var isShowingHeartUserView: Bool = false
    @State private var isHeartCheck: Bool = true
    @State var commentUser: User?
    
    @Binding var post: Post
    
    var body: some View {
        if index < commentVM.comments.count, let replyComment = commentVM.replyComments[replyCommentID] {
            HStack(alignment: .top) {
                Circle()
                    .foregroundStyle(.clear)
                    .frame(width: 38, height: 38)
                    .padding(.top, 6)
                Group {
                    NavigationLink {
                        if let user = commentUser {
                            OtherUserProfileView(buttonOnOff: $buttonOnOff,
                                                    user: user)
                        }
                    } label: {
                        if let user = commentUser {
                            CircularImageView(size: .xxxSmall,
                                                user: user)
                        }
                    }
                }
                .padding(.top, 6)
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    NavigationLink {
                        if let user = commentUser {
                            OtherUserProfileView(buttonOnOff: $buttonOnOff,
                                                    user: user)
                        }
                    } label: {
                        Text(replyComment.userID)
                            .fontWeight(.semibold)
                            .font(.system(.footnote))
                            .padding(.trailing, 4)
                            .foregroundStyle(.white)
                    }
                    
                    Text(replyComment.content)
                        .font(.system(.footnote))
                        .foregroundStyle(.white)
                    
                    Text(replyComment.time.formatDate(commentVM.comments[index].time))
                        .font(.system(.caption))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                    
                }
                .padding(.top, 6)
                .padding(.trailing, 10)
                
                Spacer()
            }
            .onAppear {
                Task {
                    await commentVM.getReplyCommentsDocument(post: post,
                                                             index: index)
                    if let replyComment = commentVM.replyComments[replyCommentID] {
                        if let user = await UpdateUserData.shared.getOthersProfileDatas(id: replyComment.userID) {
                         
                            self.commentUser = user
                            
                            self.isHeartCheck = commentVM.checkReplyCommentHeartExists(replyComment: replyComment)
                            
                            self.buttonOnOff =  UpdateFollowData.shared.checkFollowingStatus(id: user.nameID)
                        }
                    }
                }
            }
        }
    }
}

