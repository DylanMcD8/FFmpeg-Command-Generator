//
//  DynamicIslandView.swift
//  Dynamic Island Test
//
//  Created by Dylan McDonald on 1/5/24.
//

import UIKit

let DYNAMIC_ISLAND_PILL_HEIGHT = 36.8
let DYNAMIC_ISLAND_PILL_WIDTH = 125.3
let DYNAMIC_ISLAND_SPACING = 11.15

class DynamicIslandView: UIView {
	
	private var _isExpandedPublic: Bool = false 
	private var _isExpandedPrivate: Bool = false
	private var _preferredHeight: Double!
	
	private var senderView: UIWindow!
	private var viewForStatusBar: UIViewController?
	private var internalView: DynamicIslandInternalView = DynamicIslandInternalView(imageName: "checkmark.circle.fill", titleString: "Command Copied!")
	private var internalViewMask = UIView()
	private var hardwareCapsuleOverlay = UIView()
	
	private var heightConstraint = NSLayoutConstraint()
	private var widthConstraint = NSLayoutConstraint()
	private var topConstraint = NSLayoutConstraint()
	private var leadingConstraint = NSLayoutConstraint()
	private var trailingConstraint = NSLayoutConstraint()
	
	private var internalViewTopConstraint = NSLayoutConstraint()
	
