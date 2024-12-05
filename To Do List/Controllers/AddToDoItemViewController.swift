//
//  AddToDoItemViewController.swift
//  To Do List
//
//  Created by Marcelo Inocente on 26/11/24.
//

import UIKit

class AddToDoItemViewController: UIViewController {
    @IBOutlet weak var toDoTextField: UITextField!
    @IBOutlet var priorityPicker: UIPickerView!
    
    let toDoItemManager = ToDoItemManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        priorityPicker.dataSource = self
        priorityPicker.delegate = self
    }

    @IBAction func createButtonPressed(_ sender: UIButton) {
        Task { @MainActor in
            if let itemName = toDoTextField.text {
                let priorityIndex = priorityPicker.selectedRow(inComponent: 0)
                await toDoItemManager.createToDoItem(
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

extension AddToDoItemViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return K.priorities.count
    }
}

extension AddToDoItemViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(K.priorities[row])
    }
}
