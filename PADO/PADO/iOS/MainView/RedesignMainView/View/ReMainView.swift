//
//  ReMainView.swift
//  PADO
//
//  Created by 강치우 on 1/20/24.
//

import SwiftUI

struct ReMainView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Pic3")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    // MARK: - Header
                    MainHeaderCell()
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.leading, 4)
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    //MARK: - HeartComment
                    HeartCommentCell()
                        .padding(.leading, UIScreen.main.bounds.width)
                        .padding(.trailing, 55)
                        .padding(.top)
                    
                    // MARK: - Story
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<storyData.count, id: \.self) { cell in
                                StoryCell(story: storyData[cell])
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding()
                }
            }
        }
    }
}


#Preview {
    ReMainView()
}
