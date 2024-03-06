//
//  Standard Views.swift
//  ffmpeg Generator
//
//  Created by Dylan McDonald on 10/25/22.
//

import Foundation
import UIKit

class GrayButton: UIButton {
	override func draw(_ rect: CGRect) {
#if targetEnvironment(macCatalyst)
		let title = self.configuration?.title ?? ""
		let subtitle = self.configuration?.subtitle ?? ""
		let image = self.configuration?.image ?? .none
		let imagePlacement = self.configuration?.imagePlacement ?? .trailing
		let imagePadding = self.configuration?.imagePadding ?? 5
		
		self.configuration = UIButton.Configuration.plain()
		self.configuration?.title = title
		self.configuration?.subtitle = subtitle
		self.configuration?.imagePlacement = imagePlacement
		self.configuration?.imagePadding = imagePadding
		
		if image != nil {
			self.configuration?.image = image
		}
#endif
	}
}


func MacView() -> UIView {
	
	var viewCornerRadius: CGFloat {
		switch runningOn {
		case .iOS:
			return 20
		case .mac: 
			return 10
		case .vision:
			return 25 /*45 - 20*/
		}
	}
	
	let view = UIView()
	if runningOn == .mac {
		view.backgroundColor = .separator.withAlphaComponent(0.05)
		view.layer.borderColor = UIColor.separator.cgColor
		view.layer.borderWidth = 1
	} else if runningOn == .iOS {
		view.backgroundColor = .secondarySystemGroupedBackground
	} else {
		view.backgroundColor = .systemGroupedBackground
	}
	
	view.layer.cornerRadius = viewCornerRadius
    view.layer.cornerCurve = .continuous
	view.clipsToBounds = true
	
	return view
}




class StandardCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let customBackgroundView = UIView()
		if runningOn == .mac {
			customBackgroundView.layer.cornerCurve = .continuous
			if runningOn == .mac {
				customBackgroundView.layer.cornerRadius = runningOn == .mac ? 5 : 30
			}
			customBackgroundView.backgroundColor = .separator.withAlphaComponent(0.05)
			customBackgroundView.layer.borderColor = UIColor.separator.cgColor
			customBackgroundView.layer.borderWidth = 1
			customBackgroundView.clipsToBounds = true
			self.backgroundView = customBackgroundView
			self.backgroundColor = .clear
		}
		
		if runningOn == .mac {
			let customBorderView = UIView()
			customBorderView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height + 10)
			customBorderView.backgroundColor = .clear
			customBorderView.tag = 365
			
			
			let selectedBackView = UIView()
			selectedBackView.layer.cornerCurve = .continuous
			selectedBackView.frame = self.frame
			if runningOn == .mac {
				selectedBackView.layer.cornerRadius = 5
				selectedBackView.backgroundColor = .separator.withAlphaComponent(0.1)
				selectedBackView.layer.borderColor = UIColor.separator.cgColor
				selectedBackView.layer.borderWidth = 1
			}
			selectedBackView.clipsToBounds = true
			self.selectedBackgroundView = selectedBackView
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(style: .subtitle, reuseIdentifier: "identifier")
	}
}

func closeBarButton(action: UIAction?) -> UIBarButtonItem {
    var configuration = runningOn == .vision ? UIButton.Configuration.borderless() : UIButton.Configuration.gray() // 1
    configuration.cornerStyle = .capsule // 2
    if runningOn != .vision {
        configuration.baseForegroundColor = .systemGray
    }
    configuration.image = UIImage(systemName: "xmark")
    configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 0, weight: .bold, scale: .medium)
    
    let closeButton = UIButton(configuration: configuration, primaryAction: action)
    closeButton.preferredBehavioralStyle = .pad
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    if runningOn != .vision {
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: runningOn == .mac ? 27 : 35),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor, multiplier: 1)
        ])
    }
    
    return UIBarButtonItem(customView: closeButton)
}

func tintedBarButton(imageName: String, toolTip: String, action: UIAction?) -> UIBarButtonItem {
    var configuration = runningOn == .mac ? UIButton.Configuration.borderless() : UIButton.Configuration.tinted()
    configuration.cornerStyle = .capsule
    if runningOn != .vision {
        configuration.baseForegroundColor = .tintColor
    }
    configuration.image = UIImage(systemName: imageName)
    configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 0, weight: .bold, scale: .medium)
    
	
    let closeButton = UIButton(configuration: configuration, primaryAction: action)
    closeButton.preferredBehavioralStyle = .pad
    closeButton.translatesAutoresizingMaskIntoConstraints = false
	closeButton.toolTip = toolTip
