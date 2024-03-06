//
//  ViewController.swift
//  ffmpeg Generator
//
//  Created by Dylan McDonald on 10/25/22.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITextFieldDelegate {
    
    var keyboardIsShowing = false
	var lastGeneratedFilename: String = ""
    
    var videoLinkBackground = MacView()
    var audioLinkBackground = MacView()
    var filenameBackground = MacView()
    var fileFormatBackground = MacView()
    var generateButtonBackground = MacView()
    var outputBackground = MacView()
	var outputBackgroundTopConstraint = NSLayoutConstraint()
    var generateButtonBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
	
	var backgroundImageView = UIImageView()
	
	var sectionHeights: CGFloat = 0
    
    let mainScrollView = UIScrollView()
    var mainContentView = UIStackView()
    
    var iOSTitleLabel = UILabel()
    
    var fileDetailsStackView = UIStackView()
    
    var videoLinkField = standardTextField(withPlaceholder: "Enter video link...")
    var audioLinkField = standardTextField(withPlaceholder: "Enter audio link...")
    var filenameField = standardTextField(withPlaceholder: "Enter a file name...")
    var generateButton = UIButton(configuration: .filled())
    var iOSGenerateButton = UIButton(configuration: .tinted())
    var generateAndRunButton = UIButton(configuration: .filled())
    var fileFormatSelector = UISegmentedControl(items: [".mov", ".mp4", ".mkv", ".webm", "Custom"])
    var generatedLinkTextView = UITextView()
    var copyOutputButton = UIButton(configuration: .filled())
    var shareOutputButton = UIButton(configuration: .filled())
    var openTerminalButton = UIButton(configuration: .filled())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if runningOn != .mac {
            self.title = "FFmpeg Command Generator"
        }
        setupInterface()
        
        if runningOn == .vision {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
		
        fileFormatSelector.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "Last Selected Format")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(UpdateSpecklesBackground(_:)), name: NSNotification.Name(rawValue: "UpdateSpecklesBackground"), object: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
#if targetEnvironment(macCatalyst)
        if let session = (self.view.window?.windowScene?.session) {
            updateTitleBar(withDelegate: GeneratorToolbarDelegate(), withTitle: "FFmpeg Command Generator", withSubtitle: "", iconMode: .iconOnly, sender: self, session: session)
        }
#endif
    }
    
#if os(visionOS)
    override var preferredContainerBackgroundStyle: UIContainerBackgroundStyle {
		return .glass
    }
#endif
	
