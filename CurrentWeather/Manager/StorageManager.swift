//
//  StorageManager.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let cityKey = "City"
    
    func saveCity(with city: Cities) {
        var cities = fetchCities()
        let selectedCities = cities.map { $0.name }
        if !(selectedCities.contains(city.name)) {
            cities.append(city)
            guard let dataCitiy = try? JSONEncoder().encode(cities) else { return }
            userDefaults.set(dataCitiy, forKey: cityKey)
        }
    }
    
    func fetchCities() -> [Cities] {
        guard let dataCity = userDefaults.object(forKey: cityKey) as? Data else { return [] }
        guard let cities = try? JSONDecoder().decode([Cities].self, from: dataCity) else { return [] }
        return cities
    }
    
    func deleteCity(at index: Int) {
        var cities = fetchCities()
        
        cities.remove(at: index)
        guard let dataCitiy = try? JSONEncoder().encode(cities) else { return }
        userDefaults.set(dataCitiy, forKey: cityKey)
    }
    
    func fetchCitiesIdSepareted() -> String {
        guard let dataCity = userDefaults.object(forKey: cityKey) as? Data else { return "" }
        guard let cities = try? JSONDecoder().decode([Cities].self, from: dataCity) else { return "" }
        let selectedCities = cities.map { $0.id }
        return selectedCities.joined(separator: ",")
    }
    
}
