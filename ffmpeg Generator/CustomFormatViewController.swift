//
//  CustomFormatViewController.swift
//  ffmpeg Generator
//
//  Created by Dylan McDonald on 10/25/22.
//

import UIKit

class CustomFormatViewController: UIViewController, UITextFieldDelegate {

	var titleLabel = UILabel()
	var macTitleLabel = UILabel()
	var formatField = standardTextField(withPlaceholder: ".mov, .mp4, etc.")
	var saveButton = UIButton(configuration: .filled())
	var cancelButton = UIButton(configuration: .gray())

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		
		
		// Nav Bar
		if runningOn == .iOS {
			let alwaysBlurredAppearance = UINavigationBarAppearance()
			alwaysBlurredAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
			alwaysBlurredAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
			self.navigationController?.navigationBar.standardAppearance = alwaysBlurredAppearance
			self.navigationController?.navigationBar.scrollEdgeAppearance = alwaysBlurredAppearance
			self.navigationController?.navigationBar.prefersLargeTitles = false
			let iOSTitleLabel = UILabel()
			iOSTitleLabel.textColor = .label
			iOSTitleLabel.text = "Custom Format"
			self.title = ""
			iOSTitleLabel.numberOfLines = 2
			iOSTitleLabel.font = UIFont.systemFont(ofSize: (runningOn == .mac) ? 18 : 22, weight: .bold)
			self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: iOSTitleLabel)
			
			view.backgroundColor = .systemGroupedBackground
		} 
		
		preferredContentSize = (view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))
		
	}

	override func viewWillAppear(_ animated: Bool) {
		formatField.becomeFirstResponder()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
	
	@objc func dismissViewEscape() {
		dismiss(animated: true, completion: nil)
	}

 	@objc func save(_ sender: Any) {
		UserDefaults.standard.set(formatField.text, forKey: "Custom File Format")
		dismiss(animated: true, completion: nil)
	}

	@objc func cancel(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}


	func setupView() {
		if runningOn != .iOS {
			macTitleLabel.text = "Custom Format"
			macTitleLabel.font = UIFont.systemFont(ofSize: runningOn == .mac ? 16 : 25, weight: runningOn == .mac ? .semibold : .bold)
			macTitleLabel.textAlignment = .left
			macTitleLabel.textColor = .label
			macTitleLabel.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(macTitleLabel)
			
			NSLayoutConstraint.activate([
				macTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
				macTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
				macTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
			])
		}
		
		titleLabel.text = "Enter a custom file format:"
		titleLabel.font = UIFont.systemFont(ofSize: runningOn == .mac ? 14 : 20, weight: runningOn == .mac ? .medium : .semibold)
		titleLabel.textAlignment = .left
		titleLabel.textColor = .label
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleLabel)
		
		if runningOn == .iOS {
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
		} else {
			titleLabel.topAnchor.constraint(equalTo: macTitleLabel.bottomAnchor, constant: 5).isActive = true
		}

		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
		])
		
		formatField.text = UserDefaults.standard.string(forKey: "Custom File Format") ?? ""
		formatField.font = UIFont.systemFont(ofSize: runningOn == .mac ? 13 : 17, weight: .regular)
		if runningOn == .iOS {
			formatField.backgroundColor = .secondarySystemGroupedBackground
		}
		formatField.textColor = .label
		formatField.autocapitalizationType = .none
		formatField.autocorrectionType = .no
		formatField.clearButtonMode = .whileEditing
		formatField.tintColor = .tintColor
		formatField.keyboardType = .webSearch
		formatField.returnKeyType = .done
		formatField.delegate = self
		formatField.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(formatField)

		NSLayoutConstraint.activate([
			formatField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
			formatField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			formatField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			formatField.widthAnchor.constraint(equalToConstant: 360)
		])
		
		if runningOn == .iOS {
			var configuration = UIButton.Configuration.tinted()
			configuration.cornerStyle = .large
			saveButton = UIButton(configuration: configuration)
		}
		saveButton.setTitle("Save", for: .normal)
		saveButton.isPointerInteractionEnabled = true
		saveButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
		if runningOn != .mac {
			saveButton.tintColor = .accent
		}
		saveButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(saveButton)

		NSLayoutConstraint.activate([
			saveButton.topAnchor.constraint(equalTo: formatField.bottomAnchor, constant: 20),
			saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
		])
		
		if runningOn == .iOS {
			var configuration = UIButton.Configuration.gray()
			configuration.cornerStyle = .large
			cancelButton = UIButton(configuration: configuration)
		}
		cancelButton.setTitle("Cancel", for: .normal)
		cancelButton.isPointerInteractionEnabled = true
		cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
		if runningOn != .mac {
			cancelButton.tintColor = .accent
		}
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(cancelButton)

		NSLayoutConstraint.activate([
			cancelButton.topAnchor.constraint(equalTo: formatField.bottomAnchor, constant: 20),
			cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -10),
			cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor)
		])

		if runningOn != .mac {
			cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
		}
		
		if traitCollection.horizontalSizeClass != .compact {
			NSLayoutConstraint.activate([
				saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
				cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
			])
		}
		
	
	}



}
