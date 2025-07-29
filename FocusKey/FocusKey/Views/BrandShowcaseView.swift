import SwiftUI

struct BrandShowcaseView: View {
    @State private var isConnected = true
    @State private var isActivating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with new FocusKey Logo
                VStack(spacing: 16) {
                    FocusKeyBrandedLogo(variant: .blue, size: .large)
                    
                    Text("FocusKey Brand Identity")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(hex: "#2c3e50"))
                }
                .padding(.top, 24)
                
                // Logo Variants Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Logo Variants")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#2c3e50"))
                    
                    VStack(spacing: 12) {
                        HStack {
                            FocusKeyBrandedLogo(variant: .blue, size: .small)
                            Spacer()
                            FocusKeyBrandedLogo(variant: .cream, size: .small)
                        }
                        
                        HStack {
                            FocusKeyBrandedLogo(variant: .blue, size: .medium)
                            Spacer()
                            FocusKeyBrandedLogo(variant: .cream, size: .medium)
                        }
                        
                        HStack {
                            FocusKeyBrandedLogo(variant: .blue, size: .large, showText: false)
                            Spacer()
                            FocusKeyBrandedLogo(variant: .cream, size: .large, showText: false)
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                .padding(.horizontal)
                
                // Color Palette Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Brand Colors")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#2c3e50"))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        BrandColorSwatch(color: Color(hex: "#f5f1e8"), name: "Cream")
                        BrandColorSwatch(color: Color(hex: "#e8dcc6"), name: "Beige")
                        BrandColorSwatch(color: Color(hex: "#7bb3d3"), name: "Blue Start")
                        BrandColorSwatch(color: Color(hex: "#5a9fd4"), name: "Blue End")
                        BrandColorSwatch(color: Color(hex: "#10b981"), name: "Success")
                        BrandColorSwatch(color: Color(hex: "#f59e0b"), name: "Warning")
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                .padding(.horizontal)
                
                // Animated NFC Trigger Demo
                VStack(alignment: .leading, spacing: 16) {
                    Text("Interactive NFC Trigger")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#2c3e50"))
                    
                    VStack(spacing: 20) {
                        BrandedNFCTrigger(
                            isConnected: isConnected,
                            isActivating: isActivating
                        ) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isActivating = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isActivating = false
                                }
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Button("Toggle Connection") {
                                withAnimation {
                                    isConnected.toggle()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#e8dcc6"))
                            .foregroundColor(Color(hex: "#2c3e50"))
                            .cornerRadius(8)
                            
                            Button("Simulate Tap") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    isActivating = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isActivating = false
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(LinearGradient(
                                colors: [Color(hex: "#7bb3d3"), Color(hex: "#5a9fd4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer(minLength: 24)
            }
        }
        .background(Color(hex: "#f8fafc"))
    }
}

// MARK: - FocusKey Branded Logo Component
struct FocusKeyBrandedLogo: View {
    enum Variant {
        case cream, blue
    }
    
    enum Size {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            }
        }
        
        var textFont: Font {
            switch self {
            case .small: return .system(size: 16, weight: .regular)
            case .medium: return .system(size: 18, weight: .medium)
            case .large: return .system(size: 20, weight: .semibold)
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
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo Icon
            ZStack {
                // Background Container
                RoundedRectangle(cornerRadius: 16)
                    .fill(logoBackground)
                    .frame(width: size.dimension, height: size.dimension)
                
                // Inner Circle with Border
                Circle()
                    .stroke(
                        variant == .cream ? Color(hex: "#e8dcc6") : Color.white.opacity(0.8),
                        lineWidth: 4
                    )
                    .frame(width: size.dimension * 0.58, height: size.dimension * 0.58)
            }
            
            // Logo Text
            if showText {
                Text("FocusKey")
                    .font(size.textFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#2c3e50"))
                    .tracking(-0.5)
            }
        }
    }
    
    private var logoBackground: AnyShapeStyle {
        if variant == .cream {
            return AnyShapeStyle(Color(hex: "#f5f1e8"))
        } else {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(hex: "#7bb3d3"), Color(hex: "#5a9fd4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
    }
}

// MARK: - Color Swatch Component
struct BrandColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
            
            Text(name)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "#64748b"))
        }
    }
}

// MARK: - Branded NFC Trigger
struct BrandedNFCTrigger: View {
    let isConnected: Bool
    let isActivating: Bool
    let onTrigger: () -> Void
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    @State private var rippleScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            // Ripple effects during activation
            if isActivating {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color(hex: "#5a9fd4").opacity(0.3), lineWidth: 2)
                        .frame(width: 128, height: 128)
                        .scaleEffect(rippleScale)
                        .opacity(rippleOpacity)
                        .animation(
                            Animation.easeOut(duration: 1.5).delay(Double(index) * 0.2),
                            value: isActivating
                        )
                }
            }
            
            // Subtle pulse when connected
            if isConnected && !isActivating {
                Circle()
                    .stroke(Color(hex: "#5a9fd4").opacity(0.2), lineWidth: 1)
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
                        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
                    
                    if isActivating {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isActivating ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 1).repeatForever(autoreverses: false),
                                value: isActivating
                            )
                    } else if isConnected {
                        Image(systemName: "key.radiowaves.forward")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "key")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(Color(hex: "#64748b"))
                    }
                }
            }
            .disabled(!isConnected)
            .scaleEffect(isActivating ? 1.1 : 1.0)
            .animation(Animation.spring(response: 0.6, dampingFraction: 0.8), value: isActivating)
        }
        .onAppear {
            if isConnected && !isActivating {
                pulseScale = 1.1
            }
        }
        .onChange(of: isActivating) { activating in
            if activating {
                rippleScale = 3.0
                rippleOpacity = 0.0
            } else {
                rippleScale = 0.5
                rippleOpacity = 0.8
            }
        }
    }
    
    private var triggerBackground: AnyShapeStyle {
        if isConnected {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(hex: "#7bb3d3"), Color(hex: "#5a9fd4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        } else {
            return AnyShapeStyle(Color(hex: "#f5f1e8"))
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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

#Preview {
    BrandShowcaseView()
} 