//	override var prefersStatusBarHidden: Bool {
//		if let window = self.view.window {
//			if let bannerView = BannerManager.shared.banner(for: window) {
//				if hasDynamicIsland() {
//					return bannerView.isExpanded()
//				} else {
//					return false
//				}
//			} else {
//				return false
//			}
//		} else {
//			return false
//		}
//	}

	@objc func UpdateSpecklesBackground(_ notification: Notification) {
		if backgroundImageView.isDescendant(of: self.view) && UserDefaults.standard.bool(forKey: "HideSpecklesBackground") {
			backgroundImageView.removeFromSuperview()
		} else if !backgroundImageView.isDescendant(of: self.view) && !UserDefaults.standard.bool(forKey: "HideSpecklesBackground") {
			addBackgroundImage()
		}
	}
    
    @objc func switchedFormat(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "Last Selected Format")
        
        if sender.selectedSegmentIndex == 4 {
			let commandView = runningOn == .iOS ? LargeNavController(rootViewController: CustomFormatViewController()) : CustomFormatViewController()
			commandView.modalPresentationStyle = .formSheet
			present(commandView, animated: true, completion: nil)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { [self] in
            self.generatedLinkTextView.font = UIFont.monospacedSystemFont(ofSize: self.generatedLinkTextView.font!.pointSize, weight: .medium)
            updateInterfaceForCompactness()
        }
    }
	
	var compactHeightConstraint: NSLayoutConstraint?
	var wideHeightConstraint: NSLayoutConstraint?
	
    func updateInterfaceForCompactness() {
        fileDetailsStackView.axis = traitCollection.horizontalSizeClass == .compact ? .vertical : .horizontal

	
        if runningOn == .iOS {
            DispatchQueue.main.async { [self] in
				// bane of my existence right here. it magically decreases every time, for NO ****ING REASON. changed to using constant values, which isn't great, but they work soo
//				let calculatedHeight = videoLinkBackground.frame.height + 20 + audioLinkBackground.frame.height + 20 + fileDetailsStackView.frame.height + 20
//				print("*** CALCULATED HEIGHT: \(videoLinkBackground.frame.height)")
				// iPhone 15 PM: 494
				// iPhone SE Zoom: 494.5
				// iPhone SE: 494.5
				// iPhone 15 Pro: 494
				// iPad mini Compact: 494.5
				// iPad Pro Wide: ???
//				let heightConst = mainContentView.heightAnchor.constraint(equalToConstant: calculatedHeight)
				
				//			heightConst.priority = UILayoutPriority(250)
//				heightConst.isActive = true
				
                mainScrollView.contentInset = .zero
				outputBackground.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20 - 60 - 20 - 20).isActive = true
            }

			
			if traitCollection.horizontalSizeClass == .compact {
				iOSTitleLabel.text = "FFmpeg Generator"
				outputBackground.isHidden = true
				mainScrollView.isScrollEnabled = true
				wideHeightConstraint?.isActive = false
				compactHeightConstraint?.isActive = true
				mainScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = false
				mainScrollView.bottomAnchor.constraint(equalTo: generateButtonBlurView.topAnchor, constant: 0).isActive = true
				outputBackgroundTopConstraint.isActive = false
			
			} else {
                iOSTitleLabel.text = "FFmpeg Command Generator"
                outputBackground.isHidden = false
				compactHeightConstraint?.isActive = false
				wideHeightConstraint?.isActive = true
//                mainScrollView.isScrollEnabled = false
				
				outputBackgroundTopConstraint.isActive = true
                mainScrollView.bottomAnchor.constraint(equalTo: generateButtonBlurView.topAnchor, constant: 0).isActive = false
                mainScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            }
        } else {
            mainScrollView.isScrollEnabled = false
			mainScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }
	
	
	
    
    @objc func copyText(_ sender: Any) {
		if let bannerView = BannerManager.shared.banner(for: self.view.window!) {
			bannerView.setViewForStatusBar(self.navigationController ?? self)
			bannerView.setTitle("Command Copied!")
			bannerView.setImageName("paperclip.circle.fill")
			bannerView.expandIsland(collapseDelay: 3)
		}
			UIPasteboard.general.string = generatedLinkTextView.text ?? ""
		successHaptics()
    }
    
    @objc func shareText(_ sender: Any) {
        let items = [generatedLinkTextView.text ?? ""]

        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.shareOutputButton
        ac.popoverPresentationController?.sourceRect = self.shareOutputButton.bounds
        self.present(ac, animated: true)
    }
    
    
    @objc func openTerminal(_ sender: Any) {
        let command = self.generatedLinkTextView.text ?? ""
        if command != "" {
			if useAppleScript {
				runTerminalCommand(command: command)
			} else {
				copyAndOpenTerminal()
			}
        } else {
            let alert = UIAlertController(title: "No Command to Run", message: "Fill out the fields then click Generate to create the command. Then you can select Run in Terminal.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            alert.view.tintColor = .tintColor
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func generateAndRun(_ sender: Any) {
		extractFileName(from: videoLinkField.text ?? "")
        if videoLinkField.text != "" && filenameField.text != "" {
            generatedLinkTextView.text = generateCommand()
            
            let command = self.generatedLinkTextView.text ?? ""
			if command != "" {
				if useAppleScript {
					runTerminalCommand(command: command)
				} else {
					copyAndOpenTerminal()
				}
            } else {
                let alert = UIAlertController(title: "No Command to Run", message: "Fill out the fields then click Generate to create the command. Then you can select Run in Terminal.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                alert.view.tintColor = .tintColor
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Incomplete", message: "Ensure you have at least the Video Link and File Name fields filled out.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            alert.view.tintColor = .tintColor
            self.present(alert, animated: true, completion: nil)
        }
        
       
    }
	
//	func runTerminalCommandViaProcess(command: String) {
//		
//	}
	
	func extractFileName(from urlString: String) {
		// Convert the string to a URL
		if urlString == "" {
			filenameField.text = ""
			lastGeneratedFilename = ""
		} else if let url = URL(string: urlString) {
			var fileName = url.deletingPathExtension().lastPathComponent
			if fileName == "prog_index" {
				if url.pathComponents.count > 1 {
					fileName = url.deletingLastPathComponent().pathComponents[url.pathComponents.count - 2]
				}
			}
			
			if filenameField.text == "" || filenameField.text == lastGeneratedFilename {
				filenameField.text = fileName
			}
			
			lastGeneratedFilename = fileName
		} else {
			// Nothing yet
		}
	}
	
	func copyAndOpenTerminal() {
		func performFunction() {
			UIPasteboard.general.string = generatedLinkTextView.text ?? ""
			openTerminal()
			if let bannerView = BannerManager.shared.banner(for: self.view.window!) {
				bannerView.setViewForStatusBar(self.navigationController ?? self)
				bannerView.setTitle("Command Copied and Terminal Opened")
				bannerView.setImageName("apple.terminal.on.rectangle")
				bannerView.expandIsland(collapseDelay: 3)
			}
		}
		
		if UserDefaults.standard.bool(forKey: "Copy and Open Warning") == false {
			let alert = UIAlertController(title: "Notice", message: "This option will copy the command to your clipboard and then open Terminal. You will have to paste and run the command yourself.", preferredStyle: .alert)
			let okAction = UIAlertAction(title: "Copy and Open", style: .default) { _ in
				performFunction()
				UserDefaults.standard.setValue(true, forKey: "Copy and Open Warning")
			}
			alert.addAction(okAction)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			alert.view.tintColor = .tintColor
			self.present(alert, animated: true, completion: nil)
		} else {
			performFunction()
		}
	}
	
	func openTerminal() {
		func presentError() {
			let alert = UIAlertController(title: "Error Opening Terminal", message: "There was an error opening Terminal. Please open it manually.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
			alert.view.tintColor = .tintColor
			self.present(alert, animated: true, completion: nil)
		}
		
		if let url = URL(string: "x-man-page://") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url)
			} else {
				print("Cannot open URL")
				presentError()
			}
		} else {
			presentError()
		}
	}
	
//	func runPasteScript() {
//
//		let source = """
//  tell application "System Events"
//activate
//set the clipboardText to the clipboard as text
// keystroke "v" using {command down}
//  end tell
//"""
//		runAppleScript(source)
//	}
	
	func runTerminalCommand(command: String) {
		let source = """
   tell application "Terminal"
   do script "\(command)"
   activate
   end tell
   """
		runAppleScript(source)
		
		if let bannerView = BannerManager.shared.banner(for: self.view.window!) {
			bannerView.setViewForStatusBar(self.navigationController ?? self)
			bannerView.setTitle("Command Run in Terminal")
			bannerView.setImageName("apple.terminal")
			bannerView.expandIsland(collapseDelay: 3)
		}
	}
    
	func runAppleScript(_ source: String) {
#if targetEnvironment(macCatalyst)
		DispatchQueue.global(qos: .background).async {
			if let appleScript = NSAppleScript(source: source) {
				var errorDict: NSDictionary?
				let result = appleScript.executeAndReturnError(&errorDict)
				
				if let error = errorDict {
					print("Error running AppleScript: \(error)")
					DispatchQueue.main.async { [self] in
						var errorToPresent = "\(error)"
						if let errorMessage = interpretJSON(forObject: "NSAppleScriptErrorMessage", jsonData: error),
						   let errorNumber = interpretJSON(forObject: "NSAppleScriptErrorNumber", jsonData: error) {
							errorToPresent = errorMessage + " (" + errorNumber + ")"
						}
						let alert = UIAlertController(title: "Error Running AppleScript", message: "There was an error running the AppleScript command. Please paste and run the command in Terminal manually.\n\nError: " + errorToPresent, preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
						alert.view.tintColor = .tintColor
						self.present(alert, animated: true, completion: nil)
					}
					
				} else {
					print("AppleScript executed successfully. Result: \(result)")
				}
			} else {
				print("Error creating NSAppleScript instance.")
				DispatchQueue.main.async { [self] in
					let alert = UIAlertController(title: "Error Running AppleScript", message: "There was an unknown error creating the AppleScript instance. Please try again. If you continue to have issues, please send me an email in Info → Help and Feedback.", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
					alert.view.tintColor = .tintColor
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
#endif
	}
    
    func makeCommand(videoLink: String, audioLink: String = "", filename: String) -> String {
        
        var finalCommand = ""
        
        if audioLinkField.text == "" {
            finalCommand = "ffmpeg -i \(videoLink) -c copy \(filename)"
        } else {
            finalCommand = "ffmpeg -i \(videoLink) -i \(audioLink) -map 0:v:0 -map 1:a:0 -c copy \(filename)"
        }
        
        return finalCommand
    }
    
//	func generateAndCopyCommand() -> String {
//		let command = generateCommand()
//		UIPasteboard.general.string = command
//		
//		return command
//	}
	
    func generateCommand() -> String {
        
        var toReturn = ""
        
        let videoLink = (videoLinkField.text ?? "").parsedForTerminal()
        let audioLink = (audioLinkField.text ?? "").parsedForTerminal()
        var filename = (filenameField.text ?? "").parsedForTerminal()
        
        switch fileFormatSelector.selectedSegmentIndex {
        case 0:
            filename += ".mov"
        case 1:
            filename += ".mp4"
        case 2:
            filename += ".mkv"
        case 3:
            filename += ".webm"
        case 4:
            filename += UserDefaults.standard.string(forKey: "Custom File Format") ?? ""
        default:
            break
        }
        
        if audioLink != "" {
            toReturn = makeCommand(videoLink: videoLink, audioLink: audioLink, filename: filename)
        } else {
            toReturn = makeCommand(videoLink: videoLink, filename: filename)
        }
        
        openTerminalButton.isEnabled = true
        copyOutputButton.isEnabled = true
        shareOutputButton.isEnabled = true
		
		AppStoreReviewManager.requestReviewIfAppropriate()
        
        return toReturn
        
    }
    
    let sheetTransitioningDelegate = SheetTransitioningDelegate()
	
	@objc func generateFilename(_ sender: Any) {
		filenameField.text = ""
		extractFileName(from: videoLinkField.text ?? "")
		if let bannerView = BannerManager.shared.banner(for: self.view.window!) {
			bannerView.setViewForStatusBar(self.navigationController ?? self)
			if traitCollection.horizontalSizeClass == .compact {
				bannerView.setTitle("Filename Extracted")
			} else {
				bannerView.setTitle("Filename Extracted from URL")
			}
			bannerView.setImageName("folder.circle.fill")
			bannerView.expandIsland(collapseDelay: 3)
		}
	}
    
    @objc func generate(_ sender: Any) {
		extractFileName(from: videoLinkField.text ?? "")
        if videoLinkField.text != "" && filenameField.text != "" {
            if traitCollection.horizontalSizeClass == .compact {
				softHaptics()
                let commandView = GeneratedCommandViewController()
                commandView.commandToShow = generateCommand()
				commandView.senderView = self
                let navView = LargeNavController(rootViewController: commandView)
				navView.modalPresentationCapturesStatusBarAppearance = true
                
                navView.transitioningDelegate = sheetTransitioningDelegate
                sheetTransitioningDelegate.shouldShowGrabber = false
                navView.modalPresentationStyle = .custom
				self.present(navView, animated: true, completion: nil)
			} else {
				successHaptics()
			}
            generatedLinkTextView.text = generateCommand()
        } else {
            let alert = UIAlertController(title: "Incomplete", message: "Ensure you have at least the Video Link and File Name fields filled out.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            alert.view.tintColor = .tintColor
            self.present(alert, animated: true, completion: nil)
        }
       
    }
	
	@objc func textFieldDidChange(_ textField: UITextField) {
		if let text = textField.text {
			extractFileName(from: text)
		}
	}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
		
		extractFileName(from: videoLinkField.text ?? "")
        
        UserDefaults.standard.setValue(videoLinkField.text ?? "", forKey: "Last Video Link")
        UserDefaults.standard.setValue(audioLinkField.text ?? "", forKey: "Last Audio Link")
        UserDefaults.standard.setValue(filenameField.text ?? "", forKey: "Last File Name")
        
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.setValue(videoLinkField.text ?? "", forKey: "Last Video Link")
        UserDefaults.standard.setValue(audioLinkField.text ?? "", forKey: "Last Audio Link")
        UserDefaults.standard.setValue(filenameField.text ?? "", forKey: "Last File Name")
    }
    
    func resetView() {
        audioLinkField.text = ""
        videoLinkField.text = ""
        filenameField.text = ""
        generatedLinkTextView.text = "Waiting for input..."
        
        openTerminalButton.isEnabled = false
        copyOutputButton.isEnabled = false
        shareOutputButton.isEnabled = false
        
        UserDefaults.standard.setValue("", forKey: "Last Video Link")
        UserDefaults.standard.setValue("", forKey: "Last Audio Link")
        UserDefaults.standard.setValue("", forKey: "Last File Name")
    }
    
    @objc func resetView(_ sender: Any) {
        resetView()
		heavyHaptics()
    }
    
    func openAbout() {
        let aboutView = runningOn == .mac ? AboutTableViewController() : LargeNavController(rootViewController: AboutTableViewController())
        if runningOn != .mac {
            aboutView.title = "About"
        }
        aboutView.modalPresentationStyle = .formSheet
        present(aboutView, animated: true, completion: nil)
    }
    
    @objc func openAbout(_ sender: Any) {
        //		let viewID = "About"
        //		let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewID)
        //		view.modalPresentationStyle = .formSheet
        //		self.present(view, animated: true, completion: nil)
        openAbout()
    }
    
}










extension MainViewController: UIScrollViewDelegate {
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x != 0 {
//            scrollView.contentOffset.x = 0
//        }
//    }
	
	func addBackgroundImage() {
		if !UserDefaults.standard.bool(forKey: "HideSpecklesBackground") {
			backgroundImageView.image = UIImage(resource: .speckles)
			backgroundImageView.contentMode = .scaleAspectFill
			if runningOn == .iOS {
				addReverseParallaxToView(view: backgroundImageView, amount: 15)
			} else {
				backgroundImageView.alpha = 0.3
			}
			backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(backgroundImageView)
			self.view.sendSubviewToBack(backgroundImageView)
			
			let constant: CGFloat = runningOn == .iOS ? 15 : 0
			NSLayoutConstraint.activate([
				backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
				backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: constant),
				backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: constant),
				backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: constant)
			])
		}
	}
    
    func setupInterface() {
		
		addBackgroundImage()
		
		// Scroll View and Content View
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainScrollView)
        mainScrollView.isScrollEnabled = true
        mainScrollView.delegate = self
        mainScrollView.clipsToBounds = false
        mainContentView.clipsToBounds = false
		mainScrollView.backgroundColor = .clear
		mainContentView.backgroundColor = .clear
		
		mainContentView.axis = .vertical
		mainContentView.spacing = 20
		mainContentView.isLayoutMarginsRelativeArrangement = true
		mainContentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
		
		

        // Add constraints to define the scroll view's position and size
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)/*,*/
//			mainScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
		
//		if runningOn == .iOS {
//			mainScrollView.bottomAnchor.constraint(equalTo: self.generateButtonBlurView.topAnchor, constant: 0).isActive = true
//		} else {
//		}
        
//        mainContentView.backgroundColor = .clear
		mainContentView.translatesAutoresizingMaskIntoConstraints = false
		mainScrollView.addSubview(mainContentView)
		
		mainContentView.distribution = .fillProportionally
		mainContentView.alignment = .fill

		// Add constraints to define the content view's size (should match the content size of the scroll view)
		var constraints = [
			mainContentView.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor),
			mainContentView.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor),
			mainContentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			mainContentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		]
		
		if runningOn == .vision {
			constraints[0] = mainContentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -20)
		} else {
//			constraints[0].priority = UILayoutPriority(250)
			constraints[1].priority = UILayoutPriority(250)
		}
		
		for item in constraints {
//			item.priority = UILayoutPriority(250)
			item.isActive = true
		}
        

        
        // ADD VIEW COMPONENTS
        // Add videoLinkBackground
        mainContentView.addArrangedSubview(videoLinkBackground)
        videoLinkBackground.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            videoLinkBackground.topAnchor.constraint(
//                equalTo: mainContentView.topAnchor,
//                constant: runningOn == .vision ? 0 : 20
//            ),
//            videoLinkBackground.leadingAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
//                constant: 20
//            ),
//            videoLinkBackground.trailingAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
//                constant: -20
//            )
//        ])
        
        let videoLinkTitle: UILabel = {
            let label = UILabel()
            label.text = "Video Link"
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: runningOn == .mac ? 12 : 16, weight: .semibold)
            return label
        }()
        videoLinkTitle.translatesAutoresizingMaskIntoConstraints = false
        videoLinkBackground.addSubview(videoLinkTitle)
        NSLayoutConstraint.activate([
            videoLinkTitle.topAnchor.constraint(
                equalTo: videoLinkBackground.topAnchor,
                constant: 20
            ),
            videoLinkTitle.leadingAnchor.constraint(
                equalTo: videoLinkBackground.leadingAnchor,
                constant: 20
            ),
            videoLinkTitle.trailingAnchor.constraint(
                equalTo: videoLinkBackground.trailingAnchor,
                constant: -20
            )
        ])
        
        
        videoLinkField.translatesAutoresizingMaskIntoConstraints = false
        videoLinkField.delegate = self
		videoLinkField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		videoLinkField.clearButtonMode = .whileEditing
		videoLinkField.keyboardType = .webSearch
		videoLinkField.returnKeyType = .done
		videoLinkField.autocapitalizationType = .none
		videoLinkField.autocorrectionType = .no
        videoLinkField.text = UserDefaults.standard.string(forKey: "Last Video Link") ?? ""
        videoLinkBackground.addSubview(videoLinkField)
        NSLayoutConstraint.activate([
            videoLinkField.topAnchor.constraint(
                equalTo: videoLinkTitle.bottomAnchor,
                constant: 5
            ),
            videoLinkField.bottomAnchor.constraint(
                equalTo: videoLinkBackground.bottomAnchor,
                constant: -20
            ),
            videoLinkField.leadingAnchor.constraint(
                equalTo: videoLinkBackground.leadingAnchor,
                constant: 20
            ),
            videoLinkField.trailingAnchor.constraint(
                equalTo: videoLinkBackground.trailingAnchor,
                constant: -20
            )
        ])
        
        
        // Add audioLinkBackground
        mainContentView.addArrangedSubview(audioLinkBackground)
        audioLinkBackground.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            audioLinkBackground.topAnchor.constraint(
//                equalTo: videoLinkBackground.bottomAnchor,
//                constant: 20
//            ),
//            audioLinkBackground.leadingAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
//                constant: 20
//            ),
//            audioLinkBackground.trailingAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
//                constant: -20
//            )
//        ])
        
        let audioLinkTitle: UILabel = {
            let label = UILabel()
            //			label.text = "Audio Link (Optional)"
            label.textColor = .secondaryLabel
            let attributedText = NSMutableAttributedString(string: "Audio Link (Optional)")
            attributedText.addAttribute(.foregroundColor, value: UIColor.tertiaryLabel, range: NSRange(location: "Audio Link ".count, length: "(Optional)".count))
            label.attributedText = attributedText
            label.font = .systemFont(ofSize: runningOn == .mac ? 12 : 16, weight: .semibold)
            return label
        }()
        audioLinkTitle.translatesAutoresizingMaskIntoConstraints = false
        audioLinkBackground.addSubview(audioLinkTitle)
        NSLayoutConstraint.activate([
            audioLinkTitle.topAnchor.constraint(
                equalTo: audioLinkBackground.topAnchor,
                constant: 20
            ),
            audioLinkTitle.leadingAnchor.constraint(
                equalTo: audioLinkBackground.leadingAnchor,
                constant: 20
            ),
            audioLinkTitle.trailingAnchor.constraint(
                equalTo: audioLinkBackground.trailingAnchor,
                constant: -20
            )
        ])
        
        
        audioLinkField.translatesAutoresizingMaskIntoConstraints = false
        audioLinkField.delegate = self
		audioLinkField.clearButtonMode = .whileEditing
		audioLinkField.keyboardType = .webSearch
		audioLinkField.returnKeyType = .done
		audioLinkField.autocapitalizationType = .none
		audioLinkField.autocorrectionType = .no
        audioLinkField.text = UserDefaults.standard.string(forKey: "Last Audio Link") ?? ""
        audioLinkBackground.addSubview(audioLinkField)
        NSLayoutConstraint.activate([
            audioLinkField.topAnchor.constraint(
                equalTo: audioLinkTitle.bottomAnchor,
                constant: 5
            ),
            audioLinkField.bottomAnchor.constraint(
                equalTo: audioLinkBackground.bottomAnchor,
                constant: -20
            ),
            audioLinkField.leadingAnchor.constraint(
                equalTo: audioLinkBackground.leadingAnchor,
                constant: 20
            ),
            audioLinkField.trailingAnchor.constraint(
                equalTo: audioLinkBackground.trailingAnchor,
                constant: -20
            ),
            audioLinkBackground.heightAnchor.constraint(equalTo: videoLinkBackground.heightAnchor)
        ])
        
        // FILE NAME, FILE FORMAT, GENERATE STACK VIEW
        // Add Stack View
        fileDetailsStackView.axis = view.traitCollection.horizontalSizeClass == .compact ? .vertical : .horizontal
        fileDetailsStackView.spacing = 20
        fileDetailsStackView.translatesAutoresizingMaskIntoConstraints = false
        mainContentView.addArrangedSubview(fileDetailsStackView)
//        NSLayoutConstraint.activate([
//            fileDetailsStackView.topAnchor.constraint(
//                equalTo: audioLinkBackground.bottomAnchor,
//                constant: 20
//            ),
//            fileDetailsStackView.leadingAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
//                constant: 20
//            ),
//            fileDetailsStackView.trailingAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
//                constant: -20
//            ),
//			fileDetailsStackView.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: -20)
//        ])
        
        // Add File Name section
        fileDetailsStackView.addArrangedSubview(filenameBackground)
        filenameBackground.translatesAutoresizingMaskIntoConstraints = false
        //		filenameBackground.heightAnchor.constraint(constant: 20).isActive = true
        
        let fileNameTitle: UILabel = {
			let label = UILabel()
			label.tintColor = .tintColor
			// Create the attributed string
			let attributedString = NSMutableAttributedString(string: "File Name ", attributes: [
				.font: UIFont.systemFont(ofSize: runningOn == .mac ? 12 : 16, weight: .semibold),
				.foregroundColor: UIColor.secondaryLabel
			])
			
			// Add the "Extract from URL" part with a different color
			let extractString = NSAttributedString(string: "Extract from URL", attributes: [
				.font: UIFont.systemFont(ofSize: runningOn == .mac ? 10 : 14, weight: .medium),
				.foregroundColor: UIColor.tintColor
			])
			
			attributedString.append(extractString)
			label.attributedText = attributedString
			
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(generateFilename(_:)))
			label.isUserInteractionEnabled = true
			label.addGestureRecognizer(tapGesture)
//			label.textColor = .secondaryLabel
			return label
        }()
        fileNameTitle.translatesAutoresizingMaskIntoConstraints = false
        filenameBackground.addSubview(fileNameTitle)
        NSLayoutConstraint.activate([
            fileNameTitle.topAnchor.constraint(
                equalTo: filenameBackground.topAnchor,
                constant: 20
            ),
            fileNameTitle.leadingAnchor.constraint(
                equalTo: filenameBackground.leadingAnchor,
                constant: 20
            ),
            fileNameTitle.trailingAnchor.constraint(
                equalTo: filenameBackground.trailingAnchor,
                constant: -20
            ),
            filenameBackground.heightAnchor.constraint(equalTo: videoLinkBackground.heightAnchor)
        ])
        
        filenameField.translatesAutoresizingMaskIntoConstraints = false
        filenameField.delegate = self
		filenameField.keyboardType = .webSearch
		filenameField.returnKeyType = .done
        filenameField.text = UserDefaults.standard.string(forKey: "Last File Name") ?? ""
		filenameField.clearButtonMode = .whileEditing
        filenameBackground.addSubview(filenameField)
        NSLayoutConstraint.activate([
            filenameField.topAnchor.constraint(
                equalTo: fileNameTitle.bottomAnchor,
                constant: 5
            ),
            filenameField.bottomAnchor.constraint(
                equalTo: filenameBackground.bottomAnchor,
                constant: -20
            ),
            filenameField.leadingAnchor.constraint(
                equalTo: filenameBackground.leadingAnchor,
                constant: 20
            ),
            filenameField.trailingAnchor.constraint(
                equalTo: filenameBackground.trailingAnchor,
                constant: -20
            ),
        ])
		
        
        
        // Add File Format section
        fileDetailsStackView.addArrangedSubview(fileFormatBackground)
        filenameBackground.translatesAutoresizingMaskIntoConstraints = false
        //		filenameBackground.heightAnchor.constraint(constant: 20).isActive = true
        
        let fileFormatTitle: UILabel = {
            let label = UILabel()
            label.text = "File Format"
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: runningOn == .mac ? 12 : 16, weight: .semibold)
            return label
        }()
        fileFormatTitle.translatesAutoresizingMaskIntoConstraints = false
        fileFormatBackground.addSubview(fileFormatTitle)
        NSLayoutConstraint.activate([
            fileFormatTitle.topAnchor.constraint(
                equalTo: fileFormatBackground.topAnchor,
                constant: 20
            ),
            fileFormatTitle.leadingAnchor.constraint(
                equalTo: fileFormatBackground.leadingAnchor,
                constant: 20
            ),
            fileFormatTitle.trailingAnchor.constraint(
                equalTo: fileFormatBackground.trailingAnchor,
                constant: -20
            )
        ])
        
        fileFormatSelector.addTarget(self, action: #selector(switchedFormat(_:)), for: .valueChanged)
        fileFormatSelector.translatesAutoresizingMaskIntoConstraints = false
        fileFormatBackground.addSubview(fileFormatSelector)
        NSLayoutConstraint.activate([
            fileFormatSelector.topAnchor.constraint(
                equalTo: fileFormatTitle.bottomAnchor,
                constant: 5
            ),
            fileFormatSelector.bottomAnchor.constraint(
                equalTo: fileFormatBackground.bottomAnchor,
                constant: -20
            ),
            fileFormatSelector.leadingAnchor.constraint(
                equalTo: fileFormatBackground.leadingAnchor,
                constant: 20
            ),
            fileFormatSelector.trailingAnchor.constraint(
                equalTo: fileFormatBackground.trailingAnchor,
                constant: -20
            ),
            fileFormatBackground.widthAnchor.constraint(equalTo: filenameBackground.widthAnchor),
            fileFormatBackground.heightAnchor.constraint(equalTo: videoLinkBackground.heightAnchor)
        ])
        //		fileFormatBackground.widthAnchor.constraint(equalTo: filenameBackground.widthAnchor).isActive = true
        
        
		// Generate Button (first!)
		let generateButtonsStackView = UIStackView()
		if runningOn != .iOS {
			generateButtonBackground.translatesAutoresizingMaskIntoConstraints = false
			fileDetailsStackView.addArrangedSubview(generateButtonBackground)
			generateButtonBackground.heightAnchor.constraint(equalTo: filenameBackground.heightAnchor).isActive = true
			generateButtonsStackView.isOpaque = true
			generateButtonsStackView.axis = .vertical
			generateButtonsStackView.spacing = 10
			generateButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
			generateButtonBackground.addSubview(generateButtonsStackView)
			let insetNumber: CGFloat = runningOn == .mac ? 10 : 20
			NSLayoutConstraint.activate([
				generateButtonsStackView.topAnchor.constraint(
					greaterThanOrEqualTo: generateButtonBackground.topAnchor,
					constant: insetNumber
				),
				generateButtonsStackView.bottomAnchor.constraint(
					greaterThanOrEqualTo: generateButtonBackground.bottomAnchor,
					constant: -insetNumber
				),
				generateButtonsStackView.leadingAnchor.constraint(
					equalTo: generateButtonBackground.leadingAnchor,
					constant: insetNumber
				),
				generateButtonsStackView.trailingAnchor.constraint(
					equalTo: generateButtonBackground.trailingAnchor,
					constant: -insetNumber
				),
				generateButtonsStackView.centerXAnchor.constraint(equalTo: generateButtonBackground.centerXAnchor),
				generateButtonsStackView.centerYAnchor.constraint(equalTo: generateButtonBackground.centerYAnchor)
			])
			
			if runningOn == .mac {
				generateButtonBackground.widthAnchor.constraint(equalToConstant: 155).isActive = true
			} else /*if runningOn == .vision*/ {
				generateButtonBackground.widthAnchor.constraint(equalToConstant: 160).isActive = true
			}
		}
		
		
		
		// Generate button
		if runningOn == .iOS {
			var configuration = UIButton.Configuration.tinted()
			configuration.cornerStyle = .large
			generateButton = UIButton(configuration: configuration)
		}
		generateButton.setTitle("Generate", for: .normal)
		generateButton.addTarget(self, action: #selector(generate(_:)), for: .touchUpInside)
		generateButton.isPointerInteractionEnabled = true
		generateButton.translatesAutoresizingMaskIntoConstraints = false
		if runningOn != .mac {
			generateButton.tintColor = .tintColor
		}
		generateButtonsStackView.addArrangedSubview(generateButton)
		
		
		
		if runningOn == .mac {
			if useAppleScript {
				generateAndRunButton.setTitle("Generate and Run", for: .normal)
				generateAndRunButton.toolTip = "Generates the command and runs it in Terminal"
			} else {
				generateAndRunButton.setTitle("Generate and Open", for: .normal)
				generateAndRunButton.toolTip = "Generates the command, copies it to your clipboard, and opens Terminal"
			}
			
			generateAndRunButton.addTarget(self, action: #selector(generateAndRun(_:)), for: .touchUpInside)
			generateAndRunButton.translatesAutoresizingMaskIntoConstraints = false
			generateButtonsStackView.addArrangedSubview(generateAndRunButton)
			generateAndRunButton.heightAnchor.constraint(equalTo: generateButton.heightAnchor).isActive = true
		}
		
		if runningOn == .iOS {
			var configuration = UIButton.Configuration.tinted()
			configuration.cornerStyle = .large
			iOSGenerateButton = UIButton(configuration: configuration)
			
			iOSGenerateButton.setTitle("Generate", for: .normal)
			iOSGenerateButton.addTarget(self, action: #selector(generate(_:)), for: .touchUpInside)
			iOSGenerateButton.translatesAutoresizingMaskIntoConstraints = false
			iOSGenerateButton.tintColor = .tintColor
			iOSGenerateButton.isPointerInteractionEnabled = true
			let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold)]
			let attributedString = NSAttributedString(string: "Generate", attributes: attributes)
			iOSGenerateButton.setAttributedTitle(attributedString, for: .normal)
			view.addSubview(iOSGenerateButton)
			
			NSLayoutConstraint.activate([
				//                iOSGenerateButton.topAnchor.constraint(
				//                    greaterThanOrEqualTo: fileDetailsStackView.bottomAnchor,
				//                    constant: -20
				//                ),
				iOSGenerateButton.bottomAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.bottomAnchor,
					constant: -20
				),
				iOSGenerateButton.leadingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.leadingAnchor,
					constant: 20
				),
				iOSGenerateButton.trailingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.trailingAnchor,
					constant: -20
				),
				iOSGenerateButton.heightAnchor.constraint(equalToConstant: 60)
			])
			
			
			generateButtonBlurView.translatesAutoresizingMaskIntoConstraints = false
			view.insertSubview(generateButtonBlurView, belowSubview: iOSGenerateButton)
			
			generateButtonBlurView.layer.borderColor = UIColor.systemFill.cgColor
			generateButtonBlurView.layer.borderWidth = 1
			
			NSLayoutConstraint.activate([
				generateButtonBlurView.topAnchor.constraint(
					equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
					constant: -20 - 60 - 20
				),
				generateButtonBlurView.bottomAnchor.constraint(
					equalTo: view.bottomAnchor,
					constant: 2
				),
				generateButtonBlurView.leadingAnchor.constraint(
					equalTo: view.leadingAnchor,
					constant: -2
				),
				generateButtonBlurView.trailingAnchor.constraint(
					equalTo: view.trailingAnchor,
					constant: 2
				)
			])
		}
		
        outputBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outputBackground)
        NSLayoutConstraint.activate([
            outputBackground.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            outputBackground.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            outputBackground.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            )
        ])
		
		outputBackgroundTopConstraint = NSLayoutConstraint(item: self.outputBackground, attribute: .top, relatedBy: .equal, toItem: self.mainContentView, attribute: .bottom, multiplier: 1, constant: 0)
		outputBackgroundTopConstraint.isActive = true
        
        let generatedCommandTitle: UILabel = {
            let label = UILabel()
            label.text = "Generated Command"
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: runningOn == .mac ? 18 : 25, weight: .semibold)
            return label
        }()
        generatedCommandTitle.translatesAutoresizingMaskIntoConstraints = false
        outputBackground.addSubview(generatedCommandTitle)
        NSLayoutConstraint.activate([
            generatedCommandTitle.topAnchor.constraint(
                equalTo: outputBackground.topAnchor,
                constant: 15
            ),
            generatedCommandTitle.leadingAnchor.constraint(
                equalTo: outputBackground.leadingAnchor,
                constant: 20
            ),
            generatedCommandTitle.trailingAnchor.constraint(
                equalTo: outputBackground.trailingAnchor,
                constant: -20
            )
        ])
        
        generatedLinkTextView.backgroundColor = .clear
        generatedLinkTextView.isEditable = false
        generatedLinkTextView.translatesAutoresizingMaskIntoConstraints = false
        outputBackground.addSubview(generatedLinkTextView)
        NSLayoutConstraint.activate([
            generatedLinkTextView.topAnchor.constraint(
                equalTo: generatedCommandTitle.bottomAnchor,
                constant: 0
            ),
            generatedLinkTextView.leadingAnchor.constraint(
                equalTo: outputBackground.leadingAnchor,
                constant: 20
            ),
            generatedLinkTextView.trailingAnchor.constraint(
                equalTo: outputBackground.trailingAnchor,
                constant: -20
            )
        ])
        if runningOn != .mac {
            generatedLinkTextView.bottomAnchor.constraint(
                equalTo: outputBackground.bottomAnchor,
                constant: -20
            ).isActive = true
		}
        
        
        
        if runningOn == .iOS {
            copyOutputButton = tintedCircleButton(imageName: "doc.on.clipboard", action: UIAction() { _ in
            })
            copyOutputButton.backgroundColor = .secondarySystemGroupedBackground
            copyOutputButton.layer.cornerRadius = 35 / 2
        } else {
            copyOutputButton.setTitle("Copy Text", for: .normal)
        }
        copyOutputButton.addTarget(self, action: #selector(copyText(_:)), for: .touchUpInside)
        copyOutputButton.translatesAutoresizingMaskIntoConstraints = false
        copyOutputButton.isEnabled = false
		copyOutputButton.isPointerInteractionEnabled = true
        outputBackground.insertSubview(copyOutputButton, aboveSubview: generatedLinkTextView)
		if runningOn == .mac {
			copyOutputButton.topAnchor.constraint(
				equalTo: generatedLinkTextView.bottomAnchor,
				constant: 10
			).isActive = true
		}
        if runningOn != .iOS {
            NSLayoutConstraint.activate([
                copyOutputButton.trailingAnchor.constraint(
                    equalTo: outputBackground.trailingAnchor,
                    constant: -20
                ),
                copyOutputButton.bottomAnchor.constraint(
                    equalTo: outputBackground.bottomAnchor,
                    constant: -20
                )
            ])
        } else {
            NSLayoutConstraint.activate([
                copyOutputButton.topAnchor.constraint(
                    equalTo: outputBackground.topAnchor,
                    constant: 15
                ),
                copyOutputButton.trailingAnchor.constraint(
                    equalTo: outputBackground.trailingAnchor,
                    constant: -10
                )
            ])
        }
        
        
        
        if runningOn == .iOS {
            shareOutputButton = tintedCircleButton(imageName: "square.and.arrow.up", action: UIAction() { _ in
            })
            shareOutputButton.backgroundColor = .secondarySystemGroupedBackground
            shareOutputButton.layer.cornerRadius = 35 / 2
        } else {
            shareOutputButton.setTitle("Share", for: .normal)
        }
        shareOutputButton.addTarget(self, action: #selector(shareText(_:)), for: .touchUpInside)
		shareOutputButton.isPointerInteractionEnabled = true
        shareOutputButton.translatesAutoresizingMaskIntoConstraints = false
        shareOutputButton.isEnabled = false
		outputBackground.insertSubview(shareOutputButton, aboveSubview: generatedLinkTextView)
		if runningOn == .mac {
			shareOutputButton.topAnchor.constraint(
				equalTo: generatedLinkTextView.bottomAnchor,
				constant: 10
			).isActive = true
		}
        if runningOn != .iOS {
            NSLayoutConstraint.activate([
                shareOutputButton.bottomAnchor.constraint(
                    equalTo: outputBackground.bottomAnchor,
                    constant: -20
                ),
                shareOutputButton.trailingAnchor.constraint(
                    equalTo: copyOutputButton.leadingAnchor,
                    constant: -10
                )
            ])
        } else {
            NSLayoutConstraint.activate([
                shareOutputButton.topAnchor.constraint(
                    equalTo: outputBackground.topAnchor,
                    constant: 15
                ),
                shareOutputButton.trailingAnchor.constraint(
                    equalTo: copyOutputButton.leadingAnchor,
                    constant: -15
                )
            ])
        }
        
        
        
        if runningOn == .mac {
			if useAppleScript {
				openTerminalButton.setTitle("Run in Terminal", for: .normal)
				openTerminalButton.toolTip = "Run the generated command in Terminal"
			} else {
				openTerminalButton.setTitle("Copy and Open Terminal", for: .normal)
				openTerminalButton.toolTip = "Copies the command to your clipboard and opens Terminal"
			}
            openTerminalButton.addTarget(self, action: #selector(openTerminal(_:)), for: .touchUpInside)
            openTerminalButton.translatesAutoresizingMaskIntoConstraints = false
            outputBackground.addSubview(openTerminalButton)
            openTerminalButton.isEnabled = false
            NSLayoutConstraint.activate([
                openTerminalButton.topAnchor.constraint(
                    equalTo: generatedLinkTextView.bottomAnchor,
                    constant: 10
                ),
                openTerminalButton.bottomAnchor.constraint(
                    equalTo: outputBackground.bottomAnchor,
                    constant: -20
                ),
                openTerminalButton.trailingAnchor.constraint(
                    equalTo: shareOutputButton.leadingAnchor,
                    constant: -10
                )
            ])
        }
        
        
        
        // BASIC INTERFACE STUFF
        // Background colors of view and elements
        if runningOn == .iOS {
            view.backgroundColor = .systemGroupedBackground
//            fileFormatSelector.backgroundColor = .tintColor.withAlphaComponent(0.3)
            fileFormatSelector.tintColor = .tintColor
            fileFormatSelector.selectedSegmentTintColor = .tintColor.withAlphaComponent(0.4)
        } else if runningOn == .mac {
            self.view.backgroundColor = .clear
            self.view.isOpaque = false
        }
        generatedLinkTextView.text = "Waiting for input..."
        generatedLinkTextView.contentInset = .zero
        DispatchQueue.main.async {
            self.generatedLinkTextView.font = UIFont.monospacedSystemFont(ofSize: runningOn == .mac ? 16 : 20, weight: .medium)
        }

		let infoButton: UIBarButtonItem = tintedBarButton(imageName: "info", toolTip: "Open App Info", action: UIAction() { _ in
            self.openAbout()
        })
        infoButton.title = "Open App Info"
		
		let resetButton = tintedBarButton(imageName: "arrow.counterclockwise", toolTip: "Reset Input", action: UIAction() { _ in
            self.resetView()
			heavyHaptics()
        })
        resetButton.title = "Reset Input"
		
        navigationItem.rightBarButtonItems = [infoButton, resetButton]
    
        
        if runningOn == .iOS {
            let alwaysBlurredAppearance = UINavigationBarAppearance()
            alwaysBlurredAppearance.backgroundEffect = UIBlurEffect(style: .systemThickMaterial)
            self.navigationController?.navigationBar.standardAppearance = alwaysBlurredAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = alwaysBlurredAppearance
            
            self.navigationController?.navigationBar.prefersLargeTitles = false
            
            iOSTitleLabel.textColor = .label
            iOSTitleLabel.text = "FFmpeg Command Generator"
            self.title = ""
            iOSTitleLabel.numberOfLines = 2
            iOSTitleLabel.font = UIFont.systemFont(ofSize: (runningOn == .mac) ? 18 : 28, weight: .bold)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: iOSTitleLabel)
            self.navigationController?.additionalSafeAreaInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
		} 
		
		compactHeightConstraint = mainContentView.heightAnchor.constraint(equalToConstant: 494.5)
		wideHeightConstraint = mainContentView.heightAnchor.constraint(equalToConstant: 375.9)
		
        updateInterfaceForCompactness()

        
    }
    
//    @objc func keyboardWillShow(_ notification: Notification) {
//        if runningOn == .iOS {
//            keyboardIsShowing = true
//            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//                mainScrollView.isScrollEnabled = true
//                mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 105, right: 0)
//            }
//        }
//    }
//    
//    @objc func keyboardWillHide(_ notification: Notification) {
//        if runningOn == .iOS {
//            keyboardIsShowing = false
//            if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//                mainScrollView.isScrollEnabled = true
////                mainScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                mainScrollView.setContentOffset(CGPoint.zero, animated: true)
//                mainScrollView.isScrollEnabled = traitCollection.horizontalSizeClass == .compact
//            }
//        }
//    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        keyboardIsShowing = true
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.mainScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        mainScrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        keyboardIsShowing = false
        mainScrollView.contentInset = .zero
    }
    
    
}

extension String {
    func parsedForTerminal() -> String {
        return "'" + self.replacingOccurrences(of: "'", with: "'\''") + "'"
    }
}

func parseTextForTerminal(_ text: String) -> String {
    return "'" + text.replacingOccurrences(of: "'", with: "'\''") + "'"
}


func interpretJSON(forObject object: String, jsonData: Any) -> String? {
	if let jsonDictionary = jsonData as? [String: Any] {
		if let objectValue = jsonDictionary[object] {
			if let stringValue = objectValue as? String {
				return stringValue
			} else if let numberValue = objectValue as? NSNumber {
				return numberValue.stringValue
			} else {
				print("Error: Value for object '\(object)' is not a String or a Number.")
			}
		} else {
			print("Error: Object '\(object)' not found in the JSON dictionary.")
		}
	} else {
		print("Error: jsonData is not a valid NSDictionary.")
	}
	return nil
}
