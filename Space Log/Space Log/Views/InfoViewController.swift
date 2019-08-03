//
//  InfoViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 8/3/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	@IBAction func privacyPolicyTapped(_ sender: UIButton) {
		guard let url = URL(string: "http://kduncan-welke.com/spacelogprivacy.php") else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
}
