//
//  ViewController.swift
//  FFmpeg Generator
//
//  Created by Dylan McDonald on 6/23/23.
//

import UIKit

class LargeNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.tintColor = .accent
		navigationItem.largeTitleDisplayMode = .always
		
		if runningOn == .iOS {
			navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.tintColor]
			navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.tintColor]
		}
	}
	
	override var prefersStatusBarHidden: Bool {
		if let window = self.view.window {
			if let bannerView = BannerManager.shared.banner(for: window) {
				if hasDynamicIsland() {
					return bannerView.isExpanded()
				} else {
					return false
				}
			} else {
				return false
			}
		} else {
			return false
		}
	}

}
