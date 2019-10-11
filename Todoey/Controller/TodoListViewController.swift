//
//  ViewController.swift
//  Todoey
//
//  Created by Nathaniel Tucker on 9/28/19.
//  Copyright © 2019 Nathaniel Tucker. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController
{
    //MARK: - Global Variables and viewDidLoad
    var todoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    //MARK: - Navigation Bar Update
    override func viewWillAppear(_ animated: Bool) {


        guard let navHexColor = selectedCategory?.color else { fatalError() }

        title = selectedCategory?.name
        updateNavBar(withHexCode: navHexColor)

    }
    override func viewWillDisappear(_ animated: Bool) {

        updateNavBar(withHexCode: "1D9BF6")

    }

    func updateNavBar(withHexCode colorHexCode: String)
    {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation View Controller does not exist") }
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor

    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]
        {
            let categorySelectedColor = UIColor(hexString: selectedCategory!.color)
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none

            if let color = categorySelectedColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
            {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }

            cell.textLabel?.text = "No Items Added"
        }
        cell.textLabel?.text = todoItems?[indexPath.row].title ?? "No Items Added"

        return cell
    }

    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error writing to ream for DONE status: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default)
        {
            (action) in
            if textField.text != ""
            {
                if let currentCategory = self.selectedCategory{
                    do{
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }catch{
                        print("Error saving context: \(error)")
                    }
                }
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Data Manipulation Methods


    func loadItems()
    {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    //MARK: - Delete Method from Swipe
    override func updateModel(at indexPath: IndexPath)
    {
        if let itemsForDeletion = self.todoItems?[indexPath.row]
        {
            do
            {
                try self.realm.write
                {
                    self.realm.delete(itemsForDeletion)
                }
            }
            catch
            {
                print("Error saving context: \(error)")
            }
        }
    }
}

//MARK: - Searchbar Methods
extension TodoListViewController: UISearchBarDelegate
{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text?.count == 0
        {
            loadItems()
            DispatchQueue.main.async
            {
                searchBar.resignFirstResponder()
            }
        }
    }
}
