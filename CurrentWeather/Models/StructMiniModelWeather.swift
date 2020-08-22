//
//  StructMiniModelWeather.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import Foundation
import UIKit

struct CurrentModel {
    var mainImage: UIImage
    var hourSmallIcon: String
    var tempSmallIcon: String
    
    static func fetchCurrentWeather(_ lists: ClockByDayWeather) -> [CurrentModel] {
        
        var DataCurrentModel = [CurrentModel]()
        for count in 0..<lists.listStr.count {
            DataCurrentModel.append(CurrentModel(mainImage: UIImage(systemName: lists.listStr[count].conditionCode)!,
                                                 hourSmallIcon: String(lists.listStr[count].dt),
                                                 tempSmallIcon: lists.listStr[count].temperature))
            
        }
        return DataCurrentModel
    }
}

struct Constants {
    static let leftDistanceToView: CGFloat = 3
    static let rightDistanceToView: CGFloat = 3
    static let galleryMinimumLineSpacing: CGFloat = 12
    //вычисление ширины ячейки
    static let galleryItemWidth = (UIScreen.main.bounds.width - Constants.leftDistanceToView - Constants.rightDistanceToView - (Constants.galleryMinimumLineSpacing / 3)) / 3
}


