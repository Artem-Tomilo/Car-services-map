//
//  CustomCell.swift
//  Diplom-project
//
//  Created by Артем Томило on 23.06.22.
//

import UIKit

class CustomCell: UITableViewCell {
    
    private let label = UILabel(frame: .zero)
    var picture = UIImageView(frame: .zero)
    private let condition = UIImageView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        text = ""
    }
    
    private func setup() {
        
        contentView.addSubview(label)
        contentView.addSubview(picture)
        contentView.addSubview(condition)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        picture.translatesAutoresizingMaskIntoConstraints = false
        condition.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            picture.widthAnchor.constraint(equalToConstant: 50),
            picture.heightAnchor.constraint(equalToConstant: 50),
            picture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            picture.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            condition.widthAnchor.constraint(equalToConstant: 30),
            condition.heightAnchor.constraint(equalToConstant: 30),
            condition.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            condition.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            condition.image = UIImage(named: "accept")
            contentView.backgroundColor = .green
        } else {
            condition.image = UIImage(named: "noAccept")
            contentView.backgroundColor = .white
        }
    }
}