//    closeButton.setTitle(title, for: .normal)
    if runningOn == .iOS {
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: runningOn == .mac ? 27 : 35),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor, multiplier: 1)
        ])
    }
    
    return UIBarButtonItem(customView: closeButton)
}

func tintedCircleButton(imageName: String, action: UIAction?) -> UIButton {
    var configuration = runningOn == .iOS ? UIButton.Configuration.tinted() : UIButton.Configuration.borderless()
    configuration.cornerStyle = .capsule
    if runningOn != .vision {
        configuration.baseForegroundColor = .tintColor
    }
    configuration.image = UIImage(systemName: imageName)
    configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 0, weight: .bold, scale: .medium)
    
    let closeButton = UIButton(configuration: configuration, primaryAction: action)
    closeButton.preferredBehavioralStyle = .pad
    closeButton.translatesAutoresizingMaskIntoConstraints = false
//    closeButton.setTitle(title, for: .normal)
    if runningOn == .iOS {
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: runningOn == .mac ? 27 : 35),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor, multiplier: 1)
        ])
    }
    
    return closeButton
}


func closeButton(action: UIAction?) -> UIButton {
    var configuration = UIButton.Configuration.gray() // 1
    configuration.cornerStyle = .capsule // 2
    configuration.baseForegroundColor = .systemGray
    configuration.image = UIImage(systemName: "xmark")
    configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 0, weight: .bold, scale: .medium)
    
    let closeButton = UIButton(configuration: configuration, primaryAction: action)
    closeButton.preferredBehavioralStyle = .pad
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        closeButton.heightAnchor.constraint(equalToConstant: runningOn == .mac ? 27 : 35),
        closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor, multiplier: 1)
    ])
    
    return closeButton
}

func standardTextField(withPlaceholder: String) -> UITextField {
	let textField = UITextField()
	textField.borderStyle = .roundedRect
	textField.placeholder = withPlaceholder
	textField.font = .systemFont(ofSize: runningOn == .mac ? 14 : 17, weight: .medium)
	textField.textColor = .label
	textField.tintColor = .accent
	textField.clearButtonMode = .whileEditing
	if runningOn == .iOS {
		textField.backgroundColor = .tertiarySystemGroupedBackground
	}
	return textField
}




extension UIFont {
	func withOptions(weight: Double, width: Double) -> UIFont {
		let newDescriptor = fontDescriptor.addingAttributes([.traits: [
			UIFontDescriptor.TraitKey.weight: weight, UIFontDescriptor.TraitKey.width: width,
		]])
		return UIFont (descriptor: newDescriptor, size: pointSize)
	}
}

final class SheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var shouldShowGrabber: Bool = false

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let controller = UISheetPresentationController(presentedViewController: presented, presenting: presenting)
//        controller.preferredCornerRadius = 30
        #if !os(visionOS)
        controller.prefersScrollingExpandsWhenScrolledToEdge = true
        if source.traitCollection.horizontalSizeClass == .compact {
            controller.detents = [.medium(), .large()]
//            controller.largestUndimmedDetentIdentifier = .medium
        } else {
            controller.detents = [.large()]
        }
        if runningOn == .mac {
            controller.prefersGrabberVisible = false
        } else {
            controller.prefersGrabberVisible = shouldShowGrabber
        }
        #endif
        return controller
    }
}


func addReverseParallaxToView(view: UIView, amount: Float) {
	let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
	horizontal.minimumRelativeValue = amount
	horizontal.maximumRelativeValue = -amount
	
	let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
	vertical.minimumRelativeValue = amount
	vertical.maximumRelativeValue = -amount
	
	let group = UIMotionEffectGroup()
	group.motionEffects = [horizontal, vertical]
	view.addMotionEffect(group)
	
	NotificationCenter.default.addObserver(forName:  Notification.Name(rawValue: "UpdateParallax") , object: nil, queue: .main) { notification in
		UIView.animate(withDuration: 0.25) {
			view.removeMotionEffect(group)
		}
	}
}

func softHaptics() {
	#if !os(visionOS)
	UIImpactFeedbackGenerator(style: .soft).impactOccurred()
	#endif
}

func heavyHaptics() {
#if !os(visionOS)
	UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
#endif
}

func successHaptics() {
#if !os(visionOS)
	UINotificationFeedbackGenerator().notificationOccurred(.success)
#endif
}
