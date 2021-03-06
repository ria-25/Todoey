//
//  ViewController.swift
//  Todoey
//
//  Created by Easyway_Mac2 on 05/04/19.
//  Copyright © 2019 Easyway_Mac2. All rights reserved.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {
    
    //Instance Variables
    
    let cellId = "ToDoItemCell"
    var toDoList = ["Buy Apples", "Do Laundry", "Destroy people"]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet {
            self.navigationItem.title = selectedCategory?.name
            loadData()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadData()
    }


    //MARK - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //To delete Items from coredata
        
//        context.delete(itemArray[indexPath.row])
//        self.itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add New Item", style: .default) { (action) in
        let item = Item(context: self.context)
            item.title = textField.text!
            item.done = false
            item.parentCategory = self.selectedCategory!
            
         self.itemArray.append(item)
            
         self.saveData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Manipulate Model Data
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Context saving error, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name!)!)
        
        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            self.itemArray = try context.fetch(request)
        } catch {
            print("Error while fetching request \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: Codable
    
 /*   func saveData(){

        let encoder = PropertyListEncoder()

        do {
           let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Encoder failed error, \(error)")
        }

        tableView.reloadData()
    }

    func loadData(){
        if let data = try? Data.init(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()

            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("decoding failed error, \(error)")
            }
        }
    }
 */
    
}

//MARK: - Search bar methods
extension ToDoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadData(with: request, predicate: request.predicate)
    }
  
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text!.count == 0 {
            loadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
