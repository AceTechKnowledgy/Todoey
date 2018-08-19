//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ace on 15/08/18.
//  Copyright © 2018 Ace. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeViewController {
    
    //Realm Init
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categoryArray?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No Categories Added"
        
        cell.backgroundColor = UIColor(hexString: category?.colorName)
        
        return cell
    }
    
    //MARK: Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }

    //MARK: IBAction
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var categoryText = UITextField()
        
        let alertView = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alertView.addTextField {
            (itemTextField) in
            itemTextField.placeholder = "Enter the item"
            categoryText = itemTextField
        }
        
        let alertAction = UIAlertAction(title: "Add", style: .default) {
            (action) in
            
            let newCategory = Category()
            newCategory.name = categoryText.text!
            newCategory.colorName = UIColor.randomFlat().hexValue()
            
            self.saveCategory(category: newCategory)
            
            self.tableView.reloadData()
        }
        
        alertView.addAction(alertAction)
        present(alertView, animated: true, completion: nil)
    }

    func loadCategory() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    func saveCategory(category: Category?) {
        do {
            try realm.write {
                realm.add(category!)
            }
        } catch {
            print("Error on adding an Object on Realm \(error)")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        // handle action by updating model with deletion
        if let deleteCat = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(deleteCat)
                }
            } catch {
                print("Error on deleting category \(error)")
            }
        }
    }
}

