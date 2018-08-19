//
//  ViewController.swift
//  Todoey
//
//  Created by Ace on 12/08/18.
//  Copyright © 2018 Ace. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoTableViewController: SwipeViewController {

    /*As this is a TableViewController we no need to conform to datasource and delegate protocol */
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //Creating an array
    var itemArray: Results<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.colorName {
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation bar is not there")
            }
            title = selectedCategory?.name
            navBar.tintColor = UIColor(hexString: colorHex)
        }
    }

    //MARK: TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create a new cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //Each item in the array
        if let item = itemArray?[indexPath.row] {
        
            cell.textLabel?.text = item.itemName
            cell.accessoryType = item.isChecked ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory?.colorName).darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:color, isFlat:true)
            }
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.isChecked = !item.isChecked
                }
            } catch {
                print("Error on updating the realm \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: Add items to Todo list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var todoTextField = UITextField()
        
        //Adding a Alert controller to add a item
        let alertView = UIAlertController(title: "Add items to Todo", message: "", preferredStyle: .alert)
        
        //Creating an action
        let alertAction = UIAlertAction(title: "Add item", style: .default) {
            (action) in
            
            //Adding the item to the CoreData thru the context
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.itemName = todoTextField.text!
                        newItem.isChecked = false
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error on writing \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        //Adding a textfield in the Alert
        alertView.addTextField { (alertTextView) in
            alertTextView.placeholder = "Create a todo item"
            todoTextField = alertTextView
        }
        
        //Adding the action to the alertview
        alertView.addAction(alertAction)
        
        //Presenting the alertview
        present(alertView, animated: true, completion: nil)
    }
    
    //Load the persisted data from the saved Coredata method
    func loadItems() {
        
        itemArray = self.selectedCategory?.items.sorted(byKeyPath: "itemName", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        // handle action by updating model with deletion
        if let deleteCat = self.itemArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(deleteCat)
                }
            } catch {
                print("Error on deleting category: \(error)")
            }
        }
    }
}

//MARK: Extension for Searchbar
//Creating an extension for this class for extending the Searchbar function
extension TodoTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("itemName CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "itemName", ascending: true)
        
        tableView.reloadData()
    }

    //This delegate method is called when the user start typing in the searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Once typed and found the result. When the user pressed the cancel button we need bring the original list back
        if searchBar.text!.count == 0 {
            loadItems()

            //This is to cancel the background thread to stop once the searching is stop and return to main thread.
            DispatchQueue.main.async {
                //This will set the searchbox to the original state(removing the keyboard and stop cursor blinking)
                searchBar.resignFirstResponder()
            }

        }
    }
}














