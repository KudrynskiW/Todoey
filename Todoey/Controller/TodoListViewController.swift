//
//  ViewController.swift
//  Todoey
//
//  Created by Wojciech Kudrynski on 25/06/2020.
//  Copyright © 2020 Wojciech Kudrynski. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadTodoArray()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = todoItems?[indexPath.row].title ?? "No items added"
        cell.accessoryType = (todoItems?[indexPath.row].done ?? false) ? .checkmark : .none
        
        return cell
    }

    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            guard let text = textField.text, let currnetCategory = self.selectedCategory else {
                return
            }
 
            do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = text
                    newItem.done = false
                    newItem.dateCreated = Date()
                    currnetCategory.items.append(newItem)
                }
            } catch {
                print("Error saving item \(error)")
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func loadTodoArray() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchBar.text?.count != 0, let text = searchBar.text else {
            loadTodoArray()
            tableView.reloadData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            return
        }

        todoItems = todoItems?.filter("title CONTAINS[cd] %@", text)
                    .sorted(byKeyPath: "dateCreated", ascending: false)

        tableView.reloadData()
    }
}

