//
//  UpdatePhotomojiData.swift
//  PADO
//
//  Created by 최동호 on 2/6/24.
//
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import Foundation

class UpdateFacemojiData {
    let db = Firestore.firestore()
    
    func getFaceMoji(documentID: String) async throws -> [Facemoji]? {
        do {
            let querySnapshot = try await db.collection("post").document(documentID).collection("facemoji").order(by: "time", descending: false).getDocuments()
            let facemojies = querySnapshot.documents.compactMap { document in
                try? document.data(as: Facemoji.self)
            }
            return facemojies
        } catch {
            print("Error fetching comments: \(error)")
        }
        return nil
    }
    
    
    func deleteFaceMoji(documentID: String, storagefileName: String) async {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("facemoji/\(storagefileName)")
        
        do {
            try await db.collection("post").document(documentID).collection("facemoji").document(userNameID).delete()
            
            try await storageRef.delete()
        } catch {
            print("페이스모지 삭제 오류 : \(error.localizedDescription)")
        }
    }
    
    func updateEmoji(documentID: String, emoji: String) async {
        do {
            try await db.collection("post").document(documentID).collection("facemoji").document(userNameID).updateData([
                "emoji" : emoji
            ])
        } catch {
            print("파이어베이스에 이모지 업로드 오류 : \(error.localizedDescription)")
        }
    }
    
    func updateFaceMoji(cropMojiUIImage: UIImage, documentID: String, selectedEmoji: String) async throws {
        let imageData = try await UpdateImageUrl.shared.updateImageUserData(
            uiImage: cropMojiUIImage,
            storageTypeInput: .facemoji,
            documentid: documentID,
            imageQuality: .lowforFaceMoji,
            surfingID: ""
        )
        
        print(imageData)
        
        try await db.collection("post").document(documentID).collection("facemoji").document(userNameID).updateData([
            "userID" : userNameID,
            "storagename" : "\(userNameID)-\(documentID)",
            "time" : Timestamp(),
            "emoji" : selectedEmoji
        ])
    }
    
}
