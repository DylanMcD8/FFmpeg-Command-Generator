//
//  AppStoreReviewManager.swift
//  TalonRewrite
//
//  Created by Michael Burkhardt on 1/22/21.
//  Copyright © 2021 Michael Burkhardt. All rights reserved.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
    
    static func requestReviewIfAppropriate() {
        let randomInt = Int.random(in: 1...5)
        if (randomInt == 1) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
}
