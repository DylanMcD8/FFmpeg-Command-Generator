//
////
////  AboutTableViewController.swift
////  School Assistant
////
////  Created by Dylan McDonald on 6/14/20.
////  Copyright © 2020 Dylan McDonald. All rights reserved.
////
//
//import SwiftUI
//
//struct AboutAppView: View {
//	@Environment(\.dismiss) var dismiss
//	@Environment(\.horizontalSizeClass) var horizontalSizeClass
//	
//	var body: some View {
//		NavigationView {
//			List {		
//				Section {
//					VStack(alignment: .center) {
//						Image("ffmpeg About Icon")
//							.resizable()
//							.scaledToFit()
//							.frame(height: 100)
////							.aspectRatio(contentMode: .fit)
//						Text("FFmpeg Command Generator")
//							.font(.system(size: runningOn == .mac ? 23 : 30, weight: .bold))
//							.multilineTextAlignment(.center)
//						Text("Created by Sun Apps in New York")
//							.font(.system(size: runningOn == .mac ? 14 : 18, weight: .medium))
//							.foregroundStyle(.secondary)
//							.multilineTextAlignment(.center)
//					}
//				}
//				Section {
//					StandardListCellV {
//						Text("About Sun Apps").font(.headline)
//						Text("Sun Apps is an independent app development company from New York, USA. It is run by student developer Dylan McDonald. If you need to contact me, send me an email at support@sunapps.org.").font(.body)
//					}
//				}
//				Section {
//					StandardListCellH {
//						Image(systemName: "safari.fill").symbolRenderingMode(.hierarchical)
//							.foregroundStyle(.accent)
//						Text("Open Website").font(.body)
//					}
//				}
//				Section {
//					StandardListCellH {
//						Image(systemName: "hand.raised").symbolRenderingMode(.hierarchical)
//							.foregroundStyle(.accent)
//						Text("Privacy Policy").font(.body)
//					}
//				}
//			}
//			.navigationTitle("About")
//			.listStyle(.insetGrouped)
////			.listSectionSpacing(16)
//			.navigationViewStyle(.stack)
//			.toolbar {
//				ToolbarItemGroup(placement: .navigationBarTrailing) {
//					Button(action: {
//						dismiss()
//					}) {
//						Image(systemName: "xmark.circle.fill")
////							.frame(width: 25, height: 25)
//							.font(.system(size: 30, weight: .semibold))
//							.symbolRenderingMode(.hierarchical)
//						
//						
//						
//							
//					}
//					.buttonStyle(.borderless)
//					.foregroundStyle(.gray)
////					.buttonBorderShape(.capsule)
//					
//				}
//			}
//			
//		}
//		.background(runningOn != .iOS ? .clear : Color(UIColor.systemGroupedBackground))
//	}
//	
//}
//
//struct StandardListCellV<Content: View>: View {
//	let content: Content
//	let alignment: HorizontalAlignment
//	
//	init(alignment: HorizontalAlignment = .leading, @ViewBuilder builder: () -> Content) {
//		self.alignment = alignment
//		self.content = builder()
//	}
//	
//	var body: some View {
//		if runningOn == .mac {
//			VStack(alignment: alignment) {
//				content
//			}
////			.listRowBackground(Color(uiColor: .separator).opacity(0.05))
//			.overlay(
//				RoundedRectangle(cornerRadius: 8)
//					.stroke(.accent, lineWidth: 10)
//			)
//			.cornerRadius(8)
//			
//
//		} else {
//			VStack(alignment: alignment) {
//				content
//			}
//		}
//	}
//}
//
//struct StandardListCellH<Content: View>: View {
//	let content: Content
//	let alignment: VerticalAlignment
//	
//	init(alignment: VerticalAlignment = .top, @ViewBuilder builder: () -> Content) {
//		self.alignment = alignment
//		self.content = builder()
//	}
//	
//	var body: some View {
//		if runningOn == .mac {
//			HStack(alignment: alignment) {
//				content
//			}
//			//			.listRowBackground(Color(uiColor: .separator).opacity(0.05))
//			.overlay(
//				RoundedRectangle(cornerRadius: 8)
//					.stroke(.accent, lineWidth: 10)
//			)
//			.cornerRadius(8)
//			
//			
//		} else {
//			HStack(alignment: alignment) {
//				content
//			}
//		}
//	}
//}
//
//struct AboutAppView_Previews: PreviewProvider {
//	static var previews: some View {
//		AboutAppView()
//	}
//}
//
//
