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

    var firstButtonTapped = false
    var secondButtonTapped = false
    var thirdButtonTapped = false
    var fourthButtonTapped = false
    var fifthButtonTapped = false
    var sixthButtonTapped = false
    var seventhButtonTapped = false

    var conditionArray: [Bool] = []
    
    private let key = "key"

    weak var delegate: FilterViewControllerDelegate?

    let services = ["Passenger tire fitting", "Truck tire fitting", "Car maintenance", "Break repair", "Oil change", "Car wash", "Seasonal tire storage"]

    static let cellIdentifier = "cell"

    //MARK: - View did load

    override func viewDidLoad() {
        super.viewDidLoad()

        conditionArray = decode()

        if conditionArray.isEmpty {
            conditionArray = [firstButtonTapped, secondButtonTapped, thirdButtonTapped, fourthButtonTapped, fifthButtonTapped, sixthButtonTapped, seventhButtonTapped]
        }

        tableView.register(CustomCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }

    //MARK: - Encode and Decode

    func encode(type: [Bool]) {
        guard let data = try? JSONEncoder().encode(type) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func decode() -> [Bool] {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return [] }
        guard let conditionsArray = try? JSONDecoder().decode([Bool].self, from: data) else { return [] }

        return conditionsArray
    }

    //MARK: - Choose func

    func acceptFunc() -> Set<ProfServices>  {
        var services: Set<ProfServices> = []

        if firstButtonTapped == true {
            services.insert(.passengerTireFitting)
        }

        if secondButtonTapped == true {
            services.insert(.truckTireFitting)
        }

        if thirdButtonTapped == true {
            services.insert(.carMaintenance)
        }

        if fourthButtonTapped == true {
            services.insert(.breakRepair)
        }

        if fifthButtonTapped == true {
            services.insert(.oilChange)
        }

        if sixthButtonTapped == true {
            services.insert(.carWash)
        }

        if seventhButtonTapped == true {
            services.insert(.seasonalTireStorage)
        }

        return services
    }

    //MARK: - Change button image

    func changeImageForFilterButtonAfterTapped(condition: inout Bool, sender: UIButton) {

        switch condition {
        case false:
            condition.toggle()
            sender.setImage(UIImage(named: "plus"), for: .normal)
        case true:
            condition.toggle()
            sender.setImage(UIImage(named: "minus"), for: .normal)
        }

        conditionArray.remove(at: sender.tag)
        conditionArray.insert(condition, at: sender.tag)
        encode(type: conditionArray)
    }

    //MARK: - Button actions

    @objc func first(_ sender: UIButton) {
        changeImageForFilterButtonAfterTapped(condition: &firstButtonTapped, sender: sender)
    }

    @objc func second(_ sender: UIButton) {
        changeImageForFilterButtonAfterTapped(condition: &secondButtonTapped, sender: sender)
    }

    @objc func third(_ sender: UIButton) {
        changeImageForFilterButtonAfterTapped(condition: &thirdButtonTapped, sender: sender)
    }

    @objc func fourth(_ sender: UIButton) {
        changeImageForFilterButtonAfterTapped(condition: &fourthButtonTapped, sender: sender)
    }

    @objc func fifth(_ sender: UIButton) {
        changeImageForFilterButtonAfterTapped(condition: &fifthButtonTapped, sender: sender)
    }

    @objc func sixth(_ sender: UIButton) {
        changeImageForFilterButtonAfterTapped(condition: &sixthButtonTapped, sender: sender)
    }

    @objc func seventh(_ sender: UIButton) {
        changeImageForFilterButtonAfterTapped(condition: &seventhButtonTapped, sender: sender)
    }

    @IBAction func closeVC(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func accept(_ sender: UIButton) {
        delegate?.filterMap(with: acceptFunc())

        dismiss(animated: true)
    }

    @IBAction func clearAll(_ sender: UIButton) {
        firstButtonTapped = false
        secondButtonTapped = false
        thirdButtonTapped = false
        fourthButtonTapped = false
        fifthButtonTapped = false
        sixthButtonTapped = false
        seventhButtonTapped = false

        let cell = CustomCell()
        cell.button.setImage(UIImage(named: "minus"), for: .normal)
        tableView.reloadData()

        conditionArray = [firstButtonTapped, secondButtonTapped, thirdButtonTapped, fourthButtonTapped, fifthButtonTapped, sixthButtonTapped, seventhButtonTapped]

        encode(type: conditionArray)
        delegate?.filterMap(with: acceptFunc())

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
        
        cell.condition = conditionArray[indexPath.row]
       
        cell.buttonImage(condition: cell.condition, button: cell.button)

        cell.text = services[indexPath.row]

        tableView.rowHeight = 70

        cell.button.tag = indexPath.row

        switch indexPath.row {

        case 0:
            cell.picture.image = UIImage(named: "tyre")
            firstButtonTapped = cell.condition
            cell.button.addTarget(self, action: #selector(first(_:)), for: .primaryActionTriggered)
        case 1:
            cell.picture.image = UIImage(named: "tyre")
            secondButtonTapped = cell.condition
            cell.button.addTarget(self, action: #selector(second(_:)), for: .primaryActionTriggered)

        case 2:
            cell.picture.image = UIImage(named: "suspension")
            thirdButtonTapped = cell.condition
            cell.button.addTarget(self, action: #selector(third(_:)), for: .primaryActionTriggered)

        case 3:
            cell.picture.image = UIImage(named: "break")
            fourthButtonTapped = cell.condition
            cell.button.addTarget(self, action: #selector(fourth(_:)), for: .primaryActionTriggered)

        case 4:
            cell.picture.image = UIImage(named: "oil")
            fifthButtonTapped = cell.condition
            cell.button.addTarget(self, action: #selector(fifth(_:)), for: .primaryActionTriggered)

        case 5:
            cell.picture.image = UIImage(named: "wash")
            sixthButtonTapped = cell.condition
            cell.button.addTarget(self, action: #selector(sixth(_:)), for: .primaryActionTriggered)

        case 6:
            cell.picture.image = UIImage(named: "tyreStorage")
            seventhButtonTapped = cell.condition
            cell.button.addTarget(self, action: #selector(seventh(_:)), for: .primaryActionTriggered)

        default:
            break
        }
        return cell
    }
}

//MARK: - Protocol

protocol FilterViewControllerDelegate: AnyObject {
    func filterMap(with set: Set<ProfServices>)
}
