//
//  ClockByDayWeather.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

struct ListForData {
    var dt: Int
    var temperature: String
    var conditionCode: String
}

struct ListForDecodableJSON {
    var dt: String
    var temperature: String
    var conditionCode: String
}

struct ClockByDayWeather {
    private var list: [ListForData]
    
    var listStr: [ListForDecodableJSON] {
        var arr = [ListForDecodableJSON]()
        for count in 0..<list.count {
            arr.append(ListForDecodableJSON(dt: datemsToString(from: list[count].dt),
                                    temperature: String(list[count].temperature),
                                    conditionCode: findeIcon(list[count].conditionCode)))
        }
        return arr
    }
    
    init?(clockByDayWeather: ClockByDayWeatherData) {
        
        var list = [ListForData](repeating: ListForData.init(dt: 0, temperature: "", conditionCode: ""), count: 40)
        for count in 0..<clockByDayWeather.list.count {
            list[count].dt = clockByDayWeather.list[count].dt
            list[count].temperature = String(format: "%.0f", clockByDayWeather.list[count].main.temp)
            list[count].conditionCode = String(clockByDayWeather.list[count].weather.first!.id)
        }
        self.list = list
    }
    
    private func findeIcon(_ code: String) -> String {
        guard let codes = Int(code) else { return "" }
        switch codes {
        //thunderstrom-шторм
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
    
    private func datemsToString(from date: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(date))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM HH:mm"
        //dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}

extension Date {
 var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
