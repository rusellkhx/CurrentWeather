//
//  NetworkWeatherManager.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation
import CoreLocation

class NetworkWeatherManager {
    
    static let shared = NetworkWeatherManager()

    private init() {}
    
    enum RequestType {
        case cityName(city: String, units: String)
        case coordinate(latitude: CLLocationDegrees, longititude: CLLocationDegrees, units: String)
        case cityNameMoreInfo(city: String, units: String)
        case citiesGroupByIDgroup(idCities: String, units: String)
    }
    
    func fetchCurrentWeather(forRequestType requestType: RequestType) -> String {
        let urlString: String
        switch requestType {
        case .cityName(let city, let units):
            urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=\(units)"
            return urlString
        
        case .coordinate(let latitude, let longitude, let units):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"
            return urlString
        
        case .cityNameMoreInfo(let city, let units):
            urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=\(units)"
            return urlString
        
        case .citiesGroupByIDgroup(let idCities, let units):
            urlString = "https://api.openweathermap.org/data/2.5/group?id=\(idCities)&appid=\(apiKey)&units=\(units)"
            return urlString
        
        }
    }
    
    func performReqestWeather(urlString: RequestType,
                              completionHandlerWeather: @escaping(CurrentWeather?, Error?) -> Void) {
        
        let urlExample = fetchCurrentWeather(forRequestType: urlString)
        guard let url = URL(string: urlExample) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
                let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
                guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else { return }
                completionHandlerWeather(currentWeather, nil)
            } catch let error as NSError {
                completionHandlerWeather(nil, error)
            }
        }.resume()
    }
    
    func performReqestWeatherCitiesGroupByID(urlString: RequestType,
                                             completionHandlerWeather: @escaping(CitiesGroupByID?, Error?) -> Void) {
        
        let urlExample = fetchCurrentWeather(forRequestType: urlString)
        guard let url = URL(string: urlExample) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
                let citiesGroupByIDData = try decoder.decode(ClockByDayWeatherData2.self, from: data)
                guard let citiesGroupByID = CitiesGroupByID(citiesGroupByID: citiesGroupByIDData) else { return }
                completionHandlerWeather(citiesGroupByID, nil)
            } catch let error as NSError {
                completionHandlerWeather(nil, error)
            }
        }.resume()
    }
    
    func performReqestForecast(urlString: RequestType,
                               completionHandlerWeather: @escaping(ClockByDayWeather?, Error?) -> Void) {
        
        let urlExample = fetchCurrentWeather(forRequestType: urlString)
        guard let url = URL(string: urlExample) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
                let clockByDayWeatherData = try decoder.decode(ClockByDayWeatherData.self, from: data)
                guard let clockByDayWeather = ClockByDayWeather(clockByDayWeather: clockByDayWeatherData) else { return }
                completionHandlerWeather(clockByDayWeather, nil)
            } catch let error as NSError {
                completionHandlerWeather(nil, error)
            }
        }.resume()
    }
}


