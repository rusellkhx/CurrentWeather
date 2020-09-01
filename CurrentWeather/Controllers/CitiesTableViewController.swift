//
//  CitiesTableViewController.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import UIKit
import AAInfographics

class CitiesTableViewController: UITableViewController {
    
    let chartView = AAChartView()
    var networkWeatherManager = NetworkWeatherManager()
    var citiesID: [CurrentModelCitiesID]!
    
    private var cities: [Cities] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableFooterView?.isHidden = true
        
        createChartView()
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return citiesID.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CitiesTableViewCell.self),
                                                 for: indexPath) as! CitiesTableViewCell
        let city = citiesID[indexPath.row]
        cell.cityLabel.text = city.name
        cell.tempInCity.text = city.temp
        cell.timeLabel.text = city.dt
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            citiesID.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            StorageManager.shared.deleteCity(at: indexPath.row)
            createChartModel(data: citiesID)
        }
    }
    
    @IBAction func didTapBackButton(_ sender: AnyObject) {
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
            //print("убили secondView")
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - extension CitiesTableViewController
extension CitiesTableViewController {
    private func createChartView() {
        let chartViewWidth  = self.view.frame.size.width
        let chartViewHeight = 250
        
        chartView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: Int(chartViewWidth),
                                 height: chartViewHeight)
        
        chartView.tintColor = .clear
        self.view.addSubview(chartView)
        chartView.isClearBackgroundColor = true
        createChartModel(data: citiesID)
    }
    
    private func createChartModel(data: [CurrentModelCitiesID]) {
        var temp = [Int]()
        var name = [String]()
        for item in 0..<data.count {
            temp.append(Int(data[item].temp) ?? 0)
            name.append(data[item].name)
        }
        
            let aaChartModel = AAChartModel()
                .chartType(.line)
                .animationType(.easeFrom)
                .stacking(.normal)
                .markerSymbol(.circle)
                .dataLabelsEnabled(true)
                .tooltipValueSuffix("°")
                .categories(name)
                .colorsTheme(["#ffffff"])
                .series([
                    AASeriesElement()
                        .name("All cities")
                        .data(temp)])
            chartView.aa_drawChartWithChartModel(aaChartModel)
    }
}

