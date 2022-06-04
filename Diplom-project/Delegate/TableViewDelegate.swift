//
//  TableViewDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import UIKit

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listTableViewMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "table-cell", for: indexPath)
        cell.backgroundColor = .clear
        var configuration = cell.defaultContentConfiguration()
        configuration.text = listTableViewMenu[indexPath.row]
        configuration.textProperties.alignment = .center
        cell.contentConfiguration = configuration
        tableView.separatorStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    75
    }
    
    
}
