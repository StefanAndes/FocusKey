import SwiftUI
import Foundation

// MARK: - FocusKey Design System
struct FocusKeyDesign {
    
    // MARK: - Brand Colors
    struct Colors {
        // Primary Brand Colors
        static let cream = Color(hex: "#f5f1e8")
        static let beige = Color(hex: "#e8dcc6")
        static let blueStart = Color(hex: "#7bb3d3")
        static let blueEnd = Color(hex: "#5a9fd4")
        
        // Background Colors
        static let darkBackground = Color(hex: "#1a1f2e")
        static let cardBackground = Color.white
        
        // Text Colors
        static let textPrimary = Color(hex: "#2c3e50")
        static let textSecondary = Color(hex: "#64748b")
        
        // Semantic Colors
        static let success = Color(hex: "#10b981")
        static let warning = Color(hex: "#f59e0b")
        static let danger = Color(hex: "#ef4444")
        
        // System Color Mappings
        static let primary = blueEnd
        static let secondary = cream
        static let background = Color(hex: "#f8fafc")
        static let border = Color(red: 148/255, green: 163/255, blue: 184/255, opacity: 0.2)
        
        // Gradient
        static let primaryGradient = LinearGradient(
            colors: [blueStart, blueEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Dark Mode Variants
        struct Dark {
            static let background = darkBackground
            static let card = Color(hex: "#293548")
            static let primary = blueStart
            static let secondary = Color(hex: "#374151")
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // Heading Styles
        static let h1 = Font.system(size: 28, weight: .semibold, design: .default)
        static let h2 = Font.system(size: 24, weight: .semibold, design: .default)
        static let h3 = Font.system(size: 20, weight: .semibold, design: .default)
        static let h4 = Font.system(size: 18, weight: .medium, design: .default)
        
        // Body Styles
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let captionMedium = Font.system(size: 14, weight: .medium, design: .default)
        
        // Button Styles
        static let buttonTitle = Font.system(size: 16, weight: .medium, design: .default)
        static let buttonSmall = Font.system(size: 14, weight: .medium, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }
    
    // MARK: - Border Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let round: CGFloat = 1000
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let small = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.15)
        static let large = Color.black.opacity(0.2)
    }
    
    // MARK: - Animation
    struct Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let ripple = SwiftUI.Animation.easeOut(duration: 1.5)
    }
}

// MARK: - FocusKey Logo Component
struct FocusKeyLogo: View {
    enum Variant {
        case cream
        case blue
    }
    
    enum Size {
        case small   // 32x32
        case medium  // 48x48
        case large   // 64x64
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            }
        }
        
        var textFont: Font {
            switch self {
            case .small: return FocusKeyDesign.Typography.body
            case .medium: return FocusKeyDesign.Typography.h4
            case .large: return FocusKeyDesign.Typography.h3
            }
        }
    }
    
    let variant: Variant
    let size: Size
    let showText: Bool
    
    init(variant: Variant = .blue, size: Size = .medium, showText: Bool = true) {
        self.variant = variant
        self.size = size
        self.showText = showText
    }
    
    private var logoBackground: some ShapeStyle {
        variant == .cream ? AnyShapeStyle(FocusKeyDesign.Colors.cream) : AnyShapeStyle(FocusKeyDesign.Colors.primaryGradient)
    }
    
    var body: some View {
        HStack(spacing: FocusKeyDesign.Spacing.md) {
            // Logo Icon
            ZStack {
                // Background Container
                RoundedRectangle(cornerRadius: FocusKeyDesign.Radius.lg)
                    .fill(logoBackground)
                    .frame(width: size.dimension, height: size.dimension)
                
                // Inner Circle with Border
                Circle()
                    .stroke(
                        variant == .cream ? FocusKeyDesign.Colors.beige : Color.white.opacity(0.8),
                        lineWidth: 4
                    )
                    .frame(width: size.dimension * 0.58, height: size.dimension * 0.58)
            }
            
            // Logo Text
            if showText {
                Text("FocusKey")
                    .font(size.textFont)
                    .fontWeight(.semibold)
                    .foregroundColor(FocusKeyDesign.Colors.textPrimary)
                    .tracking(-0.5)
            }
        }
    }
}

// MARK: - FocusKey Button Styles
struct FocusKeyButtonStyle: ButtonStyle {
    let variant: Variant
    let size: Size
    
    enum Variant {
        case primary
        case secondary
        case tertiary
        case danger
    }
    
    enum Size {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .large: return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return FocusKeyDesign.Typography.buttonSmall
            case .medium: return FocusKeyDesign.Typography.buttonTitle
            case .large: return FocusKeyDesign.Typography.buttonTitle
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .padding(size.padding)
            .background(backgroundForVariant(pressed: configuration.isPressed))
            .foregroundColor(foregroundColorForVariant)
            .cornerRadius(FocusKeyDesign.Radius.md)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(FocusKeyDesign.Animation.spring, value: configuration.isPressed)
    }
    
