//
//  StandingsCell.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 6/28/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import UIKit
import Foundation

class StandingsCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var overallRecordLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var week1RecordLabel: UILabel!
    @IBOutlet weak var week2RecordLabel: UILabel!
    @IBOutlet weak var week3RecordLabel: UILabel!
    @IBOutlet weak var week4RecordLabel: UILabel!

    func configureCell(_ standing: Standing) {
        nameLabel.text = "\(standing.firstName) \(standing.lastName)"
        overallRecordLabel.text = standing.overallRecord
        cityNameLabel.text = standing.office
        rankingLabel.text = standing.ranking
        week1RecordLabel.text = standing.week1Record
        week2RecordLabel.text = standing.week2Record
        week3RecordLabel.text = standing.week3Record
        week4RecordLabel.text = standing.week4Record

        layer.cornerRadius = 8
    }
}
