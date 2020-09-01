//
//  ViewController.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

class ViewController: UIViewController {
    // MARK: - User properties
    var networkWeatherManager = NetworkWeatherManager()
    var units: String = "metric" //по умолчанию градусы цельсия
    var city: String = ""
    
    private var idCities = ""
    private var citiesID: [CurrentModelCitiesID]?
    private var galleryCollectionView = GalleryCollectionView()
    // MARK: - IBOutlet properties
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

    // MARK: - User private/computed properties
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self //объявили себя делегатом
        lm.desiredAccuracy = kCLLocationAccuracyKilometer //точность определения местоположения
        lm.requestWhenInUseAuthorization() //запрос на разрешение определения местоположения у пользователя
        return lm
    } ()
    // MARK: - override metods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
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
    
    private func updateView() {
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
   }
    
    private func updateInterfaceWithCurrentWeather(weather: CurrentWeather) {
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
                self.networkWeatherManager.fetchCurrentWeather(forRequestType: .citiesGroupByIDgroup(idCities: self.idCities, units: self.units))
            }
        }
    }
    
    private func updateInterfaceWithClockByDayWeather(weather: ClockByDayWeather) {
        let queue = DispatchQueue.global(qos: .default)
        queue.async {
            DispatchQueue.main.async {
                
                self.galleryCollectionView.set(cells: CurrentModel.fetchCurrentWeather(weather))
                self.galleryCollectionView.isHidden = false
                self.galleryCollectionView.reloadData()
            }
        }
    }
    
    private func changeBackground(_ code: String) -> UIImage {
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
    
    private func updateInterfaceWithCitiesGroupByID(weather: CitiesGroupByID) {
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

extension ViewController: SegueHandler {
    
    enum SegueIdentifier: String {
        case signIn, signUp
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .signIn:
            if let citiesTableViewController = segue.destination as? CitiesTableViewController {
                citiesTableViewController.citiesID = self.citiesID
            }
        case .signUp:
            print("signUp")
        }
    }
}

extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {

    func performSegue(withIdentifier segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }

    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, let identifierCase = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(String(describing: segue.identifier)).")
        }
        return identifierCase
    }
}
