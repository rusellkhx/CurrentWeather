//
//  StructModelCitiesID.swift
//  CurrentWeather
//
//  Created by Rusell on 22.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

struct CurrentModelCitiesID {
    var dt: String
    var temp: String
    var name: String
    
    static func fetchCurrentWeather(_ lists: CitiesGroupByID) -> [CurrentModelCitiesID] {
        
        var DataCurrentModel = [CurrentModelCitiesID]()
        for count in 0..<lists.listStr.count {
            DataCurrentModel.append(CurrentModelCitiesID(dt: String(lists.listStr[count].dt),
                                                         temp: lists.listStr[count].temperature,
                                                         name: lists.listStr[count].name))
        }
        return DataCurrentModel
    }
}
