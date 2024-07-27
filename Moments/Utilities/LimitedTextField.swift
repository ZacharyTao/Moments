
import SwiftUI

/// Custom View
struct LimitedTextField: View {
    /// Configuration
    var config: Config
    var hint: String
    @Binding var value: String
    /// View Properties
    @FocusState private var isKeyboardShowing: Bool
    var body: some View {
        VStack(alignment: config.progressConfig.alignment, spacing: 12) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: config.borderConfig.radius)
                    .fill(.clear)
                    .frame(height: config.autoResizes ? 0 : nil)
                    .contentShape(.rect(cornerRadius: config.borderConfig.radius))
                    .onTapGesture {
                        /// Show Keyboard
                        isKeyboardShowing = true
                    }
                
                TextField(hint, text: $value)
                    .focused($isKeyboardShowing)
                    .onChange(of: value, initial: true) { oldValue, newValue in
                        guard !config.allowsExcessTyping else { return }
                        value = String(value.prefix(config.limit))
                    }
                    .onChange(of: config.allowsExcessTyping) { oldValue, newValue in
                        if !newValue {
                            value = String(value.prefix(config.limit))
                        }
                    }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: config.borderConfig.radius)
                    .stroke(progressColor.gradient, lineWidth: config.borderConfig.width)
                    .opacity(config.borderConfig.show ? 1 : 0)
            }
            
            /// Progress Bar / Text Indicator
            HStack(alignment: .top, spacing: 12) {
                if config.progressConfig.showsRing {
                    ZStack {
                        Circle()
                            .stroke(.ultraThinMaterial, lineWidth: 5)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(progressColor.gradient, lineWidth: 5)
                            .rotationEffect(.init(degrees: -90))
                    }
                    .frame(width: 20, height: 20)
                }
                
                if config.progressConfig.showsText {
                    Text("\(value.count)/\(config.limit)")
                        .foregroundStyle(progressColor.gradient)
                }
            }
        }
    }
    
    var progress: CGFloat {
        return max(min(CGFloat(value.count) / CGFloat(config.limit), 1), 0)
    }
    
    var progressColor: Color {
        return progress < 0.6 ? config.tint : progress == 1.0 ? .red : .orange
    }
    
    struct Config {
        var limit: Int
        var tint: Color = .blue
        var autoResizes: Bool = false
        var allowsExcessTyping: Bool = false
        var progressConfig: ProgressConfig = .init()
        var borderConfig: BorderConfig = .init()
    }
    
    struct ProgressConfig {
        var showsRing: Bool = false
        var showsText: Bool = true
        var alignment: HorizontalAlignment = .trailing
    }
    
    struct BorderConfig {
        var show: Bool = true
        var radius: CGFloat = 12
        var width: CGFloat = 0.8
    }
}