	private var expandedCapsuleRadius: CGFloat {
		//		return (self.senderView.window?.screen.displayCornerRadius ?? 55) - DYNAMIC_ISLAND_SPACING
		// Corner radius of the screen (thus far, always 55 for devices with Dynamic Island) minus the inset of the Dynamic Island cutout (11.2)
		return 55 - DYNAMIC_ISLAND_SPACING
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	// For use when adding to a specific ViewController
	//	convenience init(senderView: UIViewController, preferredHeight: Double = -1.01) {
	//		self.init(frame: .zero)
	//		self.senderView = senderView
	//		if preferredHeight == -1.01 {
	//			self._preferredHeight = expandedCapsuleRadius * 2
	//		} else {
	//			self._preferredHeight = preferredHeight
	//		}
	//		setupView()
	//	}
	
	// For use when adding to the window
	convenience init(senderWindow: UIWindow, preferredHeight: Double = -1.01) {
		self.init(frame: .zero)
		self.senderView = senderWindow
		if preferredHeight == -1.01 {
			self._preferredHeight = expandedCapsuleRadius * 2
		} else {
			self._preferredHeight = preferredHeight
		}
		if runningOn == .mac {
			self._preferredHeight = self._preferredHeight * 0.77
		}
		setupView()
	}
	
	
	private func setupView() {
		if let senderView {
			self.backgroundColor = hasDynamicIsland() ? .black : .clear
			self.layer.masksToBounds = false
			
			// Capsule shape and corner radius
			if hasDynamicIsland() {
				self.layer.cornerCurve = .circular
				self.layer.cornerRadius = DYNAMIC_ISLAND_PILL_HEIGHT / 2
			} else {
				self.layer.cornerCurve = .continuous
				if runningOn == .iOS {
					self.layer.cornerRadius = 20
				} else if runningOn == .mac {
					self.layer.cornerRadius = 15
				} else if runningOn == .vision {
					self.layer.cornerRadius = 25
				}
				// Add border for nicer design on blur view
				self.layer.borderWidth = 1
				self.layer.borderColor = UIColor.systemFill.cgColor
			}
			
			self.layer.shadowOffset = CGSize(width: 0, height: 6)
			self.layer.shadowRadius = 15
			self.layer.shadowOpacity = 0
			self.layer.shadowColor = UIColor.black.cgColor
			
			if hasDynamicIsland() {
				self.alpha = 0
			}
			addToSenderSubview()
			
			// Add Internal View Mask
			internalViewMask.backgroundColor = .clear
			internalViewMask.clipsToBounds = true
			if hasDynamicIsland() {
				internalViewMask.layer.cornerCurve = .circular
				internalViewMask.layer.cornerRadius = DYNAMIC_ISLAND_PILL_HEIGHT / 2
			} else {
				internalViewMask.layer.cornerCurve = .continuous
				if runningOn == .iOS {
					internalViewMask.layer.cornerRadius = 20
				} else if runningOn == .mac {
					internalViewMask.layer.cornerRadius = 15
				} else if runningOn == .vision {
					internalViewMask.layer.cornerRadius = 25
				}
			}
			internalViewMask.translatesAutoresizingMaskIntoConstraints = false
			addSubview(internalViewMask)
			
			NSLayoutConstraint.activate([
				internalViewMask.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
				internalViewMask.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
				internalViewMask.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
				internalViewMask.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
				internalViewMask.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0)
			])
			
			// Add Blur View 
			if !hasDynamicIsland() {
				let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
				blurView.translatesAutoresizingMaskIntoConstraints = false
				internalViewMask.addSubview(blurView)
				NSLayoutConstraint.activate([
					blurView.topAnchor.constraint(equalTo: internalViewMask.topAnchor, constant: 0),
					blurView.bottomAnchor.constraint(equalTo: internalViewMask.bottomAnchor, constant: 0),
					blurView.leadingAnchor.constraint(equalTo: internalViewMask.leadingAnchor, constant: 0),
					blurView.trailingAnchor.constraint(equalTo: internalViewMask.trailingAnchor, constant: 0)
				])
			}
			
			// Add Internal View
			internalView.translatesAutoresizingMaskIntoConstraints = false
			internalViewMask.addSubview(internalView)
			
			if hasDynamicIsland() {
				NSLayoutConstraint.activate([
					internalView.leadingAnchor.constraint(equalTo: senderView.leadingAnchor, constant: DYNAMIC_ISLAND_SPACING * 2),
					internalView.trailingAnchor.constraint(equalTo: senderView.trailingAnchor, constant: -DYNAMIC_ISLAND_SPACING * 2),
					internalView.heightAnchor.constraint(equalToConstant: _preferredHeight - DYNAMIC_ISLAND_SPACING * 2),
					internalView.centerXAnchor.constraint(equalTo: senderView.centerXAnchor)
				])
			} else {
				NSLayoutConstraint.activate([
					internalView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: DYNAMIC_ISLAND_SPACING),
					internalView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -DYNAMIC_ISLAND_SPACING ),
					internalView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -DYNAMIC_ISLAND_SPACING),
					internalView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
				])
			}
			
			if hasDynamicIsland() {
				internalViewTopConstraint = NSLayoutConstraint(item: self.internalView, attribute: .top, relatedBy: .equal, toItem: senderView, attribute: .top, multiplier: 1, constant: -10)
			} else {
				internalViewTopConstraint = NSLayoutConstraint(item: self.internalView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: DYNAMIC_ISLAND_SPACING)
			}
			
			internalViewTopConstraint.isActive = true
			
			if hasDynamicIsland() {
				internalView.alpha = 0
				internalView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
			}
			
			
			if hasDynamicIsland() {
				hardwareCapsuleOverlay.translatesAutoresizingMaskIntoConstraints = false
				hardwareCapsuleOverlay.backgroundColor = .black
				internalViewMask.addSubview(hardwareCapsuleOverlay)
				
				NSLayoutConstraint.activate([
					hardwareCapsuleOverlay.heightAnchor.constraint(equalToConstant: DYNAMIC_ISLAND_PILL_HEIGHT),
					hardwareCapsuleOverlay.widthAnchor.constraint(equalToConstant: DYNAMIC_ISLAND_PILL_WIDTH),
					hardwareCapsuleOverlay.centerXAnchor.constraint(equalTo: self.centerXAnchor),
					hardwareCapsuleOverlay.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.5)
				])
				
				hardwareCapsuleOverlay.layer.cornerCurve = .circular
				hardwareCapsuleOverlay.layer.shadowOpacity = 0.9
				hardwareCapsuleOverlay.layer.cornerRadius = DYNAMIC_ISLAND_PILL_HEIGHT / 2
				hardwareCapsuleOverlay.layer.shadowColor = UIColor.black.cgColor
				hardwareCapsuleOverlay.layer.shadowRadius = 6
				hardwareCapsuleOverlay.layer.shadowOffset = CGSize(width: 0, height: 3)
				hardwareCapsuleOverlay.alpha = 0
			}
			
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Returns `true` if the `DynamicIslandView` is currently expanded, otherwise false.
	func isExpanded() -> Bool {
		return _isExpandedPublic
	}
	
