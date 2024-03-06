//
//  AppDelegate.swift
//  ffmpeg Generator
//
//  Created by Dylan McDonald on 10/25/22.
//

import UIKit

var commandToRun: String = ""
var useAppleScript = false

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

#if targetEnvironment(macCatalyst)
		AppDelegate.loadAppKitIntegrationFramework()
#endif

            return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
	
	override func buildMenu(with builder: UIMenuBuilder) {
		super.buildMenu(with: builder)
		builder.remove(menu: .services)
		builder.remove(menu: .format)
		
		let dismissViewCommand = UIKeyCommand(title: "Dismiss", action: #selector(AboutTableViewController.dismissViewEscape), input: UIKeyCommand.inputEscape)
		let dismissView = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier("dismissView"), options: .displayInline, children: [dismissViewCommand])
		builder.insertSibling(dismissView, beforeMenu: .minimizeAndZoom)
		
		let resetView = UIKeyCommand(input: "R", modifierFlags: [.command], action: NSSelectorFromString("resetView:"))
		resetView.title = "Reset Input"
		resetView.discoverabilityTitle = "Reset Input"
		
		let resetViewMenu = UIMenu(identifier: UIMenu.Identifier("ResetView"), options: .displayInline, children: [resetView])
		
		builder.insertChild(resetViewMenu, atStartOfMenu: .edit)
	}

#if targetEnvironment(macCatalyst)
	
	static var appKitController:NSObject?
	
	class func loadAppKitIntegrationFramework() {
		
		if let frameworksPath = Bundle.main.privateFrameworksPath {
			let bundlePath = "\(frameworksPath)/AppKitIntegration.framework"
			do {
				try Bundle(path: bundlePath)?.loadAndReturnError()
				
				let bundle = Bundle(path: bundlePath)!
				NSLog("[APPKIT BUNDLE] Loaded Successfully")
				
				if let appKitControllerClass = bundle.principalClass as? NSObject.Type {
					appKitController = appKitControllerClass.init()
					
					NotificationCenter.default.addObserver(appKitController as Any, selector: #selector(_marzipan_setupWindow(_:)), name: NSNotification.Name("UISBHSDidCreateWindowForSceneNotification"), object: nil)
				}
			}
			catch {
				NSLog("[APPKIT BUNDLE] Error loading: \(error)")
			}
		}
	}
    
//    class func runAppleScript(text: String) {
//        commandToRun = text
//        if let frameworksPath = Bundle.main.privateFrameworksPath {
//            let bundlePath = "\(frameworksPath)/AppKitIntegration.framework"
//            do {
//                try Bundle(path: bundlePath)?.loadAndReturnError()
//                
//                let bundle = Bundle(path: bundlePath)!
//                NSLog("[APPKIT BUNDLE] Loaded Successfully")
//                
//                if let appKitControllerClass = bundle.principalClass as? NSObject.Type {
//                    appKitController = appKitControllerClass.init()
//                    
////                    appKitController?.perform(#selector(runTerminalCommand(_:)))
//                }
//            } catch {
//                NSLog("[APPKIT BUNDLE] Error loading: \(error)")
//            }
//        }
//        commandToRun = ""
//    }
	
#endif

}


#if targetEnvironment(macCatalyst)

extension NSObject {
	@objc public func _marzipan_setupWindow(_ sender:Any) {
	}
//    
//    @objc public func runTerminalCommand(_ sender:Any) {
//    }
}

#endif
