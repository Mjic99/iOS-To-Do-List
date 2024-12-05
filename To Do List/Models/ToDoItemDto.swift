//
//  ToDoItem.swift
//  To Do List
//
//  Created by Marcelo Inocente on 25/11/24.
//

import Foundation

struct ToDoItemDto {
    let name: String
    let priority: Int
    let creationDate: Date
    let done: Bool
    let documentId: String?
}
