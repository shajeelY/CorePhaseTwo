//
//  ViewController.swift
//  CorePhaseTwoA
//
//  Created by Shajeel Yahya on 11/27/20.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate{
//It takes over our existing NSFetchRequest to load data, replaces our Word array with its own storage, and even works to ensure the user interface stays in sync with changes to the data by controlling the way objects are inserted and deleted
    

    private lazy var dataProvider: WordProvider = {
        let provider = WordProvider()
        provider.fetchedResultsControllerDelegate = self
        return provider
    }()
    
    
   private func handleBatchOperationCompletion(error: Error?) {
    if let error = error {
    let alert = UIAlertController(title: "Executing batch operation error!",
                                         message: error.localizedDescription,
                                         preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
           
       } else {
           dataProvider.resetAndRefetch()
           tableView.reloadData()
       }
   }
    
    
    @IBAction func fetchKanjiDictionary(_ sender: UIBarButtonItem) {
        dataProvider.fetchKanji { error in
            DispatchQueue.main.async {
                // Alert the error or refresh the table if no error.
                self.handleBatchOperationCompletion(error: error)
            }
        }
    }
    
    
    
 
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Kanji", for: indexPath)

        let kanji = dataProvider.fetchedResultsController.fetchedObjects?[indexPath.row]
        cell.textLabel!.text = kanji?.k_ele[0]
        cell.detailTextLabel!.text = kanji?.sense[0]
        return cell
    }
    

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    

    
    
    
    
}

