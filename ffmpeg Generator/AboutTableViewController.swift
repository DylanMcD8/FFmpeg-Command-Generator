
//
//  AboutTableViewController.swift
//  School Assistant
//
//  Created by Dylan McDonald on 6/14/20.
//  Copyright © 2020 Dylan McDonald. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var wordlerTitleLabel: UILabel!
    @IBOutlet weak var fromSunAppsLabel: UILabel!
    
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
    
    let cellIdentifier = "CellIdentifier"
    
    @objc func closeView() {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
		tableView.sectionFooterHeight = 8
		tableView.sectionHeaderHeight = 8
        
		if runningOn == .iOS {
			view.backgroundColor = .systemGroupedBackground
		}
        self.title = "About"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
        if runningOn == .mac {
            preferredContentSize = CGSize(width: 400, height: 523)
            self.navigationController?.isNavigationBarHidden = true
            self.view.backgroundColor = .clear
            self.tableView.isScrollEnabled = true
        } else if runningOn == .vision {
            let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeView))
            closeButton.title = "Close"
            self.navigationItem.leftBarButtonItem = closeButton
        } else {
			let alwaysBlurredAppearance = UINavigationBarAppearance()
			alwaysBlurredAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
			self.navigationController?.navigationBar.standardAppearance = alwaysBlurredAppearance
			self.navigationController?.navigationBar.scrollEdgeAppearance = alwaysBlurredAppearance
			self.navigationController?.navigationBar.prefersLargeTitles = false
			let iOSTitleLabel = UILabel()
			iOSTitleLabel.textColor = .label
			iOSTitleLabel.text = "About"
			self.title = ""
			iOSTitleLabel.numberOfLines = 2
			iOSTitleLabel.font = UIFont.systemFont(ofSize: (runningOn == .mac) ? 18 : 22, weight: .bold)
			self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: iOSTitleLabel)
			
			self.navigationItem.rightBarButtonItems = [closeBarButton(action: UIAction() { _ in
				self.dismiss(animated: true)
			})]
        }
    }
	
	@objc func dismissViewEscape() {
		dismiss(animated: true, completion: nil)
	}
    
    override init(style: UITableView.Style = .insetGrouped) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func goBack(_ sender:Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = ImageHeaderCell()
            cell.sourceView = self
			cell.selectionStyle = .none
			cell.isUserInteractionEnabled = runningOn == .mac
            return cell
		} else if indexPath.section == 1 {
			let cell = UseSpecklesBackgroundCell()
			cell.textLabel?.text = "Use Speckles Background"
			cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
			cell.imageView?.image = UIImage(systemName: "sparkles")
			cell.imageView?.preferredSymbolConfiguration = .init(hierarchicalColor: .accent)
			return cell
		} else {
			let cell = StandardCell(style: .subtitle, reuseIdentifier: "identifier")
            
            cell.tintColor = .accent
            
            switch indexPath.section {
            case 2:
                cell.textLabel?.text = "About Sun Apps"
                cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
                cell.detailTextLabel?.text = "Sun Apps is an independent app development company from New York, USA. It is run by student developer Dylan McDonald. If you need to contact me, send me an email using the option below."
                cell.detailTextLabel?.font = .preferredFont(forTextStyle: .callout)
                cell.detailTextLabel?.numberOfLines = 0
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
            case 3:
                cell.textLabel?.text = "Send an Email"
                cell.detailTextLabel?.text = "Need help? Or have a feature suggestion? You can send an email directly to me! I'll do my best to reply quickly. This may not work if you use a custom default email app."
                cell.detailTextLabel?.font = .preferredFont(forTextStyle: .caption1)
                cell.detailTextLabel?.textColor = .secondaryLabel
                cell.detailTextLabel?.numberOfLines = 0
                cell.imageView?.image = UIImage(systemName: "envelope")
                cell.imageView?.preferredSymbolConfiguration = .init(hierarchicalColor: .accent)
                cell.accessoryType = .disclosureIndicator
            case 4:
                cell.textLabel?.text = "Open Website"
                cell.imageView?.image = UIImage(systemName: "safari.fill")
                cell.imageView?.preferredSymbolConfiguration = .init(hierarchicalColor: .accent)
                cell.accessoryType = .disclosureIndicator
            case 5:
                cell.textLabel?.text = "Privacy Policy"
                cell.imageView?.image = UIImage(systemName: "hand.raised")
                cell.imageView?.preferredSymbolConfiguration = .init(hierarchicalColor: .accent)
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
            
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["support@sunapps.org"])
                mail.setMessageBody("", isHTML: true)
                mail.setValue("School Assistant Support", forKey: "Subject")
                mail.view.tintColor = .accent
                present(mail, animated: true)
            } else {
                let alertController = UIAlertController(title: "Error", message: "There was an error. Please send your email manually to support@sunapps.org", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
#if !os(visionOS)
        if runningOn != .mac {
            if indexPath.section == 4 {
                let urlString = "https://sunapps.org"
                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    
                    vc.delegate = self
                    present(vc, animated: true)
                }
            }
            
            if indexPath.section == 5 {
                
                let urlString = "https://sunapps.org/privacypolicy"
                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    
                    vc.delegate = self
                    present(vc, animated: true)
                }
            }
        }
