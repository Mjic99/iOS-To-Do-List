//
//  EditToDoItemViewController.swift
//  To Do List
//
//  Created by Marcelo Inocente on 2/12/24.
//

import UIKit

class EditToDoItemViewController: UIViewController {
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var priorityPicker: UIPickerView!
    
    var item: ToDoItemDto?
    
    let toDoItemManager = ToDoItemManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        priorityPicker.dataSource = self
        priorityPicker.delegate = self

        descriptionTextField.text = item?.name
        let row = (item?.priority)! - 1
        priorityPicker.selectRow(row, inComponent: 0, animated: false)
    }

    @IBAction func updateItem(_ sender: UIButton) {
        Task { @MainActor in
            if let itemName = descriptionTextField.text, let toDoItem = item {
                let priorityIndex = priorityPicker.selectedRow(inComponent: 0)
                await toDoItemManager.updateToDoItem(
                    documentId: toDoItem.documentId!,
                    name: itemName,
                    priority: K.priorities[priorityIndex]
                )
                dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name(K.Notification.fetchToDoItems), object: nil)
                }
            }
        }
    }
}

extension EditToDoItemViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return K.priorities.count
    }
}

extension EditToDoItemViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(K.priorities[row])
    }
}
