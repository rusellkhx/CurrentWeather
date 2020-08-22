//
//  CurrentWeatherData.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

struct CurrentWeatherData: Codable {
    let name: String
    let id: Int
    let main: Main
    let weather: [Weather]
    let dt: Int
    let timezone: Int
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    
    enum Codingkeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case pressure, humidity
    }
}

struct Weather: Codable {
    let id: Int
}
