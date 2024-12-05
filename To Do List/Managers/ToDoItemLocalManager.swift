//
//  ToDoItemLocalManager.swift
//  To Do List
//
//  Created by Marcelo Inocente on 2/12/24.
//

import UIKit
import CoreData
import FirebaseAuth

class ToDoItemLocalManager {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func createToDoItem(name: String, priority: Int) -> ToDoItem {
        let userId = Auth.auth().currentUser?.uid
        let newToDoItem = ToDoItem(context: context)
        newToDoItem.name = name
        newToDoItem.priority = Int32(priority)
        newToDoItem.creationDate = Date()
        newToDoItem.done = false
        newToDoItem.isSynced = false
        newToDoItem.userId = userId
        
        saveContext()
        return newToDoItem
    }
    
    func markItemAsSynced(item: ToDoItem, documentId: String) {
        item.isSynced = true
        item.documentId = documentId
        saveContext()
    }

    func getItems() -> [ToDoItem] {
        let userId = Auth.auth().currentUser?.uid
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        request.predicate = NSPredicate(format:"userId == %@", userId!)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ToDoItem.priority), ascending: false),
            NSSortDescriptor(key: #keyPath(ToDoItem.name), ascending: true)
        ]
        do {
            let items = try context.fetch(request)
            return items
        } catch {
            print("Error getting local data: \(error)")
            return []
        }
    }
    
    func updateToDoItem(documentId: String, name: String, priority: Int) -> ToDoItem {
        let item = getItemByDocumentId(documentId: documentId)
        item?.name = name
        item?.priority = Int32(priority)
        item?.isSynced = false
        saveContext()
        return item!
    }
    
    func getItemByDocumentId(documentId: String) -> ToDoItem? {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format:"documentId == %@", documentId)
        let result = try? context.fetch(request)
        
        if result?.count == 1 {
            return result![0]
        }
        return nil
    }
    
    func deleteItem(documentId: String) {
        let item = getItemByDocumentId(documentId: documentId)
        if let item = item {
            context.delete(item)
            saveContext()
        }
    }
    
    func deleteItem(item: ToDoItem) {
        context.delete(item)
        saveContext()
    }
    
    func markAsDeleted(documentId: String) {
        let item = getItemByDocumentId(documentId: documentId)
        item?.toBeDeleted = true
        item?.isSynced = false
        saveContext()
    }
    
    func switchDoneStatus(documentId: String) -> ToDoItem {
        let item = getItemByDocumentId(documentId: documentId)
        item?.done = !(item?.done)!
        item?.isSynced = false
        saveContext()
        return item!
    }
    
    func mapToDoItemToToDoItemDto(item: ToDoItem) -> ToDoItemDto {
        return ToDoItemDto(
            name: item.name!,
            priority: Int(item.priority),
            creationDate: item.creationDate ?? Date(),
            done: item.done,
            documentId: item.documentId
        )
    }
}
