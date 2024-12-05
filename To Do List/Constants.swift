//
//  Constants.swift
//  To Do List
//
//  Created by Marcelo Inocente on 26/11/24.
//

import Foundation

struct K {
    static let priorities = [1, 2, 3, 4, 5, 6, 7]
    static let toDoCellNibName = "ToDoItem"
    static let cellIdentifier = "ReusableCell"
    
    struct Segue {
        static let addItemSegue = "AddItemSegue"
        static let editItemSegue = "EditItemSegue"
        static let signUpSegue = "SignUpToList"
        static let loginSegue = "LoginToList"
        static let alreadyLoggedInSegue = "alreadyLoggedInSegue"
    }
    
    struct Notification {
        static let fetchToDoItems = "fetchToDoItems"
    }
}
