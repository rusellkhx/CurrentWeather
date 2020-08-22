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

class ViewController: UIViewController {
    
    // MARK: - User property
    //var ref: DatabaseReference!
    var networkWeatherManager = NetworkWeatherManager()
    var units: String = "metric" //по умолчанию градусы цельсия
    var city: String = ""
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @IBAction func tappedCities(_ sender: Any) {
        guard cityLabel.text != nil
        else {
            showAlert(with: "Error",
                      and: "No connection with Firebase")
            return
        }
        performSegue(withIdentifier: "SegueCities", sender: nil)
    }
    // MARK: -  @objc
    // Present the Autocomplete view controller when the button is pressed.
    @objc func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    // MARK: - Methods
    func updateView() {
        networkWeatherManager.onCompletionCurrentWeather = { [weak self] currentWeather in
            guard let self = self else { return }
            self.updateInterfaceWithCurrentWeather(weather: currentWeather)
        }
        networkWeatherManager.onCompletionClockByDayWeather = { [weak self] clockByDayWeather in
            guard let self = self else { return }
            self.updateInterfaceWithClockByDayWeather(weather: clockByDayWeather)
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
        //ref = FirebaseDatabase.Database.database().reference(withPath: "cities").child("city")
        
        getCityGoogle.backgroundColor = .clear
        getCityGoogle.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        getCityGoogle.setTitle("", for: .normal)
        getCityGoogle.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
        self.view.addSubview(getCityGoogle)
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
                //print(citySave)
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
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let city = place.name {
            self.city = city
        }
        
        self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: self.city, units: self.units))
        self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityNameMoreInfo(city: self.city, units: self.units))

        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    /*func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }*/
    
}


