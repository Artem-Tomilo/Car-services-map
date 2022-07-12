//
//  HorisontalCustomCellForCollectionView.swift
//  Diplom-project
//
//  Created by Артем Томило on 7.07.22.
//

import UIKit
import GooglePlaces

class HorisontalCustomCellForCollectionView: UICollectionViewCell {
    
    let firstImage = UIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setup() {
        contentView.addSubview(firstImage)
        
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            firstImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            firstImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            firstImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