//#warning("This isn't ready for end-user use!")
	/// Set the preferred height of the `DynamicIslandView`. Set -1.01 for 
	func setPreferredHeight(_ with: Double) {
		self._preferredHeight = with
	}
	
	func setViewForStatusBar(_ view: UIViewController) {
		self.viewForStatusBar = view
	}
	
	
	/// Adds the `DynamicIslandView` to the `subview` of the sender and sets up the necessary constraints.
	func addToSenderSubview() {
		if let senderView {
			self.translatesAutoresizingMaskIntoConstraints = false
			senderView.addSubview(self)
			
			NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: senderView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
			
			if hasDynamicIsland() {
				// Set to the capsule height and width for start of animation
				heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: DYNAMIC_ISLAND_PILL_HEIGHT)
				// Place at position of Dynamic Island
				topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: senderView, attribute: .top, multiplier: 1, constant: DYNAMIC_ISLAND_SPACING)
			} else {
				// Set to preferred height since it doesn't need to animate out of the pill
				heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: _preferredHeight)
				
				// Place a little above Safe Area. Will move to proper area at time of animation.
				topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: senderView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: -50)
				
			}
			
			let forceWidth = senderView.frame.width < 440 || hasDynamicIsland()
			
			// Shouldn't end up being used on non-Dynamic Island device
			widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: DYNAMIC_ISLAND_PILL_WIDTH)
			// Fixes bug with a reported conflict with internally supplied constraint, even though they don't actually conflict
			widthConstraint.priority = UILayoutPriority(999)
			
			leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: forceWidth ? .equal : .greaterThanOrEqual, toItem: senderView, attribute: .leading, multiplier: 1, constant: DYNAMIC_ISLAND_SPACING)
			trailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: forceWidth ? .equal : .lessThanOrEqual, toItem: senderView, attribute: .trailing, multiplier: 1, constant: -DYNAMIC_ISLAND_SPACING)
			
			topConstraint.isActive = true
			// Fixed width will never be used without the Dynamic Island
			widthConstraint.isActive = hasDynamicIsland()
			heightConstraint.isActive = true
			leadingConstraint.isActive = !hasDynamicIsland()
			trailingConstraint.isActive = !hasDynamicIsland()
			
			if !hasDynamicIsland() {
				self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
			}
			
			self.alpha = 0
		}
	}
	
	/// Expands the `DynamicIslandView`.
	func expandIsland(collapseDelay: Double = 0) {
		if senderView != nil && _isExpandedPrivate == false {
			_isExpandedPrivate = true
			_isExpandedPublic = true
			if hasDynamicIsland() {
				widthConstraint.isActive = false
				leadingConstraint.isActive = true
				trailingConstraint.isActive = true
				self.alpha = 1
				heightConstraint.constant = expandedCapsuleRadius * 2
				
				internalViewTopConstraint.constant = DYNAMIC_ISLAND_SPACING * 2
			} else {
				switch runningOn {
				case .iOS:
					topConstraint.constant = 5
				case .mac :
					topConstraint.constant = 10
				case .vision:
					topConstraint.constant = 50
				}
			}
			
			UIView.animate(withDuration: 0.2) {
				if hasDynamicIsland() {
					self.hardwareCapsuleOverlay.alpha = 1
				}
				#if !os(visionOS)
				self.viewForStatusBar?.setNeedsStatusBarAppearanceUpdate()
				//				self.senderView.rootViewController?.setNeedsStatusBarAppearanceUpdate()
//				NotificationCenter.default.post(name: Notification.Name("UpdateStatusBar"), object: nil)
				#endif
			}
			
			
			UIView.animate(withDuration: hasDynamicIsland() ? 0.7 : 0.55, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: [.curveEaseInOut, .beginFromCurrentState]) { [self] in
				senderView.layoutIfNeeded()
				if hasDynamicIsland() {
					self.layer.cornerRadius = expandedCapsuleRadius
					self.internalViewMask.layer.cornerRadius = expandedCapsuleRadius
					self.internalView.alpha = 1
					internalView.transform = CGAffineTransform.identity
				} else {
					self.alpha = 1
					self.transform = CGAffineTransform.identity
				}
				self.layer.cornerCurve = .continuous
				self.layer.shadowOpacity = 0.6
				
			} completion: { _ in 
				if hasDynamicIsland() {
					UIView.animate(withDuration: 0.2) {
						self.hardwareCapsuleOverlay.alpha = 0
					} completion: { _ in
						if collapseDelay > 0 {
							self.collapseIsland(withDelay: collapseDelay)
						}
					}
				} else {
					if collapseDelay > 0 {
						self.collapseIsland(withDelay: collapseDelay)
					}
				}
			}
			
		}
	}
	
	/// Collapses the `DynamicIslandView`.
	func collapseIsland(withDelay: Double = 0) {
		if senderView != nil && _isExpandedPrivate == true {
			if hasDynamicIsland() {
				widthConstraint.isActive = true
				widthConstraint.constant = DYNAMIC_ISLAND_PILL_WIDTH
				heightConstraint.constant = DYNAMIC_ISLAND_PILL_HEIGHT
				// Should always remain active for devices without Dynamic Island
				leadingConstraint.isActive = false
				trailingConstraint.isActive = false
				
				internalViewTopConstraint.constant = -10
			} else {
				self.topConstraint.constant = -50
			}
			
			UIView.animate(withDuration: 0.2, delay: withDelay) {
				if hasDynamicIsland() {
					self.hardwareCapsuleOverlay.alpha = 1
				}
			} completion: { _ in
				UIView.animate(withDuration: 0.2) {
					self._isExpandedPublic = false
					#if !os(visionOS)
					self.viewForStatusBar?.setNeedsStatusBarAppearanceUpdate()
//					self.senderView.rootViewController?.setNeedsStatusBarAppearanceUpdate()
//					NotificationCenter.default.post(name: Notification.Name("UpdateStatusBar"), object: nil)
					#endif
				}
			}
			
			UIView.animate(withDuration: hasDynamicIsland() ? 0.7 : 0.55, delay: withDelay, usingSpringWithDamping: 0.8, initialSpringVelocity: -0.7, options: [.curveEaseInOut, .beginFromCurrentState]) { [self] in
				self.senderView.layoutIfNeeded()
				if hasDynamicIsland() {
					self.layer.cornerRadius = DYNAMIC_ISLAND_PILL_HEIGHT / 2
					self.internalViewMask.layer.cornerRadius = DYNAMIC_ISLAND_PILL_HEIGHT / 2
					self.internalView.alpha = 0
					self.internalView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
				} else {
					self.alpha = 0
					self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
				}
				self.layer.shadowOpacity = 0
			} completion: { _ in 
				self._isExpandedPrivate = false
				if hasDynamicIsland() {
					UIView.animate(withDuration: 0.2) {
						self.hardwareCapsuleOverlay.alpha = 0
						self.alpha = 0
					}
				}
				if !self._isExpandedPrivate {
					if hasDynamicIsland() {
						self.layer.cornerCurve = .circular
						self.layer.cornerRadius = DYNAMIC_ISLAND_PILL_HEIGHT / 2
						self.internalViewMask.layer.cornerRadius = DYNAMIC_ISLAND_PILL_HEIGHT / 2
					}
					self.alpha = 0
				}
			}
		}
	}
	
	/// Expands the `DynamicIslandView`, if it's collapsed, or collapses it if it's expanded.
	func toggleIsland() {
		if _isExpandedPublic {
			collapseIsland()
		} else {
			expandIsland()
		}
	}
	
	func containsDynamicIsland() -> Bool {
#if os(visionOS)
		return false
#else
		return UIScreen.main.bounds.height == 852 || UIScreen.main.bounds.height == 932 
#endif
	}
	
	func setTitle(_ with: String) {
		if isExpanded() {
			UIView.animate(withDuration: 0.2) {
				self.internalView.setTitle(with)
				self.layoutIfNeeded()
			}
		} else {
			internalView.setTitle(with)
			self.layoutIfNeeded()
		}
	} 
	
	func setImageName(_ with: String) {
		internalView.setImageName(with)
	}
	
	func setImageTintColor(_ with: UIColor) {
		internalView.setImageTintColor(with)
	}
	
}

