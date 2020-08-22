//
//  CitiesGroupByID.swift
//  CurrentWeather
//
//  Created by Rusell on 22.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

struct ListForDataCitiesGroupByID {
    var dt: Int
    var temperature: String
    var name: String
}

struct ListForDataCitiesGroupByID2 {
    var dt: String
    var temperature: String
    var name: String
}

// MARK: - CitiesGroupByID
struct CitiesGroupByID {
    let cnt: Int
    
    private var list: [ListForDataCitiesGroupByID]
    
    var listStr: [ListForDataCitiesGroupByID2] {
        var arr = [ListForDataCitiesGroupByID2]()
        for count in 0..<list.count {
            arr.append(ListForDataCitiesGroupByID2(dt: datemsToString(from: list[count].dt),
                                                   temperature: String(list[count].temperature),
                                                   name: list[count].name))
                                                  
        }
        return arr
    }
    
    
    /*init(from decoder: Decoder) throws {
     let values = try decoder.container(keyedBy: CodingKeys.self)
     
     cnt = (try? values.decodeIfPresent(Int.self, forKey: .cnt))                          ?? 0
     list = (try? values.decodeIfPresent([List].self, forKey: .list))                          ?? []
     }*/
    init?(citiesGroupByID: ClockByDayWeatherData2) {
        
        var list = [ListForDataCitiesGroupByID](repeating: ListForDataCitiesGroupByID.init(dt: 0,
                                                                                           temperature: "",
                                                                                           name: ""),
                                                                                           count: 40)
        for count in 0..<citiesGroupByID.list.count {
            list[count].dt = citiesGroupByID.list[count].dt
            list[count].temperature = String(format: "%.0f", citiesGroupByID.list[count].main.temp)
            list[count].name = String(citiesGroupByID.list[count].name)
        }
        self.cnt = citiesGroupByID.cnt
        self.list = list
        print(citiesGroupByID.list.count)
        
    }
    
    private func datemsToString(from date: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(date))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM HH:mm"
        //dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}



