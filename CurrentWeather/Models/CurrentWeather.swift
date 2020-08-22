//
//  CurrentWeather.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

struct CurrentWeather {
    let cityName: String
    
    private let id: Int
    private let temperature: Double
    private let feelsLikeTemperature: Double
    private let pressure, humidity: Int
    private let conditionCode: Int //обновление иконки
    private let dt: Int
    private let timezone: Int
    
    var temperatureString: String {
        return String(format: "%.0f", temperature)
    }
    
    var feelsLikeTemperatureString: String {
        return String(format: "%.0f", feelsLikeTemperature)
    }
    
    var pressureString: String {
        return String(pressure)
    }
    var humidityString: String {
        return String(humidity)
    }
    
    var dtString: String {
        datemsToString(dt: dt, timezone: timezone, dateFormat: "MMM d, yyyy")
    }
    
    var dtStringHourMinute: String {
        datemsToString(dt: dt, timezone: timezone, dateFormat: "HH:mm")
    }
    
    var idString: String {
        return String(id)
    }
    
    var systemIconNameString: String {
        switch conditionCode {
        case 200...232: return "cloud.bolt.rain.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...521: return "cloud.rain.fill"
        case 600...622: return "cloud.snow.fill"
        case 701...781: return "smoke.fill"
        case 800: return "sun.min.fill"
        case 801...804: return "cloud.fill"
        default: return "nosign"
        }
    }
    
    init?(currentWeatherData: CurrentWeatherData) {
        cityName = currentWeatherData.name
        temperature = currentWeatherData.main.temp
        feelsLikeTemperature = currentWeatherData.main.feels_like
        conditionCode = currentWeatherData.weather.first!.id
        pressure = currentWeatherData.main.pressure
        humidity = currentWeatherData.main.humidity
        dt = currentWeatherData.dt
        timezone = currentWeatherData.timezone
        id = currentWeatherData.id
    }
    
    private func datemsToString(dt: Int, timezone: Int, dateFormat: String) -> String {
        let date = Date(timeIntervalSince1970: Double(dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone =  TimeZone(secondsFromGMT: timezone)
        return dateFormatter.string(from: date)
    }
}
