//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Mohamed Hany on 16/07/2023.
//

import UIKit
import CoreData
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let category = categories[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = category.name
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = category.name
        }

        return cell
    }
    
    //MARK: - Data manipulation
    func saveCategories(){
        do{
            if context.hasChanges{
                try context.save()
            }
        }catch{
            showErrorAlert(title: error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){

        do{
            categories = try context.fetch(request)
            tableView.reloadData()
        }catch{
            showErrorAlert(title: error.localizedDescription)
        }
    }
    
    func showErrorAlert(title: String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        present(alert, animated: true)
    }
    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            if let unwrappedCategory = textField.text , unwrappedCategory != "" {
                let newCategory = Category(context: self.context)
                newCategory.name = unwrappedCategory
                self.categories.append(newCategory)
                self.saveCategories()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        alert.addTextField{ alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinactionVC = segue.destination as! ToDoListViewController
        
        if let indexpath = tableView.indexPathForSelectedRow {
            destinactionVC.selectedCategory = categories[indexpath.row]
        }
    }
}

//MARK: - Swipe Cell delegate
extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }

            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
            }

            // customize the action appearance
            deleteAction.image = UIImage(named: "delete")

            return [deleteAction]
    }
    
}
