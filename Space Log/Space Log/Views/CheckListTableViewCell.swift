//
//  CheckListTableViewCell.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 6/21/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class CheckListTableViewCell: UITableViewCell {

	// MARK: IBOutlets
	
	@IBOutlet weak var cellTitle: UILabel!
	@IBOutlet weak var cellCheck: UIButton!
	
	weak var cellDelegate: CellCheckDelegate?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	// MARK: IBActions
	
	@IBAction func checkTapped(_ sender: UIButton) {
		var isChecked = false
		
		if sender.imageView?.image == UIImage(named: "unchecked") {
			sender.setImage(UIImage(named: "checked"), for: .normal)
			isChecked = true
		} else if cellCheck.imageView?.image == UIImage(named: "checked") {
			sender.setImage(UIImage(named: "unchecked"), for: .normal)
			isChecked = false
		}
		
		self.cellDelegate?.didChangeSelectedState(sender: self, isChecked: isChecked)
	}
}
