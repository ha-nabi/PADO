//
//  FollowViewModel.swift
//  PADO
//
//  Created by 최동호 on 1/23/24.
//

import Firebase
import FirebaseFirestoreSwift
import SwiftUI

class FollowViewModel: ObservableObject, Searchable {
    // IDs
    @Published var followerIDs: [String] = []
    @Published var followingIDs: [String] = []
    @Published var surferIDs: [String] = []
    @Published var surfingIDs: [String] = []
    
    // search
    @Published var searchedFollower: [String] = []
    @Published var searchedSurfer: [String] = []
    @Published var searchedFollowing: [String] = []
    @Published var isLoading: Bool = false
    
    // 서퍼지정 관련 변수들
    @Published var showSurfingList: Bool = false
    @Published var selectSurfingID: String = ""
    @Published var selectSurfingUsername: String = ""
    @Published var selectSurfingProfileUrl: String = ""
    
    @Published var searchResults: [User] = []
    @Published var viewState: ViewState = ViewState.empty
    
    @State var progress: Double = 0
    
    private var listeners: [CollectionType: ListenerRegistration] = [:]
    
    func initializeFollowFetch(id: String) async {
        await fetchIDs(id: id, collectionType: .following)
        await fetchIDs(id: id, collectionType: .follower)
        await fetchIDs(id: id, collectionType: .surfer)
        await fetchIDs(id: id, collectionType: .surfing)
    }
    
    @MainActor
    func fetchIDs(id: String, collectionType: CollectionType) async {
        self.isLoading = true
        let db = Firestore.firestore()
        
        listeners[collectionType] = db.collection("users").document(id).collection(collectionType.collectionName).addSnapshotListener { documentSnapshot, error in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching document: \(error!)")
                self.isLoading = false
                return
            }
            
            var ids: [String] = []
            for document in documents {
                if let documentId = document.data()["\(collectionType.collectionName)ID"] as? String {
                    ids.append(documentId)
                }
            }

            switch collectionType {
            case .follower:
                self.followerIDs = ids
                self.followerIDs = self.filterBlockedUserIDs(userIDs: self.followerIDs)
            case .following:
                self.followingIDs = ids
                self.followingIDs = self.filterBlockedUserIDs(userIDs: self.followingIDs)
                if id == userNameID {
                    userFollowingIDs = ids
                }
            case .surfer:
                self.surferIDs = ids
                self.surferIDs = self.filterBlockedUserIDs(userIDs: self.surferIDs)
            case .surfing:
                self.surfingIDs = ids
                self.surfingIDs = self.filterBlockedUserIDs(userIDs: self.surfingIDs)
            }
            self.isLoading = false
        }
    }
    
    func stopListeningForCollectionType(_ collectionType: CollectionType) {
        listeners[collectionType]?.remove()
        listeners[collectionType] = nil
    }
    
    func stopAllListeners() {
        for listener in listeners.values {
            listener.remove()
        }
        listeners.removeAll()
    }


    @MainActor
    func searchFollowers(with str: String, type: SearchFollowType) async {
        setViewState(to: .loading)
        self.isLoading = true

        if str.count > 0 {
            switch type {
            case .follower:
                var targetUsers: [User] = []
                var targetSurferUsers: [User] = []
                
                for i in followerIDs {
                    if let user = await UpdateUserData.shared.getOthersProfileDatas(id: i) {
                        targetUsers.append(user)
                    }
                }
                
                for i in surferIDs {
                    if let user = await UpdateUserData.shared.getOthersProfileDatas(id: i) {
                        targetSurferUsers.append(user)
                    }
                }
                searchedFollower = targetUsers.filter { $0.nameID.localizedCaseInsensitiveContains(str) || $0.username.localizedCaseInsensitiveContains(str) }
                                              .map { $0.nameID }
                searchedSurfer = targetSurferUsers.filter { $0.nameID.localizedCaseInsensitiveContains(str) || $0.username.localizedCaseInsensitiveContains(str) }
                    .map { $0.nameID }
                
            case .following:
                var targetUsers: [User] = []
                
                for i in followingIDs {
                    if let user = await UpdateUserData.shared.getOthersProfileDatas(id: i) {
                        targetUsers.append(user)
                    }
                }
                
                searchedFollowing = targetUsers.filter { $0.nameID.localizedCaseInsensitiveContains(str) || $0.username.localizedCaseInsensitiveContains(str) }
                    .map { $0.nameID }
            }
            self.isLoading = false
            setViewState(to: .ready)
        }
    }

}

extension FollowViewModel {
    private func filterBlockedUserIDs(userIDs: [String]) -> [String] {
        let blockedUserIDs = Set(blockingUser.map { $0.blockUserID } + blockedUser.map { $0.blockUserID })
        
        return userIDs.filter { userID in
            !blockedUserIDs.contains(userID)
        }
    }
}
