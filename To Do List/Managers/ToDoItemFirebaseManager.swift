//
//  ToDoItemFirebaseManager.swift
//  To Do List
//
//  Created by Marcelo Inocente on 2/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ToDoItemFirebaseManager {
    let db = Firestore.firestore()

    func getToDoItems() async throws -> [ToDoItemDto] {
        let userId = Auth.auth().currentUser?.uid
        let querySnapshot = try await db.collection("ToDoItems")
            .whereField("userId", isEqualTo: userId!)
            .getDocuments()
        var items: [ToDoItemDto] = []
        for document in querySnapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String, let priority = data["priority"] as? Int, let creationDate = data["creationDate"] as? Double, let done = data["done"] as? Bool {
                items.append(ToDoItemDto(
                    name: name,
                    priority: priority,
                    creationDate: Date(timeIntervalSince1970: creationDate),
                    done: done,
                    documentId: document.documentID
                ))
            }
        }
        items.sort {
            if $0.priority == $1.priority {
                return $0.name < $1.name
            }
            return $0.priority > $1.priority
        }
        return items
    }

    func createToDoItem(item: ToDoItem) async throws -> String {
        let userId = Auth.auth().currentUser?.uid
        let item = try await db.collection("ToDoItems").addDocument(data: [
            "userId": userId!,
            "name": item.name!,
            "priority": item.priority,
            "done": item.done,
            "creationDate": (item.creationDate?.timeIntervalSince1970)!
        ])
        return item.documentID
    }

    func updateToDoItem(item: ToDoItem) async throws {
        try await db.collection("ToDoItems").document(item.documentId!).setData([
            "name": item.name!,
            "priority": item.priority,
            "done": item.done
        ], merge: true)
    }
    
    func updateToDoItemStatus(documentId: String, done: Bool) async throws {
        try await db.collection("ToDoItems").document(documentId).setData([
            "done": done,
        ], merge: true)
    }
    
    func deleteToDoItem(documentId: String) async throws {
        try await db.collection("ToDoItems").document(documentId).delete()
    }
}
