//
//  MarkerInfoView.swift
//  Diplom-project
//
//  Created by Артем Томило on 15.06.22.
//

import UIKit

class MarkerInfoView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionButton: UIButton!
    
    weak var delegate: MarkerInfoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        nameLabel.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        nameLabel.layer.borderWidth = 0.5
        
        addressLabel.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        addressLabel.layer.borderWidth = 0.5
        
        telLabel.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        telLabel.layer.borderWidth = 0.5
        
        ratingLabel.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        ratingLabel.layer.borderWidth = 0.5
        
        webLabel.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        webLabel.layer.borderWidth = 0.5
        
        distanceLabel.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        distanceLabel.layer.borderWidth = 0.5
    }
    
    @IBAction func heartButtonTapped(_ sender: UIButton) {
        delegate?.favoritesPlaces(sender)
    }
    
    @IBAction func directionButtonTapped(_ sender: UIButton) {
        delegate?.getDirections()
    }
}

protocol MarkerInfoViewDelegate: AnyObject {
    func favoritesPlaces(_ sender: UIButton)
    func getDirections()
}
