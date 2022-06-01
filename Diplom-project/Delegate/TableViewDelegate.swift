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
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "table-cell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = "Hello World!"
        cell.contentConfiguration = configuration
        return cell
    }
    
    
}
