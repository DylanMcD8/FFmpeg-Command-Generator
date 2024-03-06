//
//  Toolbar.swift
//  FFmpeg Generator
//
//  Created by Dylan McDonald on 10/25/22.
//

import Foundation
import UIKit

#if targetEnvironment(macCatalyst)
import AppKit

func updateTitlebarTitle(with: String, session: UISceneSession) {
	let windowScene = session.scene as! UIWindowScene
	//    if runningOn == "iPad" {
	//        windowScene.subtitle = with
	//    } else if runningOn == "Mac" {
	windowScene.title = with
	//    }
}
func updateTitlebarSubtitle(with: String, session: UISceneSession) {
	let windowScene = session.scene as! UIWindowScene
	//    if runningOn == "Mac" {
	windowScene.subtitle = with
	//    }
}

func updateTitleBar(withDelegate: NSToolbarDelegate, withTitle: String, withSubtitle: String, iconMode: NSToolbar.DisplayMode, sender: UIViewController, session: UISceneSession) {
	var toolbarDelegate: NSToolbarDelegate?
	toolbarDelegate = withDelegate
	
	//    guard let session = sender.view.window?.windowScene?.session else { print("No session"); return }
	let windowScene = session.scene as! UIWindowScene
	
	//    let windowScene = UIApplication.shared.keyWindow?.windowScene
	
	windowScene.title = withTitle
	windowScene.subtitle = withSubtitle
	
	
	let toolbar = NSToolbar(identifier: "main")
	toolbar.delegate = toolbarDelegate
	toolbar.displayMode = iconMode
	toolbar.allowsUserCustomization = false
	// Enabling this breaks the whole app
	//    toolbar.autosavesConfiguration = true
	toolbar.showsBaselineSeparator = false
	
	if let titlebar = windowScene.titlebar {
		titlebar.toolbar = toolbar
		titlebar.toolbarStyle = .unified
		titlebar.separatorStyle = .none
	}
	
	sender.navigationController?.isNavigationBarHidden = true
}


extension NSToolbarItem.Identifier {
	static let info = NSToolbarItem.Identifier("com.ffmpeg.info")
	static let reset = NSToolbarItem.Identifier("com.ffmpeg.reset")
}

class GeneratorToolbarDelegate: NSObject {
}

extension GeneratorToolbarDelegate: NSToolbarDelegate {
	
	func toolbarItems() -> [NSToolbarItem.Identifier] {
		return [.reset, .info]
	}
	
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return toolbarItems()
	}
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return toolbarItems()
	}
	
	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		switch itemIdentifier {
		case .info:
			
			
			let barItem = UIBarButtonItem(image: UIImage(systemName: "info"), style: .plain, target: nil, action: NSSelectorFromString("openAbout:"))
			let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: barItem)
			
			item.label = "App Info"
			item.toolTip = "App Info"
			item.isBordered = true
			item.isNavigational = false
			item.autovalidates = false
			
			return item
			
			
		case .reset:
			let barItem = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise"), style: .plain, target: nil, action: NSSelectorFromString("resetView:"))
			let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: barItem)
			
			item.label = "Reset Input"
			item.toolTip = "Reset Input"
			item.isBordered = true
			item.isNavigational = false
			item.autovalidates = false
			
			return item
		
		default:
			break
		}
		
		
		
		return NSToolbarItem(itemIdentifier: itemIdentifier)
	}
}

#endif

