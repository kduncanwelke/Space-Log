//
//  ImageViewController.swift
//  Space Log
//
//  Created by Kate Duncan-Welke on 7/11/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var dismissButton: UIButton!
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageLeading: NSLayoutConstraint!
	@IBOutlet weak var imageTop: NSLayoutConstraint!
	@IBOutlet weak var imageBottom: NSLayoutConstraint!
	@IBOutlet weak var imageTrailing: NSLayoutConstraint!
	@IBOutlet weak var buttonView: UIView!
	
	// MARK: Variables
	
	var image: UIImage?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		scrollView.delegate = self
		
		dismissButton.layer.cornerRadius = CGFloat(15.0)
		dismissButton.clipsToBounds = true
		dismissButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
		
		deleteButton.layer.cornerRadius = CGFloat(15.0)
		deleteButton.clipsToBounds = true
		deleteButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
		
		guard let imageToZoom = image else { return }
		imageView.image = imageToZoom
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateZoom(view.bounds.size)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	// MARK: Custom functions
	
	// allow zooming in but limit zooming out to size where image fits on screen
	func updateZoom(_ size: CGSize) {
		let boundsSize = view.bounds.size
		let imageSize = imageView.bounds.size
		
		let xScale = 1 + (1 * (imageSize.width / boundsSize.width))
		let yScale = 1 + (1 * (imageSize.height / boundsSize.height))
		
		let maxScale = max(xScale, yScale)
			
		scrollView.maximumZoomScale = maxScale
		scrollView.minimumZoomScale = 1
	}
	
	func centerImage() {
		// center the zoom view as it becomes smaller than the size of the screen
		let boundsSize = view.bounds.size
		var frameToCenter = scrollView?.frame ?? CGRect.zero
		
		// center horizontally
		if frameToCenter.size.width < boundsSize.width {
			frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
		} else {
			frameToCenter.origin.x = 0
		}
		
		// center vertically
		if frameToCenter.size.height < boundsSize.height {
			frameToCenter.origin.y = (boundsSize.height - (frameToCenter.size.height + buttonView.bounds.height))///2
		} else {
			frameToCenter.origin.y = 0
		}
		
		scrollView?.frame = frameToCenter
	}
	
	// MARK: IBActions
	
	@IBAction func dismissPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func deletePressed(_ sender: UIButton) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "photoDeleted"), object: nil)
		self.dismiss(animated: true, completion: nil)
	}
}

// handle scrollview functions of image
extension ImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		centerImage()
	}
}
