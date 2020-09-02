//
//  GalleryCollectionViewCell.swift
//  CurrentWeather
//
//  Created by Rusell on 16.08.2020.
//  Copyright © 2020 RusellKh. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    static let reusedId = "GalleryCollectionViewCell"
    //создаем картинку
    let mainImageView: UIImageView = {
        //картинка
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    let nameLabelDown: UILabel = {
        //текст
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameLabelUp: UILabel = {
        //текст
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabelUp)
        addSubview(mainImageView)
        addSubview(nameLabelDown)
        
        //закрепляем констрейнт
        backgroundColor = UIColor.clear
        
        nameLabelUp.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        nameLabelUp.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        nameLabelUp.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        
        mainImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: nameLabelUp.bottomAnchor).isActive = true
        mainImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2).isActive = true
        
        nameLabelDown.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        nameLabelDown.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        nameLabelDown.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 0).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

