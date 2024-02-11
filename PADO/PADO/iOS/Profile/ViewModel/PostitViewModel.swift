//
//  PostitViewModel.swift
//  PADO
//
//  Created by 최동호 on 2/9/24.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation

class PostitViewModel: ObservableObject {
    @Published var messages: [PostitMessage] = []
    @Published var ownerID: String = ""
    @Published var inputcomment: String = ""
    @Published var longpressedMessage: String = ""
    @Published var longpressedID: String = ""
    @Published var showdeleteModal: Bool = false
    @Published var messageUserIDs: [String] = []
    @Published var messageUsers: [String: User] = [:]
    
    let db = Firestore.firestore()
    
    @MainActor
    func getMessageDocument(ownerID: String) async {
        self.messages.removeAll()
        self.ownerID = ownerID
        do {
            let querySnapshot = try await db.collection("users").document(ownerID).collection("message").order(by: "messageTime", descending: false).getDocuments()
            self.messages = querySnapshot.documents.compactMap { document in
                try? document.data(as: PostitMessage.self)
            }
            self.messageUserIDs = removeDuplicateUserIDs(from: messages)
            await fetchMessageUser(ownerID: ownerID)
        } catch {
            print("Error fetching comments: \(error)")
        }
    }
    
    @MainActor
    func writeMessage(ownerID: String, imageUrl: String, inputcomment: String) async {
        
        let initialMessageData : [String: Any] = [
            "messageUserID": userNameID,
            "imageUrl": imageUrl,
            "content": inputcomment,
            "messageTime": Timestamp(),
        ]
        await createMessageData(ownerID: ownerID, data: initialMessageData)
        self.inputcomment = ""
    }
    
    @MainActor
    func createMessageData(ownerID: String, data: [String: Any]) async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss.sssZ"
        
        let formattedDate = dateFormatter.string(from: Date())
        let formattedCommentTitle = userNameID+formattedDate
        
        do {
            try await db.collection("users").document(ownerID).collection("message").document(formattedCommentTitle).setData(data)
            
        } catch {
            print("Error saving post data: \(error.localizedDescription)")
        }
        
        await getMessageDocument(ownerID: ownerID)
    }
    
    @MainActor
    func removeMessageData(ownerID: String, messageID: String) async {
        do {
            try await db.collection("users").document(ownerID).collection("message").document(messageID).delete()
            await getMessageDocument(ownerID: ownerID)
        } catch {
            print("Error removing document: \(error.localizedDescription)")
        }
    }
    
    func removeDuplicateUserIDs(from messages: [PostitMessage]) -> [String] {
        let userIDs = messages.map { $0.messageUserID }
        let uniqueUserIDs = Set(userIDs)
        return Array(uniqueUserIDs)
    }
    
    @MainActor
    func fetchMessageUser(ownerID: String) async {
        do {
            for documentID in messageUserIDs {
                let querySnapshot = try await db.collection("users").document(documentID).getDocument()
                
                let userData = try? querySnapshot.data(as: User.self)
                self.messageUsers[documentID] = userData
            }
        } catch {
            print("Error fetch User: \(error.localizedDescription)")
        }
    }
}