func hasDynamicIsland() -> Bool {
#if os(visionOS)
	return false
#else
	return UIScreen.main.bounds.height == 852 || UIScreen.main.bounds.height == 932 
#endif
}


private class DynamicIslandInternalView: UIView {
	var imageView = UIImageView()
	
	var titleLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	convenience init(imageName: String, titleString: String, imageTintColor: UIColor = .tintColor) {
		self.init(frame: .zero)
		setupView(imageName: imageName, titleString: titleString, imageTintColor: imageTintColor)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setTitle(_ title: String) {
		titleLabel.text = title
	}
	
	func setImageName(_ imageName: String) {
		let config = UIImage.SymbolConfiguration(hierarchicalColor: .tintColor)
		imageView.image = (UIImage(systemName: imageName) ?? UIImage(systemName: "xmark.circle.fill")!).applyingSymbolConfiguration(config)
	}
	
	func setImageTintColor(_ imageTintColor: UIColor) {
		imageView.tintColor = imageTintColor
		let config = UIImage.SymbolConfiguration(hierarchicalColor: .tintColor)
		imageView.image = imageView.image?.applyingSymbolConfiguration(config)
	}
	
	private func setupView(imageName: String, titleString: String, imageTintColor: UIColor) {
		imageView.tintColor = imageTintColor
		let config = UIImage.SymbolConfiguration(hierarchicalColor: .tintColor)
		imageView.image = (UIImage(systemName: imageName) ?? UIImage(systemName: "xmark.circle.fill")!).applyingSymbolConfiguration(config)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		addSubview(imageView)
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: self.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
		])
		
		
		titleLabel.text = titleString
		titleLabel.textColor = hasDynamicIsland() ? .white : .label
		titleLabel.minimumScaleFactor = 0.3
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.font = UIFont.systemFont(ofSize: runningOn == .mac ? 19 : 25, weight: .semibold)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)
		
		NSLayoutConstraint.activate([		
			titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: DYNAMIC_ISLAND_SPACING),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DYNAMIC_ISLAND_SPACING)
		])
		
		if hasDynamicIsland() {
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
			titleLabel.numberOfLines = 1
		} else {
			titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: DYNAMIC_ISLAND_SPACING).isActive = true
			titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
			titleLabel.numberOfLines = 2
		}
	}
	
}

extension UIColor {
	
	func add(overlay: UIColor) -> UIColor {
		var bgR: CGFloat = 0
		var bgG: CGFloat = 0
		var bgB: CGFloat = 0
		var bgA: CGFloat = 0
		
		var fgR: CGFloat = 0
		var fgG: CGFloat = 0
		var fgB: CGFloat = 0
		var fgA: CGFloat = 0
		
		self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
		overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)
		
		let r = fgA * fgR + (1 - fgA) * bgR
		let g = fgA * fgG + (1 - fgA) * bgG
		let b = fgA * fgB + (1 - fgA) * bgB
		
		return UIColor(red: r, green: g, blue: b, alpha: 1.0)
	}
}
