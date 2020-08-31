//
//  ViewController.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import UIKit
import CoreLocation
//import Firebase
import GooglePlaces
import AAInfographics
class ViewController: UIViewController {
    
    // MARK: - User property
    //var ref: DatabaseReference!
    var networkWeatherManager = NetworkWeatherManager()
    var units: String = "metric" //по умолчанию градусы цельсия
    var city: String = ""
    let chartView = AAChartView()
    
    private var idCities = ""
    private var citiesID: [CurrentModelCitiesID]?
    // MARK: - IBOutlet property
    @IBOutlet weak var dtLabel: UILabel!
    @IBOutlet weak var backgroungUIImageView: UIImageView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var presureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var getCityGoogle: UIButton!
    @IBOutlet weak var keySC: UISegmentedControl!
    @IBOutlet weak var typeUnits: UILabel!
    @IBOutlet weak var dtTime: UILabel!
    //@IBOutlet weak var chartView: AAChartView!
    
    
    // MARK: - User private/computed property
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self //объявили себя делегатом
        lm.desiredAccuracy = kCLLocationAccuracyKilometer //точность определения местоположения
        lm.requestWhenInUseAuthorization() //запрос на разрешение определения местоположения у пользователя
        return lm
    } ()
    
    private var galleryCollectionView = GalleryCollectionView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueCities" {
            if let citiesTableViewController = segue.destination as? CitiesTableViewController {
                citiesTableViewController.citiesID = self.citiesID
            }
        }
    }
    // MARK: - IBActions
    @IBAction func searchPressed(_ sender: UIButton) {
        self.presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert) { [unowned self] city in
            
            self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: city, units: self.units))
            self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityNameMoreInfo(city: city, units: self.units))
        }
    }
    
    @IBAction func selectedSC(_ sender: UISegmentedControl) {
        units = keySC.selectedSegmentIndex == 0 ? "metric" : "imperial"
        self.typeUnits.text = keySC.selectedSegmentIndex == 0 ? "°C" : "°F"
        self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: self.cityLabel.text!, units: self.units))
    }
    
    @IBAction func takeCitiesByID(_ sender: Any) {
        
    }
    // MARK: -  @objc
    // Present the Autocomplete view controller when the button is pressed.
    @objc func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    // MARK: - Methods
    func createChartModel(data: ClockByDayWeather) {
        let aaChartModel = AAChartModel()
            .chartType(.line)
            //.animationType(.bounce)
            .stacking(.normal)
            .markerSymbol(.circle)
            .title("TITLE")//The chart title
            //.subtitle("subtitle")//The chart subtitle
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
            .tooltipValueSuffix("°")//the value suffix of the chart tooltip
            .categories(
                [data.listStr[0].dt,
                data.listStr[1].dt,
                data.listStr[2].dt,
                data.listStr[3].dt,
                data.listStr[4].dt,
                data.listStr[5].dt,
                data.listStr[6].dt,
                data.listStr[7].dt,
                data.listStr[8].dt,
                data.listStr[9].dt,
                data.listStr[10].dt]
        )
            .series([
                AASeriesElement()
                    .name("city")
                    .data([Int(data.listStr[0].dt) ?? 0,
                           Int(data.listStr[1].dt) ?? 0,
                           Int(data.listStr[2].dt) ?? 0,
                           Int(data.listStr[3].dt) ?? 0,
                           Int(data.listStr[4].dt) ?? 0,
                           Int(data.listStr[5].dt) ?? 0,
                           Int(data.listStr[6].dt) ?? 0,
                           Int(data.listStr[7].dt) ?? 0,
                           Int(data.listStr[8].dt) ?? 0,
                           Int(data.listStr[9].dt) ?? 0,
                           Int(data.listStr[10].dt) ?? 0])
            ])
        
        chartView.aa_drawChartWithChartModel(aaChartModel)
    }
    
    func updateView() {
        networkWeatherManager.onCompletionCurrentWeather = { [weak self] currentWeather in
            guard let self = self else { return }
            self.updateInterfaceWithCurrentWeather(weather: currentWeather)
        }
        networkWeatherManager.onCompletionClockByDayWeather = { [weak self] clockByDayWeather in
            guard let self = self else { return }
            self.updateInterfaceWithClockByDayWeather(weather: clockByDayWeather)
        }
        
        networkWeatherManager.onCompletionCitiesGroupByID = { [weak self] citiesGroupByID in
            guard let self = self else { return }
            self.updateInterfaceWithCitiesGroupByID(weather: citiesGroupByID)
        }
        
        // проверка включенности определения местоположения
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
        
        view.addSubview(galleryCollectionView)
        galleryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        galleryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        galleryCollectionView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 120).isActive = true
        galleryCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        galleryCollectionView.isHidden = true
        
        getCityGoogle.backgroundColor = .clear
        getCityGoogle.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        getCityGoogle.setTitle("", for: .normal)
        getCityGoogle.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
        self.view.addSubview(getCityGoogle)
        
        let chartViewWidth  = self.view.frame.size.width
        let chartViewHeight = 100
        
        chartView.frame = CGRect(x:0,y:420,width:Int(chartViewWidth),height:chartViewHeight)
        chartView.tintColor = .none
        self.view.addSubview(chartView)
        
        chartView.isClearBackgroundColor = true
        chartView.isHidden = true
    }
    
    func updateInterfaceWithCurrentWeather(weather: CurrentWeather) {
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            DispatchQueue.main.async {
                self.cityLabel.text = weather.cityName
                self.temperatureLabel.text = weather.temperatureString
                self.feelsLikeTemperatureLabel.text = weather.feelsLikeTemperatureString
                self.weatherIconImageView.image = UIImage(systemName: weather.systemIconNameString)
                self.presureLabel.text = weather.pressureString
                self.humidityLabel.text = weather.humidityString
                self.backgroungUIImageView.image = self.changeBackground(weather.systemIconNameString)
                self.dtLabel.text = weather.dtString
                self.dtTime.text = weather.dtStringHourMinute
                
                let citySave = Cities(name: weather.cityName,
                                      temperature: weather.temperatureString,
                                      id: weather.idString,
                                      dt: weather.dtStringHourMinute)
                StorageManager.shared.saveCity(with: citySave)
                self.idCities = StorageManager.shared.fetchCitiesIdSepareted()
                print(self.idCities)
                self.networkWeatherManager.fetchCurrentWeather(forRequestType: .citiesGroupByIDgroup(idCities: self.idCities, units: self.units))
            }
        }
    }
    
    func updateInterfaceWithClockByDayWeather(weather: ClockByDayWeather) {
        let queue = DispatchQueue.global(qos: .default)
        queue.async {
            DispatchQueue.main.async {
                
                self.galleryCollectionView.set(cells: CurrentModel.fetchCurrentWeather(weather))
                self.galleryCollectionView.isHidden = false
                self.galleryCollectionView.reloadData()
                
                self.createChartModel(data: weather)
                self.chartView.isHidden = false
            }
        }
    }
    
    func changeBackground(_ code: String) -> UIImage {
        switch code {
        case "cloud.bolt.rain.fill": return UIImage(assetIdentifier: .tunderstorm)!
        case "cloud.drizzle.fill": return UIImage(assetIdentifier: .drizzle)!
        case "cloud.rain.fill": return UIImage(assetIdentifier: .rain)!
        case "cloud.snow.fill": return UIImage(assetIdentifier: .snow)!
        case "smoke.fill": return UIImage(assetIdentifier: .smoke)!
        case "sun.min.fill": return UIImage(assetIdentifier: .sun)!
        case "cloud.fill": return UIImage(assetIdentifier: .cloud)!
        default: return UIImage(assetIdentifier: .sun)!
        }
    }
    
    func updateInterfaceWithCitiesGroupByID(weather: CitiesGroupByID) {
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            DispatchQueue.main.async {
                self.citiesID = CurrentModelCitiesID.fetchCurrentWeather(weather)
            }
        }
    }
}

// MARK: - Extensions, Protocols
extension ViewController: CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return self.showAlert(with: "Ошибка!", and: "Нет данных по координатам") }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        networkWeatherManager.fetchCurrentWeather(forRequestType: .coordinate(latitude: latitude, longititude: longitude, units: self.units))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showAlert(with: "Ошибка!", and: "Нет данных по координатам")
        print(error.localizedDescription)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let city = place.name {
            self.city = city
        }
        
        self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: self.city, units: self.units))
        self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityNameMoreInfo(city: self.city, units: self.units))
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}


