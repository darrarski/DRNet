//
//  MenuViewController.swift
//  DRNet-Example-iOS
//
//  Created by Dariusz Rybicki on 09/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {
    
    let menu: [MenuSection] = [
        MenuSection(
            title: "Examples",
            items: [
                MenuItem(
                    title: "Example 1",
                    action: { (menuViewController) -> Void in
                        let viewController = Example1ViewController()
                        menuViewController.navigationController?.pushViewController(viewController, animated: true)
                    }
                ),
            ]
        ),
    ]
    
    // MARK: - Menu structure
    
    class MenuSection {
        
        let title: String
        let items: [MenuItem]
        
        init(title: String, items: [MenuItem]) {
            self.title = title
            self.items = items
        }
    }
    
    class MenuItem {
        
        typealias Action = (menuViewController: MenuViewController) -> Void
        
        let title: String
        let action: Action
        
        init(title: String, action: Action) {
            self.title = title
            self.action = action
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "DRNet iOS Examples"
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu[section].items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuItem", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = menu[indexPath.section].items[indexPath.row].title
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menu[section].title
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        menu[indexPath.section].items[indexPath.row].action(menuViewController: self)
    }
    
}
