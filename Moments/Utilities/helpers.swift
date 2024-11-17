//
//  helpers.swift
//  Moments
//
//  Created by Zachary Tao on 3/30/24.
//

import Foundation
import SwiftUI

struct ShortCodeGenerator {
    private static let base62chars = [Character]("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    private static let maxBase : UInt32 = 62

    static func getCode(withBase base: UInt32 = maxBase, length: Int) -> String {
        var code = ""
        for _ in 0..<length {
            let random = Int(arc4random_uniform(min(base, maxBase)))
            code.append(base62chars[random])
        }
        return code
    }
}

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
    
    static var mainColor1 = Color(hex: "#FFFFFF")
    static var second = Color(hex: "#FF5116") //orange
    static var first = Color(hex: "#F6F6F6") //white sand
}

import UIKit
import AVFoundation

public extension UIImage {
    /// Resize image while keeping the aspect ratio. Original image is not modified.
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    func resize(_ width: Int, _ height: Int) -> UIImage {
        // Keep aspect ratio
        let maxSize = CGSize(width: width, height: height)

        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size

        // Set scale of renderer so that 1pt == 1px
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        // Resize the image
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized
    }
}

func dateDisplayFormatter(_ date: Date?) -> String {
    guard let date = date else { return "Unknown Time" }
    let currentTime = Date()
    
    let calendar = Calendar.current
    let timeDifference = currentTime.timeIntervalSince(date)
    let isJustNow = timeDifference < 2 * 60 // Within 2 minutes
    let isToday = calendar.isDateInToday(date)
    
    if isJustNow {
        // If the photo was taken within the last two minutes
        return "Just now"
    } else if timeDifference < 60 * 60 {
        // If the photo was taken within the last hour but more than two minutes ago
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        
        return (formatter.string(from: date, to: currentTime) ?? "") + " ago"
    } else if isToday {
        // If the photo was taken today, but more than an hour ago
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    } else {
        // If the photo was not taken today
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a EEEE" // e.g., "10:39 PM Sunday"
        return formatter.string(from: date)
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
  private var content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  func makeUIView(context: Context) -> UIScrollView {
    // set up the UIScrollView
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator  // for viewForZooming(in:)
    scrollView.maximumZoomScale = 20
    scrollView.minimumZoomScale = 1
    scrollView.bouncesZoom = true

    // create a UIHostingController to hold our SwiftUI content
    let hostedView = context.coordinator.hostingController.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    scrollView.addSubview(hostedView)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    // update the hosting controller's SwiftUI content
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return hostingController.view
    }
  }
}


struct ColorOptions: Codable {
    static var all: [Color] = [
        .white,
        .black,
        .gray,
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .cyan,
        .indigo,
        .purple,
    ]
    
    static var `default` : Color = Color.primary
    
    static func random() -> Color {
        if let element = ColorOptions.all.randomElement() {
            return element
        } else {
            return .primary
        }
        
    }
}

struct AnniSymbols {
    static func randomName() -> String {
        if let random = symbolNames.randomElement() {
            return random
        } else {
            return ""
        }
    }
    
    static func randomNames(_ number: Int) -> [String] {
        var names: [String] = []
        for _ in 0..<number {
            names.append(randomName())
        }
        return names
    }
    
    static var symbolNames: [String] = [
        "🎂", // Birthday
        "🎓", // Graduation
        "🎉", // Party/Celebration
        "🎄", // Christmas
        "🎆", // New Year's Eve
        "🎈", // Party/General Celebration
        "🍾", // New Year/Celebration
        "🏡", // New Home
        "👶", // New Baby
        "🎁", // Gifts/Christmas
        "💍", // Wedding/Engagement
        "🌟", // Achievement/Celebration
        "🥂", // Celebration/Cheers
        "🍀", // St. Patrick's Day
        "💖", // Valentine's Day
        "💕", // Love
         "💞", // Revolving Hearts
         "💓", // Beating Heart
        "🇺🇸", // Independence Day
        "🎃", // Halloween
        "🦃", // Thanksgiving
        "🐣", // Easter
        "🕎", // Hanukkah
        "🌍", // Earth Day
        "👩‍🎓", // Graduation (female)
        "👨‍🎓", // Graduation (male)
        "🏈", // Super Bowl
        "🏂", // Winter Sports
        "🏊", // Summer Olympics
        "🏆", // Championship/Sporting Events
        "💼", // New Job
        "💵", // Pay Day
        "📅", // Anniversaries/Important Dates
        "🚗", // New Car
        "🛳",  // Cruise/Trip
        "✈️",  // Flight/Trip
        "🚀", // Space-related Events
        "🎮", // Game Release
        "👑", // Royalty-related Events
        "📚", // School Year Start/End
        "🏰", // Disney Trip or Similar
        "🔔", // Wedding Bell
        "⏰",  // Time-related Reminder
        "🧧", // Red Envelope
        "🧨" // Fireworks
    ]
}
