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
    
    var place: Places!
    
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
    
    @IBAction func heartButtonTapped(_ sender: UIButton) {
        place.favoriteStatus.toggle()
        
        if place.favoriteStatus {
            sender.setImage(UIImage(named: "heartRed"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "heartClear"), for: .normal)
        }
        print(place.favoriteStatus)
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
        
        if place == nil || place.favoriteStatus == false {
            heartButton.setImage(UIImage(named: "heartClear"), for: .normal)
        } else {
            heartButton.setImage(UIImage(named: "heartRed"), for: .normal)
        }
    }
    
    func fetchPlaces() -> [Places] {
        guard let data = UserDefaults.standard.object(forKey: "place") as? Data else { return [] }
        guard let places = try? JSONDecoder().decode([Places].self, from: data) else { return [] }
        
        return places
    }
    
    func change(index: Int) {
        var places = fetchPlaces()
        
        var place = places.remove(at: index)
        
        place.favoriteStatus.toggle()
        
        places.insert(place, at: index)
        
        guard let data = try? JSONEncoder().encode(places) else { return }
        UserDefaults.standard.set(data, forKey: "place")
    }
}
