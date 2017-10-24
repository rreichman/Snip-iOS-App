//
//  TableViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/23/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    let shoppingList = ["Bread", "Milk", "Eggs", "Honey", "Veggies", "fdsajfdasjkjdfshhjksdfkadfshjkdsfajkhfdsajfdasjkjdfshhjksdfkadfshjkdsfajkhfdsajfdasjkjdfshhjksdfkadfshjkdsfajkh"]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return(shoppingList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("in table view")
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = shoppingList[indexPath.row]
        
        return(cell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("table view has loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
