//
//  EntryListTableViewCell.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/22/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class EntryListTableViewCell: UITableViewCell {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var cellTitle: UILabel!
	@IBOutlet weak var createdDate: UILabel!
	@IBOutlet weak var editedDate: UILabel!
	@IBOutlet weak var cellContent: UILabel!
	@IBOutlet weak var reminderIndicator: UIImageView!
	@IBOutlet weak var photoIndicator: UIImageView!
	@IBOutlet weak var urlIndicator: UIImageView!
	@IBOutlet weak var listIndicator: UIImageView!
	@IBOutlet weak var location: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		if selected {
			self.contentView.backgroundColor = UIColor(red:0.09, green:0.04, blue:0.10, alpha:1.0)
		} else {
			self.contentView.backgroundColor = UIColor(red:0.11, green:0.10, blue:0.17, alpha:1.0)
		}
	}

}