    private func backgroundForVariant(pressed: Bool) -> some View {
        Group {
            switch variant {
            case .primary:
                FocusKeyDesign.Colors.primaryGradient
                    .opacity(pressed ? 0.8 : 1.0)
            case .secondary:
                FocusKeyDesign.Colors.secondary
                    .opacity(pressed ? 0.8 : 1.0)
            case .tertiary:
                Color.clear
            case .danger:
                FocusKeyDesign.Colors.danger
                    .opacity(pressed ? 0.8 : 1.0)
            }
        }
    }
    
    private var foregroundColorForVariant: Color {
        switch variant {
        case .primary, .danger:
            return .white
        case .secondary:
            return FocusKeyDesign.Colors.textPrimary
        case .tertiary:
            return FocusKeyDesign.Colors.primary
        }
    }
}

// MARK: - FocusKey Card Style
struct FocusKeyCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    init(padding: CGFloat = FocusKeyDesign.Spacing.lg, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(FocusKeyDesign.Colors.cardBackground)
            .cornerRadius(FocusKeyDesign.Radius.lg)
            .shadow(color: FocusKeyDesign.Shadow.small, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Status Indicator Component
struct FocusKeyStatusIndicator: View {
    enum StatusType {
        case locked
        case unlocked
        case keyConnected
        case keyDisconnected
        
        var icon: String {
            switch self {
            case .locked: return "shield.checkered"
            case .unlocked: return "shield.slash"
            case .keyConnected: return "key.radiowaves.forward"
            case .keyDisconnected: return "key"
            }
        }
        
        var color: Color {
            switch self {
            case .locked, .keyConnected: return FocusKeyDesign.Colors.success
            case .unlocked: return FocusKeyDesign.Colors.danger
            case .keyDisconnected: return FocusKeyDesign.Colors.warning
            }
        }
        
        var label: String {
            switch self {
            case .locked: return "Protected"
            case .unlocked: return "Unprotected"
            case .keyConnected: return "Key Connected"
            case .keyDisconnected: return "Key Disconnected"
            }
        }
    }
    
    let type: StatusType
    
    var body: some View {
        HStack(spacing: FocusKeyDesign.Spacing.sm) {
            Image(systemName: type.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(type.color)
            
            Text(type.label)
                .font(FocusKeyDesign.Typography.captionMedium)
                .foregroundColor(type.color)
        }
        .padding(.horizontal, FocusKeyDesign.Spacing.md)
        .padding(.vertical, FocusKeyDesign.Spacing.sm)
        .background(type.color.opacity(0.1))
        .cornerRadius(FocusKeyDesign.Radius.round)
    }
}

// MARK: - Animated NFC Trigger
struct FocusKeyNFCTrigger: View {
    let isConnected: Bool
    let isActivating: Bool
    let onTrigger: () -> Void
    
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity: Double = 0.8
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    private var triggerBackground: some ShapeStyle {
        isConnected ? AnyShapeStyle(FocusKeyDesign.Colors.primaryGradient) : AnyShapeStyle(FocusKeyDesign.Colors.secondary)
    }
    
    var body: some View {
        ZStack {
            // Ripple Effect during activation
            if isActivating {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(FocusKeyDesign.Colors.primary.opacity(0.3), lineWidth: 2)
                        .frame(width: 128, height: 128)
                        .scaleEffect(rippleScale)
                        .opacity(rippleOpacity)
                        .animation(
                            FocusKeyDesign.Animation.ripple.delay(Double(index) * 0.2),
                            value: rippleScale
                        )
                }
            }
            
            // Subtle pulse when connected
            if isConnected && !isActivating {
                Circle()
                    .stroke(FocusKeyDesign.Colors.primary.opacity(0.2), lineWidth: 1)
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulseScale)
                    .animation(
                        Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
                        value: pulseScale
                    )
            }
            
            // Main trigger button
            Button(action: onTrigger) {
                ZStack {
                                         Circle()
                         .fill(triggerBackground)
                         .frame(width: 128, height: 128)
                        .shadow(color: FocusKeyDesign.Shadow.medium, radius: 16, x: 0, y: 8)
                    
                    if isActivating {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotationAngle))
                    } else if isConnected {
                        Image(systemName: "key.radiowaves.forward")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "key")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(FocusKeyDesign.Colors.textSecondary)
                    }
                }
            }
            .disabled(!isConnected)
            .scaleEffect(isActivating ? 1.1 : 1.0)
            .animation(FocusKeyDesign.Animation.spring, value: isActivating)
        }
        .onAppear {
            if isConnected && !isActivating {
                pulseScale = 1.1
            }
            if isActivating {
                rippleScale = 3.0
                rippleOpacity = 0.0
                rotationAngle = 360
            }
        }
        .onChange(of: isActivating) { activating in
            if activating {
                rippleScale = 3.0
                rippleOpacity = 0.0
                rotationAngle += 360
            } else {
                rippleScale = 0.5
                rippleOpacity = 0.8
            }
        }
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 