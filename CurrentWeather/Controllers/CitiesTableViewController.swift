//
//  CitiesTableViewController.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import UIKit

class CitiesTableViewController: UITableViewController {
    
    var networkWeatherManager = NetworkWeatherManager()
    var citiesID: [ListForDataCitiesGroupByID2]!
    private var cities: [Cities] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableFooterView?.isHidden = true
        cities = StorageManager.shared.fetchCities()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count//citiesID.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCities", for: indexPath) as! CitiesTableViewCell
        let city = cities[indexPath.row]
        cell.cityLabel.text = city.name
        cell.tempInCity.text = city.temperature
        cell.timeLabel.text = city.dt
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            StorageManager.shared.deleteCity(at: indexPath.row)
        }
    }
    
    @IBAction func didTapBackButton(_ sender: AnyObject) {
        // if you use navigation controller, just pop ViewController:
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
            print("убили secondView")
        } else {
            // otherwise, dismiss it
            dismiss(animated: true, completion: nil)
        }
    }
}
