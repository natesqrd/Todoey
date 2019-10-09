//
//  CatagoryViewController.swift
//  Todoey
//
//  Created by Nathaniel Tucker on 10/5/19.
//  Copyright © 2019 Nathaniel Tucker. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    //MARK: - Variables and viewDidLoad
    let realm = try! Realm()

    var categories : Results<Category>?



    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        loadCategories()

    }
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added"
        cell.delegate = self

        return cell
    }
    //MARK: - Data Manipulation Methods
    func save(category : Category)
    {
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }

    func loadCategories()
    {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    //MARK: - Add New Catagories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default)
        {
            (action) in
            if textField.text != ""
            {
                let newCategory = Category()
                newCategory.name = textField.text!

                self.save(category: newCategory)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }


    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VCDestination = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow
        {
            VCDestination.selectedCategory = categories?[indexPath.row]

        }
    }

}

//MARK: - SwipeCell Delegate Methods
extension CategoryViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("delete icon present")
            if let categoriesForDeletion = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(categoriesForDeletion)
                }
            }catch{
                print("Error saving context: \(error)")
            }
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }

}
