import SwiftUI

struct FocusKeyBrandShowcase: View {
    @State private var isNFCConnected = true
    @State private var isActivating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: FocusKeyDesign.Spacing.xl) {
                // Header with Logo
                VStack(spacing: FocusKeyDesign.Spacing.lg) {
                    FocusKeyLogo(variant: .blue, size: .large)
                    
                    Text("FocusKey Brand Identity")
                        .font(FocusKeyDesign.Typography.h1)
                        .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                }
                .padding(.top, FocusKeyDesign.Spacing.xl)
                
                // Logo Variants
                FocusKeyCard {
                    VStack(alignment: .leading, spacing: FocusKeyDesign.Spacing.lg) {
                        Text("Logo Variants")
                            .font(FocusKeyDesign.Typography.h3)
                            .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                        
                        VStack(spacing: FocusKeyDesign.Spacing.md) {
                            HStack {
                                FocusKeyLogo(variant: .blue, size: .small)
                                Spacer()
                                FocusKeyLogo(variant: .cream, size: .small)
                            }
                            
                            HStack {
                                FocusKeyLogo(variant: .blue, size: .medium)
                                Spacer()
                                FocusKeyLogo(variant: .cream, size: .medium)
                            }
                            
                            HStack {
                                FocusKeyLogo(variant: .blue, size: .large, showText: false)
                                Spacer()
                                FocusKeyLogo(variant: .cream, size: .large, showText: false)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Color Palette
                FocusKeyCard {
                    VStack(alignment: .leading, spacing: FocusKeyDesign.Spacing.lg) {
                        Text("Color Palette")
                            .font(FocusKeyDesign.Typography.h3)
                            .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: FocusKeyDesign.Spacing.md) {
                            ColorSwatch(color: FocusKeyDesign.Colors.cream, name: "Cream")
                            ColorSwatch(color: FocusKeyDesign.Colors.beige, name: "Beige")
                            ColorSwatch(color: FocusKeyDesign.Colors.blueStart, name: "Blue Start")
                            ColorSwatch(color: FocusKeyDesign.Colors.blueEnd, name: "Blue End")
                            ColorSwatch(color: FocusKeyDesign.Colors.success, name: "Success")
                            ColorSwatch(color: FocusKeyDesign.Colors.warning, name: "Warning")
                        }
                    }
                }
                .padding(.horizontal)
                
                // Button Styles
                FocusKeyCard {
                    VStack(alignment: .leading, spacing: FocusKeyDesign.Spacing.lg) {
                        Text("Button Styles")
                            .font(FocusKeyDesign.Typography.h3)
                            .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                        
                        VStack(spacing: FocusKeyDesign.Spacing.md) {
                            Button("Primary Button") { }
                                .buttonStyle(FocusKeyButtonStyle(variant: .primary, size: .medium))
                            
                            Button("Secondary Button") { }
                                .buttonStyle(FocusKeyButtonStyle(variant: .secondary, size: .medium))
                            
                            Button("Tertiary Button") { }
                                .buttonStyle(FocusKeyButtonStyle(variant: .tertiary, size: .medium))
                            
                            Button("Danger Button") { }
                                .buttonStyle(FocusKeyButtonStyle(variant: .danger, size: .medium))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Status Indicators
                FocusKeyCard {
                    VStack(alignment: .leading, spacing: FocusKeyDesign.Spacing.lg) {
                        Text("Status Indicators")
                            .font(FocusKeyDesign.Typography.h3)
                            .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                        
                        VStack(spacing: FocusKeyDesign.Spacing.md) {
                            HStack {
                                FocusKeyStatusIndicator(type: .locked)
                                Spacer()
                                FocusKeyStatusIndicator(type: .unlocked)
                            }
                            
                            HStack {
                                FocusKeyStatusIndicator(type: .keyConnected)
                                Spacer()
                                FocusKeyStatusIndicator(type: .keyDisconnected)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // NFC Trigger
                FocusKeyCard {
                    VStack(alignment: .leading, spacing: FocusKeyDesign.Spacing.lg) {
                        Text("NFC Trigger")
                            .font(FocusKeyDesign.Typography.h3)
                            .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                        
                        VStack(spacing: FocusKeyDesign.Spacing.lg) {
                            FocusKeyNFCTrigger(
                                isConnected: isNFCConnected,
                                isActivating: isActivating
                            ) {
                                isActivating = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isActivating = false
                                }
                            }
                            
                            HStack {
                                Button("Toggle Connection") {
                                    isNFCConnected.toggle()
                                }
                                .buttonStyle(FocusKeyButtonStyle(variant: .secondary, size: .small))
                                
                                Button("Simulate Activation") {
                                    isActivating = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isActivating = false
                                    }
                                }
                                .buttonStyle(FocusKeyButtonStyle(variant: .primary, size: .small))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Typography
                FocusKeyCard {
                    VStack(alignment: .leading, spacing: FocusKeyDesign.Spacing.lg) {
                        Text("Typography")
                            .font(FocusKeyDesign.Typography.h3)
                            .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: FocusKeyDesign.Spacing.md) {
                            Text("Heading 1")
                                .font(FocusKeyDesign.Typography.h1)
                                .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                            
                            Text("Heading 2")
                                .font(FocusKeyDesign.Typography.h2)
                                .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                            
                            Text("Heading 3")
                                .font(FocusKeyDesign.Typography.h3)
                                .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                            
                            Text("Body text with regular weight for readability and clear communication.")
                                .font(FocusKeyDesign.Typography.body)
                                .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                            
                            Text("Caption text for supplementary information.")
                                .font(FocusKeyDesign.Typography.caption)
                                .foregroundColor(FocusKeyDesign.Colors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: FocusKeyDesign.Spacing.xl)
            }
        }
        .background(FocusKeyDesign.Colors.background)
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: FocusKeyDesign.Spacing.sm) {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(FocusKeyDesign.Radius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: FocusKeyDesign.Radius.sm)
                        .stroke(FocusKeyDesign.Colors.border, lineWidth: 1)
                )
            
            Text(name)
                .font(FocusKeyDesign.Typography.caption)
                .foregroundColor(FocusKeyDesign.Colors.textSecondary)
        }
    }
}

#Preview {
    FocusKeyBrandShowcase()
} 