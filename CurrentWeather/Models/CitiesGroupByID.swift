//
//  CitiesGroupByID.swift
//  CurrentWeather
//
//  Created by Rusell on 22.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

struct ListForDecodableJSONcitiesGroupByID {
    var dt: Int
    var temperature: String
    var name: String
    
    var dtStr: String {
        return datemsToString(from: dt)
    }
    
    init(dt: Int, temperature: String, name: String) {
        self.dt = dt
        self.temperature = temperature
        self.name = name
    }
    
    private func datemsToString(from date: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(date))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM HH:mm"
        //dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }

}

import Foundation

// MARK: - CitiesGroupByID
struct CitiesGroupByID {
    let cnt: Int
    
    let list: [ListForDecodableJSONcitiesGroupByID]

    init?(citiesGroupByID: ClockByDayWeatherData2) {
        var list2 = [ListForDecodableJSONcitiesGroupByID]()
        for city in 0..<citiesGroupByID.list.count{
            list2.append(ListForDecodableJSONcitiesGroupByID(dt: citiesGroupByID.list[city].dt,
                                                             temperature: String(format: "%.0f", citiesGroupByID.list[city].main.temp),
                                                             name: citiesGroupByID.list[city].name))
        }
        self.list = list2
        self.cnt = citiesGroupByID.cnt
    }
}



