//
//  HeartNotificationCell.swift
//  PADO
//
//  Created by 황민채 on 2/8/24.
//

import Kingfisher
import SwiftUI

struct HeartNotificationCell: View {
    @ObservedObject var notiVM: NotificationViewModel
    
    var notification: Noti
    
    var body: some View {
        Button {
            notiVM.showHeartPost = true
        } label: {
            HStack(spacing: 0) {
                if let user = notiVM.notiUser[notification.sendUser] {
                    CircularImageView(size: .medium,
                                      user: user)
                    .padding(.trailing, 10)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(notification.sendUser)님이 회원님의 파도에 ❤️로 공감했습니다. ")
                            .font(.system(.subheadline))
                            .fontWeight(.medium)
                        +
                        Text(notification.createdAt.formatDate(notification.createdAt))
                            .font(.system(.footnote))
                            .foregroundStyle(Color(.systemGray))
                    }
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                }
                Spacer()
                
            }
        }
        .sheet(isPresented: $notiVM.showHeartPost) {
            if let postID = notification.postID,
               let post = notiVM.notiPosts[postID] {
                NavigationStack {
                    FeedCell(post: .constant(post))
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