#endif
        
        if runningOn == .mac || runningOn == .vision {
            switch indexPath.section {
            case 4:
                if let url = URL(string: "https://sunapps.org"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            case 5:
                if let url = URL(string: "https://sunapps.org/privacypolicy"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            default:
                return
            }
        } else {
#if !os(visionOS)
            switch indexPath.section {
            case 4:
                if let url = URL(string: "https://sunapps.org") {
                    let vc = SFSafariViewController(url: url)
                    
                    vc.delegate = self
                    present(vc, animated: true)
                }
            case 5:
                if let url = URL(string: "https://sunapps.org/privacypolicy") {
                    let vc = SFSafariViewController(url: url)
                    
                    vc.delegate = self
                    present(vc, animated: true)
                }
            default:
                return
            }
#endif
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

#if !os(visionOS)
extension AboutTableViewController: SFSafariViewControllerDelegate {
}
#endif


class ImageHeaderCell: UITableViewCell {
    
    let image = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    var sourceView: AboutTableViewController!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
	
        self.selectionStyle = .none
        
        configureImageView()
        configureTitleLabel()
        configureSubtitleLabel()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() {
        image.image = UIImage(named: "ffmpeg About Icon")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(image)
        backgroundColor = .clear
    }
    
    private func configureTitleLabel() {
        titleLabel.text = "FFmpeg Command Generator"
        titleLabel.font = .systemFont(ofSize: runningOn == .mac ? 23 : 30, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func configureSubtitleLabel() {
        subtitleLabel.text = "Created by Sun Apps in New York"
        subtitleLabel.font = UIFont.systemFont(ofSize: runningOn == .mac ? 14 : 18, weight: .medium)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            image.heightAnchor.constraint(equalToConstant: runningOn == .mac ? 77 : 100),
            
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        if runningOn == .mac {
            let closeButton = closeButton(action: UIAction() { _ in
                self.sourceView.dismiss(animated: true)
            })
            contentView.addSubview(closeButton)
            NSLayoutConstraint.activate([
                closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
                closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                closeButton.heightAnchor.constraint(equalToConstant: runningOn == .mac ? 27 : 35),
                closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor, multiplier: 1)
            ])
        }
    }
}


class UseSpecklesBackgroundCell: StandardCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		let switchView = UISwitch(frame: .zero)
		switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
		switchView.onTintColor = .tintColor
		switchView.isOn = !UserDefaults.standard.bool(forKey: "HideSpecklesBackground")
		self.accessoryView = switchView
		self.imageView?.image = self.imageView?.image?.withConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: .tintColor))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@IBAction func switchChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(!sender.isOn, forKey: "HideSpecklesBackground")
		NotificationCenter.default.post(name: Notification.Name("UpdateSpecklesBackground"), object: nil)
	}
}
