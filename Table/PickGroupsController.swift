//
//  PickGroupsController.swift
//  Table
//
//  Created by Henri El Daher on 11/21/17.
//  Copyright © 2017 Henri El Daher. All rights reserved.
//

import UIKit
import CloudKit

class PickGroupsController: UIViewController {
    
    //next step (Friday) - need to use code from create group controller in this controller
    //allow groups to be checked and unchecked
    //need to move 'save post' code in done method to this controller
    
    let container = CKContainer.default()
    var groups = [CKRecord]()
    var selectedGroups = [CKRecord]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGroups()
    }
    
    func fetchGroups() {
        groups = [CKRecord]()
        
        let query = CKQuery(recordType: "Group", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        let db = container.publicCloudDatabase
        db.perform(query, inZoneWith: nil) { (results:[CKRecord]?, error:Error?) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let groups = results {
                self.groups = groups
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

}


extension PickGroupsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        let label = cell.viewWithTag(6000) as! UILabel
        
        if groups.count == 0 {
            label.text = "(Nothing Found)"
        } else {
            let group = groups[indexPath.row]
            label.text = group["name"] as? String
        }
        
        return cell
    }
}

extension PickGroupsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        if let cell = tableView.cellForRow(at: indexPath) {
            var tappedGroup = groups[indexPath.row]
            let label = cell.viewWithTag(6001) as! UILabel
            
            let db = container.publicCloudDatabase
            db.fetch(withRecordID: tappedGroup.recordID, completionHandler: { (record, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    tappedGroup = record!
                    
                    if tappedGroup["checked"] as! String == "false" {
                        print("false")
                        
                        if let group = record {
                            
                            print("got group")
                            group["checked"] = "true" as NSString
                            
                            db.save(group, completionHandler: { (record, error) in
                                if error != nil {
                                    print(error!.localizedDescription)
                                } else {
                                    print("group updated")
                                    self.selectedGroups.append(group)
                                    DispatchQueue.main.async {
                                        label.isHidden = false
                                    }
                                }
                            })
                        }
                        
                    } else {
                        print("true")
                        
                        if let group = record {
                            print("got group")
                            group["checked"] = "false" as NSString
                            
                            db.save(group, completionHandler: { (record, error) in
                                if error != nil {
                                    print(error!.localizedDescription)
                                } else {
                                    print("group updated")
                                    if let i = self.selectedGroups.index(of: record!) {
                                        self.selectedGroups.remove(at: i)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        label.isHidden = true
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}




