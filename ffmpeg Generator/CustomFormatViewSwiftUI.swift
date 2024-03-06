//
//  CustomFormatViewController.swift
//  ffmpeg Generator
//
//  Created by Dylan McDonald on 10/25/22.
//

import SwiftUI

struct CustomFormatView: View {
	@State private var formatString: String = (UserDefaults.standard.string(forKey: "Custom File Format") ?? "")
	@Environment(\.dismiss) var dismiss
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text("Enter a custom file format:")
				.font(.system(size: runningOn == .mac ? 16 : 20, weight: .semibold))
				.padding([.leading, .trailing], 20)
				.padding(.top, runningOn == .vision ? 25 : 20)
				.padding(.bottom, 15)
			
            let formatField = Group {
                TextField(".mov, .mp4, etc.", text: $formatString)
//                    .foregroundStyle(.separator)
                    .textFieldStyle(.roundedBorder)
                    
//                    .background(Color(uiColor: .secondarySystemGroupedBackground))
            }
                .padding(.bottom, 15)
                .padding([.leading, .trailing], 20)
            
			if horizontalSizeClass != .compact {
				formatField
					.frame(width: 360)
			} else {
				formatField
			}
			
			HStack(spacing: 10) {
				if runningOn == .mac {
					Spacer()
				}
				
				
				Button(action: {
					dismiss()
				}) {
					if runningOn != .mac {
						Text("Cancel")
							.padding(.horizontal).frame(maxWidth: .infinity)
					} else {
						Text("Cancel")
					}
				}
				.padding(.horizontal, 0.0)
				.buttonStyle(.bordered)
				
				Button(action: {
					UserDefaults.standard.set(formatString, forKey: "Custom File Format")
					dismiss()
				}) {
					if runningOn != .mac {
						Text("Save")
							.padding(.horizontal).frame(maxWidth: .infinity)
					} else {
						Text("Save   ")
//							.frame(width: 150)
					}
				}
				.padding(.horizontal, 0.0)
				.buttonStyle(.borderedProminent)
				
				
			}
//			.frame(minWidth: 0, maxWidth: .infinity)
			.padding([.leading, .trailing, .bottom], 20)
			
			if horizontalSizeClass == .compact {
				Spacer()
			}
		}
		.background(runningOn != .iOS ? .clear : Color(UIColor.systemGroupedBackground))
		.fixedSize(horizontal: horizontalSizeClass == .compact ? false : true, vertical: horizontalSizeClass == .compact ? false : true)
	
		
	}
}







struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		CustomFormatView()
			
	}
}

extension View {
	/// Applies the given transform if the given condition evaluates to `true`.
	/// - Parameters:
	///   - condition: The condition to evaluate.
	///   - transform: The transform to apply to the source `View`.
	/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}
