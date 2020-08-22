//
//  UImage.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import UIKit

enum AssetIdentifier: String {
    case rain = "rain"
    case sun = "sun"
    case smoke = "smoke"
    case snow = "snow"
    case cloud = "cloud"
    case tunderstorm = "tunderstorm"
    case drizzle = "drizzle"
}

extension UIImage {
    convenience init?(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}

