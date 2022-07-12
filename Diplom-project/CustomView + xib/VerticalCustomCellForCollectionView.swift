//
//  VerticalCustomCellForCollectionView.swift
//  Diplom-project
//
//  Created by Артем Томило on 7.07.22.
//

import UIKit

class VerticalCustomCellForCollectionView: UICollectionViewCell {
    
    let firstImage = UIImageView(frame: .zero)
    private let nameLabel = UILabel(frame: .zero)
    private let adressLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameText = ""
        adressText = ""
    }
    
    func setup() {
        
        contentView.addSubview(firstImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(adressLabel)
        
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        adressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: firstImage.leadingAnchor, constant: -10),
            nameLabel.heightAnchor.constraint(equalToConstant: 30),
            
            adressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            adressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            adressLabel.trailingAnchor.constraint(equalTo: firstImage.leadingAnchor, constant: -10),
            adressLabel.heightAnchor.constraint(equalToConstant: 30),
            
            firstImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            firstImage.heightAnchor.constraint(equalToConstant: 50),
            firstImage.widthAnchor.constraint(equalToConstant: 50),
            firstImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        adressLabel.numberOfLines = 0
        contentView.backgroundColor = .yellow
    }
    
    var nameText: String = "" {
        didSet {
            nameLabel.text = nameText
        }
    }
    
    var adressText: String = "" {
        didSet {
            adressLabel.text = adressText
        }
    }
}
