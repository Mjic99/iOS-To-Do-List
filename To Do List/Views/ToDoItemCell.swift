//
//  ToDoItem.swift
//  To Do List
//
//  Created by Marcelo Inocente on 25/11/24.
//

import UIKit
import SwipeCellKit

class ToDoItemCell: SwipeTableViewCell {
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    let itemManager = ToDoItemManager()
    
    var item: ToDoItemDto?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onDoneClick(_ sender: UIButton) {
        Task {
            doneButton.isEnabled = false
            await itemManager.switchItemDoneStatus(documentId: item!.documentId!)
            NotificationCenter.default.post(name: Notification.Name(K.Notification.fetchToDoItems), object: nil)
            doneButton.isEnabled = true
        }
        
    }
}
