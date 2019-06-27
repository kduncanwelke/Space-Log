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
	@IBOutlet weak var iconIndicator: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
