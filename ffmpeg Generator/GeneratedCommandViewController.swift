//
//  GeneratedCommandViewController.swift
//  FFmpeg Generator
//
//  Created by Dylan McDonald on 8/22/23.
//

import UIKit

class GeneratedCommandViewController: UIViewController {
    
    var commandToShow: String = ""
    
    var generatedLinkTextView = UITextView()
    var copyOutputButton = UIButton(configuration: .filled())
    var shareOutputButton = UIButton(configuration: .filled())
	
	var senderView: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground

        let alwaysBlurredAppearance = UINavigationBarAppearance()
		alwaysBlurredAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        self.navigationController?.navigationBar.standardAppearance = alwaysBlurredAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = alwaysBlurredAppearance
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        let iOSTitleLabel = UILabel()
        iOSTitleLabel.textColor = .label
        iOSTitleLabel.text = "Generated Command"
        self.title = ""
        iOSTitleLabel.numberOfLines = 2
        iOSTitleLabel.font = UIFont.systemFont(ofSize: (runningOn == .mac) ? 18 : 22, weight: .bold)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: iOSTitleLabel)
//        self.navigationController?.additionalSafeAreaInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        
        self.navigationItem.rightBarButtonItems = [closeBarButton(action: UIAction() { _ in
            self.dismiss(animated: true)
        })]
        
        generatedLinkTextView.text = commandToShow
        generatedLinkTextView.backgroundColor = .secondarySystemGroupedBackground
        generatedLinkTextView.layer.cornerRadius = 15
        generatedLinkTextView.layer.cornerCurve = .continuous
        generatedLinkTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        generatedLinkTextView.isEditable = false
        generatedLinkTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(generatedLinkTextView)
        NSLayoutConstraint.activate([
            generatedLinkTextView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            generatedLinkTextView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            generatedLinkTextView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            )
        ])
        
        
        if runningOn != .mac {
            var configuration = UIButton.Configuration.tinted()
            configuration.cornerStyle = .large
            if runningOn != .vision {
                configuration.baseForegroundColor = .tintColor
            }
            configuration.image = UIImage(systemName: "doc.on.clipboard")
            configuration.imagePadding = 5
            configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 0, weight: .semibold, scale: .medium)
            copyOutputButton = UIButton(configuration: configuration)
        }
        copyOutputButton.setTitle("Copy Text", for: .normal)
        copyOutputButton.addTarget(self, action: #selector(copyText(_:)), for: .touchUpInside)
		copyOutputButton.isPointerInteractionEnabled = true
        copyOutputButton.translatesAutoresizingMaskIntoConstraints = false
        copyOutputButton.role = .primary
        view.addSubview(copyOutputButton)
        NSLayoutConstraint.activate([
            copyOutputButton.topAnchor.constraint(
                equalTo: generatedLinkTextView.bottomAnchor,
                constant: 20
            ),
            copyOutputButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            copyOutputButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            copyOutputButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        if runningOn != .mac {
            var configuration = UIButton.Configuration.tinted()
            configuration.cornerStyle = .large
            if runningOn != .vision {
                configuration.baseForegroundColor = .tintColor
            }
            configuration.image = UIImage(systemName: "square.and.arrow.up")
            configuration.imagePadding = 5
            configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 0, weight: .semibold, scale: .medium)
            shareOutputButton = UIButton(configuration: configuration)
        }
        shareOutputButton.setTitle("Share Text", for: .normal)
        shareOutputButton.addTarget(self, action: #selector(shareText(_:)), for: .touchUpInside)
		shareOutputButton.isPointerInteractionEnabled = true
        shareOutputButton.translatesAutoresizingMaskIntoConstraints = false
        shareOutputButton.role = .primary
        view.addSubview(shareOutputButton)
        NSLayoutConstraint.activate([
            shareOutputButton.topAnchor.constraint(
                equalTo: generatedLinkTextView.bottomAnchor,
                constant: 20
            ),
            shareOutputButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            shareOutputButton.trailingAnchor.constraint(
                equalTo: copyOutputButton.leadingAnchor,
                constant: -20
            ),
            shareOutputButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            shareOutputButton.heightAnchor.constraint(equalToConstant: 50),
            shareOutputButton.widthAnchor.constraint(equalTo: copyOutputButton.widthAnchor)
        ])
        
        DispatchQueue.main.async {
            self.generatedLinkTextView.font = UIFont.monospacedSystemFont(ofSize: runningOn == .mac ? 16 : 15, weight: .medium)
        }
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		if let bannerView = BannerManager.shared.banner(for: self.view.window!) {
			bannerView.setViewForStatusBar(self.senderView?.navigationController ?? self)
		}
	}
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { [self] in
            if viewIfLoaded != nil {
                self.generatedLinkTextView.font = UIFont.monospacedSystemFont(ofSize: self.generatedLinkTextView.font!.pointSize, weight: .medium)
            }
        }
    }
	
	@objc func dismissViewEscape() {
		dismiss(animated: true, completion: nil)
	}
    
    @objc func copyText(_ sender: Any) {
        UIPasteboard.general.string = generatedLinkTextView.text ?? ""
		if let bannerView = BannerManager.shared.banner(for: self.view.window!) {
			bannerView.setViewForStatusBar(self.navigationController ?? self)
			bannerView.setTitle("Command Copied!")
			bannerView.setImageName("paperclip.circle.fill")
			bannerView.expandIsland(collapseDelay: 3)
		}
		successHaptics()
    }
    
    @objc func shareText(_ sender: Any) {
        let items = [generatedLinkTextView.text ?? ""]

        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.shareOutputButton
        ac.popoverPresentationController?.sourceRect = self.shareOutputButton.bounds
        self.present(ac, animated: true)
    }

}
