//
//  CreateGroupController.swift
//  Table
//
//  Created by Henri El Daher on 11/11/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class CreateGroupController: UIViewController {
    
    let container = CKContainer.default()
    var group: CKRecord?
    
    var searchResults = [String]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        
        if groupName.text! != "" {
            let newGroup = CKRecord(recordType: "Group")
            newGroup["name"] = groupName.text! as NSString
        
            let db = container.publicCloudDatabase
            
            db.save(newGroup, completionHandler: { (record, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("group saved")
                }
            })
        
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension CreateGroupController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = []
        
        for i in 0...2 {
            searchResults.append(String(format: "Fake Result %d for '%@'", i, searchBar.text!))
        }
        
        tableView.reloadData()
    }
}

extension CreateGroupController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel!.text = searchResults[indexPath.row]
        return cell
    }
}

extension CreateGroupController: UITableViewDelegate {
    
}




