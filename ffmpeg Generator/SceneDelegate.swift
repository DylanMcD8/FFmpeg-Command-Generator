//
//  SceneDelegate.swift
//  ffmpeg Generator
//
//  Created by Dylan McDonald on 10/25/22.
//

enum Platforms {
	case mac
	case iOS
	case vision
}

var runningOn: Platforms = .iOS


import UIKit

class BannerManager {
	static let shared = BannerManager()
	
	private var windowToBannerMap: [UIWindow: DynamicIslandView] = [:]
	
	func addBanner(in window: UIWindow) {
		// Create a new instance of your banner view
		let bannerView = DynamicIslandView(senderWindow: window)
		// Add the banner to the window
		window.addSubview(bannerView)
		bannerView.layer.zPosition = .greatestFiniteMagnitude
		
		// Keep track of the banner for this window
		windowToBannerMap[window] = bannerView
	}
	
	func removeBanner(in window: UIWindow) {
		// Remove the banner associated with this window
		windowToBannerMap[window]?.removeFromSuperview()
		windowToBannerMap.removeValue(forKey: window)
	}
	
	func banner(for window: UIWindow) -> DynamicIslandView? {
		return windowToBannerMap[window]
	}
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
#if os(iOS)
		runningOn = .iOS
#endif
		
#if os(visionOS)
		runningOn = .vision
#endif
		
		
#if targetEnvironment(macCatalyst)
		runningOn = .mac
		var toolbarDelegate: NSToolbarDelegate?
#endif
		
		
		
		
		
#if targetEnvironment(macCatalyst)
		toolbarDelegate = GeneratorToolbarDelegate()
		let toolbar = NSToolbar(identifier: NSToolbar.Identifier("CGASceneDelegate.Toolbar"))
		toolbar.delegate = toolbarDelegate
		toolbar.displayMode = .iconOnly
		toolbar.allowsUserCustomization = false
		//        toolbar.autosavesConfiguration = true
		toolbar.showsBaselineSeparator = false
		
		windowScene.title = "FFmpeg Command Generator"
		
		if let titlebar = windowScene.titlebar {
			titlebar.toolbar = toolbar
			titlebar.toolbarStyle = .unified
		}
#endif
		
		if let windowScene = scene as? UIWindowScene {
			let window = UIWindow(windowScene: windowScene)
			let mainView = LargeNavController(rootViewController: MainViewController())
			
			window.rootViewController = mainView
			mainView.view.backgroundColor = .clear
			mainView.view.isOpaque = false
			
			if runningOn == .mac {
				windowScene.sizeRestrictions?.maximumSize = CGSize(width: 900, height: 620)
				windowScene.sizeRestrictions?.minimumSize = CGSize(width: 900, height: 620)
			} else if runningOn == .vision {
				windowScene.sizeRestrictions?.maximumSize = CGSize(width: 1200, height: 750)
				windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1200, height: 750)
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				windowScene.sizeRestrictions?.maximumSize = CGSize(width: 9000, height: 9000)
			}
#if targetEnvironment(macCatalyst)
			AppDelegate.appKitController?.perform(NSSelectorFromString("configureMainWindowForSceneIdentifier:"), with: windowScene.session.persistentIdentifier)
#endif
			
			
			window.windowScene = windowScene
			self.window = window
			window.makeKeyAndVisible()
			
			BannerManager.shared.addBanner(in: window)
		}
	}
	
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}
	
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}
	
	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
	
}



