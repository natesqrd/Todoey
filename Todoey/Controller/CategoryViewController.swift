//
//  CatagoryViewController.swift
//  Todoey
//
//  Created by Nathaniel Tucker on 10/5/19.
//  Copyright © 2019 Nathaniel Tucker. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    //MARK: - Variables and viewDidLoad
    let realm = try! Realm()

    var categories : Results<Category>?



    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()

    }
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        guard let category = categories?[indexPath.row] else { fatalError() }
        cell.textLabel?.text = category.name

        if let categoryColor = UIColor(hexString: category.color) {
        cell.backgroundColor = categoryColor
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
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
    //MARK: - Delete Method from Swipe
    override func updateModel(at indexPath: IndexPath)
    {
        if let categoriesForDeletion = self.categories?[indexPath.row]
        {
        do
        {
            try self.realm.write
            {
                self.realm.delete(categoriesForDeletion)
            }
        }
            catch
            {
                print("Error saving context: \(error)")
            }
        }
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
                newCategory.color = UIColor.randomFlat.hexValue()
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


