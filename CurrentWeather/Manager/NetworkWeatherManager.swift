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
    
    enum RequestType {
        case cityName(city: String, units: String)
        case coordinate(latitude: CLLocationDegrees, longititude: CLLocationDegrees, units: String)
        case cityNameMoreInfo(city: String, units: String)
        case citiesGroupByIDgroup(idCities: String, units: String)
    }
    
    var onCompletionCurrentWeather: ((CurrentWeather) -> Void)?
    var onCompletionClockByDayWeather: ((ClockByDayWeather) -> Void)?
    var onCompletionCitiesGroupByID: ((CitiesGroupByID) -> Void)?
    
    func fetchCurrentWeather(forRequestType requestType: RequestType) {
        var urlString = " "
        
        switch requestType {
        case .cityName(let city, let units):
            urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=\(units)"
            performReqestWeather(withURLString: urlString)
        case .coordinate(let latitude, let longitude, let units):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"
            performReqestWeather(withURLString: urlString)
        case .cityNameMoreInfo(let city, let units):
             urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=\(units)"
            performReqestForecast(withURLString: urlString)
        case .citiesGroupByIDgroup(let idCities, let units):
            urlString = "https://api.openweathermap.org/data/2.5/group?id=\(idCities)&appid=\(apiKey)&units=\(units)"
            performReqestWeatherCitiesGroupByID(withURLString: urlString)
        }
        
    }

    fileprivate func performReqestWeather(withURLString urlString: String) {
        guard let url = URL(string: urlString) else { return }
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let currentWeather = self.parseJSON(withData: data) {
                        self.onCompletionCurrentWeather?(currentWeather)
                    }
                }
            }
            task.resume()
    }
    
    fileprivate func performReqestWeatherCitiesGroupByID(withURLString urlString: String) {
        guard let url = URL(string: urlString) else { return }
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let data = data {
                    //let dataStr = String(data: data, encoding: .utf8)
                    if let citiesGroupByID = self.parseJSONCitiesGroupByID(withData: data) {
                        self.onCompletionCitiesGroupByID?(citiesGroupByID)
                    }
                }
            }
            task.resume()
    }
    
    fileprivate func performReqestForecast(withURLString urlString: String) {
            guard let url = URL(string: urlString) else { return }
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let clockByDayWeather = self.parseJSON_2(withData: data) {
                        self.onCompletionClockByDayWeather?(clockByDayWeather)
                    }
                }
            }
            task.resume()
    }
    
    fileprivate func parseJSON(withData data: Data) -> CurrentWeather? {
        let decoder = JSONDecoder()
        do {
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            return currentWeather
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    fileprivate func parseJSON_2(withData data: Data) -> ClockByDayWeather? {
        let decoder = JSONDecoder()
        do {
            let clockByDayWeatherData = try decoder.decode(ClockByDayWeatherData.self, from: data)
            guard let clockByDayWeather = ClockByDayWeather(clockByDayWeather: clockByDayWeatherData) else {
                return nil
            }
            return clockByDayWeather
            
        } catch let error as NSError {
                    print(error.localizedDescription)
        }
        return nil
    }
    
    fileprivate func parseJSONCitiesGroupByID(withData data: Data) -> CitiesGroupByID? {
        let decoder = JSONDecoder()
        do {
            let citiesGroupByIDdata = try decoder.decode(ClockByDayWeatherData2.self, from: data)
            guard let citiesGroupByID = CitiesGroupByID(citiesGroupByID: citiesGroupByIDdata) else {
                return nil
            }
            return citiesGroupByID
            
        } catch let error as NSError {
                    print(error.localizedDescription)
        }
        return nil
    }
}
