//
//  ViewController.swift
//  Todoey
//
//  Created by Nathaniel Tucker on 9/28/19.
//  Copyright © 2019 Nathaniel Tucker. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController
{
    //MARK: - Global Variables
    var itemArray = [Item]()
    let defaults = UserDefaults.standard
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)

        let newItem1 = Item()
        newItem1.title = "Buy Eggos"
        itemArray.append(newItem1)

        let newItem2 = Item()
        newItem2.title = "Destroy Demogorgon"
        itemArray.append(newItem2)

        if let items = defaults.array(forKey: "TodoListArray") as? [Item]
        {
            itemArray = items
        }
    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title

        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

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
                let newItem = Item()
                newItem.title = textField.text!

                self.itemArray.append(newItem)
                self.defaults.set(self.itemArray, forKey: "TodoListArray")
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
}

