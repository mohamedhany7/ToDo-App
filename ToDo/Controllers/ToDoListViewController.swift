//
//  ViewController.swift
//  ToDo
//
//  Created by Mohamed Hany on 08/07/2023.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var items = [Item]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            if let unwrappedItem = textField.text , unwrappedItem != "" {
                let newItem = Item(context: self.context)
                newItem.title = unwrappedItem
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.items.append(newItem)
                self.saveItems()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        alert.addAction(action)
        alert.addTextField{ alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = items[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = item.title
        }
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.items[indexPath.row].done.toggle()
        tableView.reloadData()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          context.delete(items[indexPath.row])
          self.items.remove(at: indexPath.row)
          self.tableView.deleteRows(at: [indexPath], with: .automatic)
          saveItems()
      }
    }
    
    func saveItems(){
        do{
            if context.hasChanges{
                try context.save()
            }
        }catch{
            showErrorAlert(title: error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
            request.predicate = compoundPredicate
        }else {
            request.predicate = categoryPredicate
        }
        
        do{
            items = try context.fetch(request)
            tableView.reloadData()
        }catch{
            showErrorAlert(title: error.localizedDescription)
        }
    }
    
    func showErrorAlert(title: String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        present(alert, animated: true)
    }
    
}

//MARK: - SearchBar Delegate

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let unwrappedText = searchBar.text, unwrappedText != "" {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", unwrappedText)
                        
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request, predicate: predicate)
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String){
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
