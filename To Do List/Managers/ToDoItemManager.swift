//
//  ToDoItemManager.swift
//  To Do List
//
//  Created by Marcelo Inocente on 27/11/24.
//

import Foundation

class ToDoItemManager {
    let firebaseManager = ToDoItemFirebaseManager()
    let localManager = ToDoItemLocalManager()

    func getToDoItems(onItemsSynced: @escaping ([ToDoItemDto]) -> Void) -> [ToDoItemDto] {
        let items = localManager.getItems()
        Task {
            await syncToDoItems(localItems: items, onItemsSynced: onItemsSynced)
        }
        return items.map { localManager.mapToDoItemToToDoItemDto(item: $0) }
    }
    
    func syncToDoItems(localItems: [ToDoItem], onItemsSynced: @escaping ([ToDoItemDto]) -> Void) async {
        do {
            let unsyncedLocalItems = localItems.filter { !$0.isSynced }
            for localItem in unsyncedLocalItems {
                if let documentId = localItem.documentId { //the local item also exists on firebase
                    if localItem.toBeDeleted { //item has to be deleted from firebase
                        try await firebaseManager.deleteToDoItem(documentId: documentId)
                        localManager.deleteItem(documentId: documentId)
                    } else { //we update the item with what we have locally
                        try await firebaseManager.updateToDoItem(item: localItem)
                        localManager.markItemAsSynced(item: localItem, documentId: documentId)
                    }
                } else { //the local item is not on firebase yet
                    if localItem.toBeDeleted { //just delete the local item
                        localManager.deleteItem(item: localItem)
                    } else { //create the item on firebase
                        let documentId = try await firebaseManager.createToDoItem(item: localItem)
                        localManager.markItemAsSynced(item: localItem, documentId: documentId)
                    }
                }
            }
            let items = try await firebaseManager.getToDoItems()
            onItemsSynced(items)
        } catch {
            print("failed to fetch from firebase")
        }
    }
    
    func createToDoItem(name: String, priority: Int) async {
        let item = localManager.createToDoItem(name: name, priority: priority)
        do {
            let documentId = try await firebaseManager.createToDoItem(item: item)
            localManager.markItemAsSynced(item: item, documentId: documentId)
        } catch {
            print("failed to create on firebase")
        }
    }
    
    func updateToDoItem(documentId: String, name: String, priority: Int) async {
        let item = localManager.updateToDoItem(documentId: documentId, name: name, priority: priority)
        do {
            try await firebaseManager.updateToDoItem(item: item)
            localManager.markItemAsSynced(item: item, documentId: documentId)
        } catch {
            print("failed to update on firebase")
        }
    }
    
    func deleteToDoItem(documentId: String) async {
        localManager.markAsDeleted(documentId: documentId)
        do {
            try await firebaseManager.deleteToDoItem(documentId: documentId)
            localManager.deleteItem(documentId: documentId)
        } catch {
            print("failed to delete on firebase")
        }
    }
    
    func switchItemDoneStatus(documentId: String) async {
        let item = localManager.switchDoneStatus(documentId: documentId)
        do {
            try await firebaseManager.updateToDoItemStatus(documentId: documentId, done: item.done)
            localManager.markItemAsSynced(item: item, documentId: documentId)
        } catch {
            print("failed to update on firebase")
        }
    }
}
