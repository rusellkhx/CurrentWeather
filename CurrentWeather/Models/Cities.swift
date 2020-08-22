//
//  Cities.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation

struct Cities: Codable {
    let name: String
    let temperature: String
    let id: String
    let dt: String

    init(name: String, temperature: String, id: String, dt: String) {
        self.name = name
        self.temperature = temperature
        self.id = id
        self.dt = dt
    }
}


