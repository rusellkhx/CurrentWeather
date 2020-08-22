//
//  WeatherId.swift
//  CurrentWeather
//
//  Created by Rusell on 22.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

struct ClockByDayWeatherData2: Codable {
    let list: [List]
    let cnt: Int
}
// MARK: - List
struct List: Codable {
    let coord: Coord2
    let sys: Sys
    let weather: [Weather2]
    let main: Main2
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt, id: Int
    let name: String
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
struct Coord2: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main2: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let country: String
    let timezone, sunrise, sunset: Int
}

// MARK: - Weather
struct Weather2: Codable {
    let id: Int
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}
