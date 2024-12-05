//
//  ViewController.swift
//  To Do List
//
//  Created by Marcelo Inocente on 21/11/24.
//

import UIKit
import SwipeCellKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let toDoItemManager = ToDoItemManager()
    
    var toDoItems: [ToDoItemDto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavTitle()
        replaceBackButton()
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.toDoCellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        getToDoItems()
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissal), name: Notification.Name(K.Notification.fetchToDoItems), object: nil)
    }
    
    func replaceBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(systemName: "iphone.and.arrow.right.outward"), style: .plain, target: self, action: #selector(logout(sender:)))
        newBackButton.tintColor = UIColor(named: "Red")
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func logout(sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error signing out \(error)")
        }
    }
    
    func addNavTitle() {
        let navView = UIView()

        // Create the label
        let label = UILabel()
        label.text = "TO-DO LIST"
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = .center

        // Create the image view
        let image = UIImageView()
        image.image = UIImage(named: "icon")
        // To maintain the image's aspect ratio:
        let imageAspect = image.image!.size.width/image.image!.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = .scaleAspectFit

        // Add both the label and image view to the navView
        navView.addSubview(label)
        navView.addSubview(image)

        // Set the navigation bar's navigation item's titleView to the navView
        self.navigationItem.titleView = navView

        // Set the navView's frame to fit within the titleView
        navView.sizeToFit()
    }

    @objc func handleModalDismissal() {
        getToDoItems()
    }

    @IBAction func addItem(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.Segue.addItemSegue, sender: self)
    }

    func getToDoItems() {
        self.toDoItems = toDoItemManager.getToDoItems() { items in
            self.toDoItems = items
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func deleteItem(documentId: String) async {
        await toDoItemManager.deleteToDoItem(documentId: documentId)
        getToDoItems()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! ToDoItemCell
        let item = toDoItems[indexPath.row]

        cell.delegate = self
        cell.label.text = item.name
        cell.priorityLabel.text = String(item.priority)
        cell.item = item
        if item.done {
            cell.doneButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            cell.doneButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .highlighted)
        } else {
            cell.doneButton.setImage(UIImage(systemName: "square"), for: .normal)
            cell.doneButton.setImage(UIImage(systemName: "square.fill"), for: .highlighted)
        }

        return cell
    }
}
extension ViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                let item = self.toDoItems[indexPath.row]
                let alert = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                    Task {
                        await self.deleteItem(documentId: item.documentId!)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(deleteAction)
                self.present(alert, animated: true)
            }
            
            let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
                let item = self.toDoItems[indexPath.row]
                self.performSegue(withIdentifier: K.Segue.editItemSegue, sender: item)
            }

            deleteAction.image = UIImage(systemName: "trash.fill")
            editAction.image = UIImage(systemName: "pencil")

            return [deleteAction, editAction]
        }
        return []
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.editItemSegue {
            if let editVC = segue.destination as? EditToDoItemViewController, let item = sender as? ToDoItemDto {
                editVC.item = item
            }
        }
    }
}
