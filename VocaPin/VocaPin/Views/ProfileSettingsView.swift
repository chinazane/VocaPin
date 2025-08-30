//
//  ProfileSettingsView.swift
//  VocaPin
//
//  Created by Kiro on 8/27/25.
//

import SwiftUI
import WidgetKit
import StoreKit
import WebKit

struct ProfileSettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    HeaderSection()
                    
                    // Premium Section
                    PremiumSection()
                    
                    // Settings Section
                    SettingsSection()
                    
                    // Footer Section
                    FooterSection()
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(red: 0.9, green: 0.85, blue: 0.8))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.black)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Header Section
private struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 12) {
            // App Logo
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // App Title
            Text("Vocal Sticky")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            // Tagline
            Text("Speak it. Stick it.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Settings Section
private struct SettingsSection: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showWidgetSetup = false
    private let ratingService: RatingServiceProtocol = RatingService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Widget Setting using SettingRow style
            SettingRow(
                icon: "apps.iphone",
                title: "Add Widget",
                subtitle: "Quick access from home.",
                action: .navigation {
                    handleWidgetNavigation()
                },
                backgroundColor: Color.blue.opacity(0.15),
                iconColor: Color.blue
            )
            
            SettingRow(
                icon: "globe",
                title: "Language",
                subtitle: settingsManager.getCurrentSystemLanguage(),
                action: .navigation {
                    handleLanguageSettings()
                },
                backgroundColor: Color.green.opacity(0.15),
                iconColor: Color.green
            )
            
            SettingRow(
                icon: "star.fill",
                title: "Rate the App",
                subtitle: "Share your feedback.",
                action: .navigation {
                    handleRateApp()
                },
                backgroundColor: Color.pink.opacity(0.15),
                iconColor: Color.pink
            )
        }
        .sheet(isPresented: $showWidgetSetup) {
            WidgetSetupView()
                .presentationDetents([.height(500), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
    }
    
    private func handleWidgetNavigation() {
        // Show widget setup guide when navigation is triggered
        showWidgetSetup = true
    }
    
    private func handleLanguageSettings() {
        // Open iOS Settings app to language settings
        settingsManager.openLanguageSettings()
    }
    
    private func handleRateApp() {
        // Use RatingService to handle the rating request
        ratingService.requestRating()
    }
}

// MARK: - Premium Section
private struct PremiumSection: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Lock Icon with circle background
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text("Unlock Premium")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    // Description
                    Text("Unlimited notes & exclusive features")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                }
                
                Spacer()
            }
            
            // Upgrade Button
            Button(action: {
                handleUpgradeAction()
            }) {
                Text("Upgrade")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.3), Color.yellow.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func handleUpgradeAction() {
        // TODO: Implement premium upgrade flow
        // This will be connected to the app's premium subscription system
        print("Upgrade button tapped - Premium flow to be implemented")
    }
}

// MARK: - Footer Section
private struct FooterSection: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    var body: some View {
        VStack(spacing: 16) {
            // App Version
            Text(settingsManager.getFormattedVersion())
                .font(.caption2)
                .foregroundColor(.gray)
            
            // Legal Links
            HStack(spacing: 8) {
                Button(action: {
                    showPrivacyPolicy = true
                }) {
                    Text("Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .underline()
                }
                .accessibilityLabel("Privacy Policy")
                .accessibilityHint("Opens privacy policy in web browser")
                
                Text("·")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showTermsOfService = true
                }) {
                    Text("Terms of Service")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .underline()
                }
                .accessibilityLabel("Terms of Service")
                .accessibilityHint("Opens terms of service in web browser")
            }
        }
        .padding(.vertical, 16)
        .sheet(isPresented: $showPrivacyPolicy) {
            WebView(url: URL(string: "https://vocapin.com/privacy-policy")!)
                .navigationTitle("Privacy Policy")
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showTermsOfService) {
            WebView(url: URL(string: "https://vocapin.com/terms-of-service")!)
                .navigationTitle("Terms of Service")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Web View
private struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            // Handle navigation errors - fallback to external browser
            let url = webView.url ?? parent.url
            UIApplication.shared.open(url)
        }
    }
}


#Preview {
    ProfileSettingsView()
}
