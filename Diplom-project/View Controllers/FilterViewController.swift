//
//  FilterViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 23.06.22.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButon: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var resetFilterButton: UIButton!
    
    private let key = "key"
    
    weak var delegate: FilterViewControllerDelegate?
    
    var servicesDictionary: Dictionary <ProfServices, Bool> = [:]
    
    static let cellIdentifier = "cell"
    
    //MARK: - View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        
        servicesDictionary = decode()
        
        if servicesDictionary.isEmpty {
            servicesDictionary = Dictionary(uniqueKeysWithValues: zip(ProfServices.allCases, repeatElement(false, count: ProfServices.allCases.count)))
        }
        
        for i in ProfServices.allCases {
            if servicesDictionary[i] == true {
                let index = IndexPath(row: i.rawValue, section: 0)
                tableView.selectRow(at: index, animated: false, scrollPosition: .none)
            }
        }
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }
    
    //MARK: - Encode and Decode
    
    func encode(type: Dictionary <ProfServices, Bool>) {
        guard let data = try? JSONEncoder().encode(type) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func decode() -> Dictionary <ProfServices, Bool> {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return [:] }
        guard let conditionsArray = try? JSONDecoder().decode(Dictionary <ProfServices, Bool>.self, from: data) else { return [:] }
        
        return conditionsArray
    }
    
    //MARK: - Accept func
    
    func filterFunc() -> Set<ProfServices>  {
        var services: Set<ProfServices> = []
        
        for (key, value) in servicesDictionary {
            if value {
                services.insert(key)
            }
        }
        
        return services
    }
    
    //MARK: - Button actions
    
    @IBAction func closeVC(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func acceptFilterFunc(_ sender: UIButton) {
        encode(type: servicesDictionary)
        delegate?.filterMap(with: filterFunc())
        dismiss(animated: true)
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        for (key, value) in servicesDictionary {
            if value {
                servicesDictionary[key] = false
            }
        }
        encode(type: servicesDictionary)
        
        delegate?.filterMap(with: filterFunc())
        
        dismiss(animated: true)
    }
}

//MARK: - Table view

extension FilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfServices.allCases.count
    }
}

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as? CustomCell else { return UITableViewCell() }
        
        let services = ProfServices.allCases[indexPath.row]
        
        cell.text = services.title
        
        cell.picture.image = UIImage(named: services.image)
        
        tableView.rowHeight = 70
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentService = ProfServices.allCases[indexPath.row]
        servicesDictionary[currentService] = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentService = ProfServices.allCases[indexPath.row]
        servicesDictionary[currentService] = false
    }
}

//MARK: - Protocol

protocol FilterViewControllerDelegate: AnyObject {
    func filterMap(with set: Set<ProfServices>)
}
