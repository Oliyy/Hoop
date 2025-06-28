import Cocoa
import SwiftUI

// MARK: - Main App
@main
struct WindowResizerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var windowManager: WindowManager!
    var httpServer: HTTPServer!
    var currentAnimation: AnimationStyle = .smooth
    var currentPadding: PaddingOption = .medium
    
    private let animationStyleKey = "HoopAnimationStyle"
    private let paddingOptionKey = "HoopPaddingOption"
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load saved settings
        loadSavedSettings()
        
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar icon
        setupMenuBar()
        
        // Initialize window manager
        windowManager = WindowManager()
        windowManager.animationStyle = currentAnimation
        windowManager.paddingOption = currentPadding
        
        // Start HTTP server
        httpServer = HTTPServer(windowManager: windowManager)
        httpServer.start()
        
        // Request accessibility permissions
        requestAccessibilityPermissions()
    }
    
    private func loadSavedSettings() {
        if let savedAnimationRaw = UserDefaults.standard.string(forKey: animationStyleKey),
           let savedAnimation = AnimationStyle(rawValue: savedAnimationRaw) {
            currentAnimation = savedAnimation
        }
        
        if let savedPaddingRaw = UserDefaults.standard.string(forKey: paddingOptionKey),
           let savedPadding = PaddingOption(rawValue: savedPaddingRaw) {
            currentPadding = savedPadding
        }
    }
    
    private func saveAnimationStyle(_ style: AnimationStyle) {
        UserDefaults.standard.set(style.rawValue, forKey: animationStyleKey)
    }
    
    private func savePaddingOption(_ padding: PaddingOption) {
        UserDefaults.standard.set(padding.rawValue, forKey: paddingOptionKey)
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "rectangle.and.arrow.up.right.and.arrow.down.left", accessibilityDescription: "Window Resizer")
        }
        
        updateMenu()
    }
    
    func updateMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Server: http://localhost:8437", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Animation style submenu
        let animationMenu = NSMenu()
        for style in AnimationStyle.allCases {
            let item = NSMenuItem(title: style.displayName, action: #selector(setAnimationStyle(_:)), keyEquivalent: "")
            item.representedObject = style
            item.state = currentAnimation == style ? .on : .off
            animationMenu.addItem(item)
        }
        
        let animationItem = NSMenuItem(title: "Animation Style", action: nil, keyEquivalent: "")
        animationItem.submenu = animationMenu
        menu.addItem(animationItem)
        
        // Padding submenu
        let paddingMenu = NSMenu()
        for padding in PaddingOption.allCases {
            let item = NSMenuItem(title: padding.displayName, action: #selector(setPadding(_:)), keyEquivalent: "")
            item.representedObject = padding
            item.state = currentPadding == padding ? .on : .off
            paddingMenu.addItem(item)
        }
        
        let paddingItem = NSMenuItem(title: "Padding", action: nil, keyEquivalent: "")
        paddingItem.submenu = paddingMenu
        menu.addItem(paddingItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func setAnimationStyle(_ sender: NSMenuItem) {
        if let style = sender.representedObject as? AnimationStyle {
            currentAnimation = style
            windowManager.animationStyle = style
            saveAnimationStyle(style)
            updateMenu()
        }
    }
    
    @objc func setPadding(_ sender: NSMenuItem) {
        if let padding = sender.representedObject as? PaddingOption {
            currentPadding = padding
            windowManager.paddingOption = padding
            savePaddingOption(padding)
            updateMenu()
        }
    }
    
    func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Please enable accessibility permissions for this app in System Preferences")
        }
    }
}

// MARK: - Animation Styles
enum AnimationStyle: String, CaseIterable {
    case linear = "linear"
    case smooth = "smooth"
    case bounce = "bounce"
    case elastic = "elastic"
    case spring = "spring"
    case overshoot = "overshoot"
    case anticipate = "anticipate"
    case rubberBand = "rubberBand"
    case jello = "jello"
    case wobbly = "wobbly"
    
    case glide = "glide"
    case silk = "silk"
    case flow = "flow"
    case drift = "drift"
    
    case zoom = "zoom"
    case pop = "pop"
    case swoosh = "swoosh"
    case whip = "whip"
    case bounce2x = "bounce2x"
    case wiggle = "wiggle"
    
    case magnetic = "magnetic"
    case gravity = "gravity"
    case orbit = "orbit"
    case spiral = "spiral"
    case wave = "wave"
    
    case rocket = "rocket"
    case teleport = "teleport"
    case lightning = "lightning"
    case pulse = "pulse"
    case tornado = "tornado"
    
    var displayName: String {
        switch self {
        case .linear: return "Linear"
        case .smooth: return "Smooth (Default)"
        case .bounce: return "Bounce"
        case .elastic: return "Elastic"
        case .spring: return "Spring"
        case .overshoot: return "Overshoot"
        case .anticipate: return "Anticipate"
        case .rubberBand: return "Rubber Band"
        case .jello: return "Jello"
        case .wobbly: return "Wobbly"
        
        case .glide: return "✨ Glide"
        case .silk: return "🪶 Silk"
        case .flow: return "🌊 Flow"
        case .drift: return "☁️ Drift"
        
        case .zoom: return "🔍 Zoom"
        case .pop: return "🎈 Pop"
        case .swoosh: return "💨 Swoosh"
        case .whip: return "⚡ Whip"
        case .bounce2x: return "🏀 Double Bounce"
        case .wiggle: return "🐍 Wiggle"
        
        case .magnetic: return "🧲 Magnetic"
        case .gravity: return "🌍 Gravity"
        case .orbit: return "🪐 Orbit"
        case .spiral: return "🌀 Spiral"
        case .wave: return "〰️ Wave"
        
        case .rocket: return "🚀 Rocket"
        case .teleport: return "✨ Teleport"
        case .lightning: return "⚡ Lightning"
        case .pulse: return "💓 Pulse"
        case .tornado: return "🌪️ Tornado"
        }
    }
    
    var duration: Double {
        switch self {
        case .linear, .smooth: return 0.3
        case .bounce: return 0.6
        case .elastic: return 0.8
        case .spring: return 0.5
        case .overshoot: return 0.4
        case .anticipate: return 0.5
        case .rubberBand: return 0.7
        case .jello: return 1.0
        case .wobbly: return 0.8
        
        case .glide, .silk: return 0.4
        case .flow: return 0.5
        case .drift: return 0.6
        
        case .zoom: return 0.3
        case .pop: return 0.4
        case .swoosh: return 0.35
        case .whip: return 0.25
        case .bounce2x: return 0.8
        case .wiggle: return 0.7
        
        case .magnetic: return 0.5
        case .gravity: return 0.6
        case .orbit: return 0.9
        case .spiral: return 1.0
        case .wave: return 0.8
        
        case .rocket: return 0.2
        case .teleport: return 0.15
        case .lightning: return 0.3
        case .pulse: return 0.6
        case .tornado: return 1.2
        }
    }
}

// MARK: - Padding Options
enum PaddingOption: String, CaseIterable {
    case none = "0"
    case small = "4"
    case medium = "8"
    case large = "12"
    
    var displayName: String {
        switch self {
        case .none: return "0px (No Padding)"
        case .small: return "4px"
        case .medium: return "8px (Default)"
        case .large: return "12px"
        }
    }
    
    var value: CGFloat {
        switch self {
        case .none: return 0
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        }
    }
}

// MARK: - Window Manager
class WindowManager {
    var animationStyle: AnimationStyle = .smooth
    var paddingOption: PaddingOption = .medium
    
    func resizeWindow(to position: WindowPosition, animationStyle: AnimationStyle? = nil) {
        guard let frontWindow = getFrontmostWindow() else {
            print("No frontmost window found")
            return
        }
        
        // Get the screen that contains the window
        guard let screen = getScreenForWindow(frontWindow) else {
            print("Could not determine window's screen")
            return
        }
        
        let targetFrame = calculateFrame(for: position, on: screen)
        
        // Use provided animation style or default
        let style = animationStyle ?? self.animationStyle
        
        // Animate the window resize
        animateWindow(frontWindow, to: targetFrame, style: style)
    }
    
    func moveWindowToMonitor(monitorIndex: Int, animationStyle: AnimationStyle? = nil) -> Bool {
        guard let frontWindow = getFrontmostWindow() else {
            print("No frontmost window found")
            return false
        }
        
        // Convert 1-based index to 0-based for array access
        let arrayIndex = monitorIndex - 1
        
        // Validate monitor index
        guard arrayIndex >= 0 && arrayIndex < NSScreen.screens.count else {
            print("Invalid monitor index: \(monitorIndex). Available monitors: 1-\(NSScreen.screens.count)")
            return false
        }
        
        // Get current window position and size
        var currentPosition: AnyObject?
        var currentSize: AnyObject?
        
        AXUIElementCopyAttributeValue(frontWindow, kAXPositionAttribute as CFString, &currentPosition)
        AXUIElementCopyAttributeValue(frontWindow, kAXSizeAttribute as CFString, &currentSize)
        
        guard let currentPosValue = currentPosition,
              let currentSizeValue = currentSize else {
            print("Could not get current window position/size")
            return false
        }
        
        var currentPoint = CGPoint()
        var currentSizeStruct = CGSize()
        
        AXValueGetValue(currentPosValue as! AXValue, .cgPoint, &currentPoint)
        AXValueGetValue(currentSizeValue as! AXValue, .cgSize, &currentSizeStruct)
        
        // Get current screen
        guard let currentScreen = getScreenForWindow(frontWindow) else {
            print("Could not determine window's current screen")
            return false
        }
        
        // Get target screen
        let targetScreen = NSScreen.screens[arrayIndex]
        
        // Calculate relative position and size on current screen
        let currentVisibleFrame = convertVisibleFrameToTopLeft(currentScreen.visibleFrame)
        let targetVisibleFrame = convertVisibleFrameToTopLeft(targetScreen.visibleFrame)
        
        // Calculate relative position (as percentages)
        let relativeX = (currentPoint.x - currentVisibleFrame.origin.x) / currentVisibleFrame.width
        let relativeY = (currentPoint.y - currentVisibleFrame.origin.y) / currentVisibleFrame.height
        let relativeWidth = currentSizeStruct.width / currentVisibleFrame.width
        let relativeHeight = currentSizeStruct.height / currentVisibleFrame.height
        
        // Apply relative position to target screen
        let targetX = targetVisibleFrame.origin.x + (relativeX * targetVisibleFrame.width)
        let targetY = targetVisibleFrame.origin.y + (relativeY * targetVisibleFrame.height)
        let targetWidth = relativeWidth * targetVisibleFrame.width
        let targetHeight = relativeHeight * targetVisibleFrame.height
        
        // Ensure window stays within target screen bounds
        let padding = paddingOption.value
        let maxX = targetVisibleFrame.origin.x + targetVisibleFrame.width - targetWidth - padding
        let maxY = targetVisibleFrame.origin.y + targetVisibleFrame.height - targetHeight - padding
        let minX = targetVisibleFrame.origin.x + padding
        let minY = targetVisibleFrame.origin.y + padding
        
        let finalX = max(minX, min(maxX, targetX))
        let finalY = max(minY, min(maxY, targetY))
        let finalWidth = min(targetWidth, targetVisibleFrame.width - (padding * 2))
        let finalHeight = min(targetHeight, targetVisibleFrame.height - (padding * 2))
        
        let targetFrame = CGRect(x: finalX, y: finalY, width: finalWidth, height: finalHeight)
        
        // Use provided animation style or default
        let style = animationStyle ?? self.animationStyle
        
        // Animate the window move
        animateWindow(frontWindow, to: targetFrame, style: style)
        
        return true
    }
    
    private func getFrontmostWindow() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        var windowRef: AnyObject?
        
        let result = AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &windowRef)
        
        if result == .success {
            return (windowRef as! AXUIElement)
        }
        
        return nil
    }
    
    private func getScreenForWindow(_ window: AXUIElement) -> NSScreen? {
        // Get window position and size
        var positionRef: AnyObject?
        var sizeRef: AnyObject?
        
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        
        guard let positionValue = positionRef,
              let sizeValue = sizeRef else { return nil }
        
        var position = CGPoint()
        var size = CGSize()
        
        AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)
        
        // Window coordinates from AX are already in screen coordinates (top-left origin)
        // Find which screen contains the window's center point
        let windowCenter = CGPoint(x: position.x + size.width / 2, y: position.y + size.height / 2)
        
        // Check each screen to see if it contains the window center
        for screen in NSScreen.screens {
            // Convert NSScreen frame to top-left origin coordinate system
            let screenFrame = convertScreenFrame(screen.frame)
            
            if screenFrame.contains(windowCenter) {
                return screen
            }
        }
        
        // Fallback: find the screen with the closest center
        var closestScreen = NSScreen.main
        var closestDistance = CGFloat.greatestFiniteMagnitude
        
        for screen in NSScreen.screens {
            let screenFrame = convertScreenFrame(screen.frame)
            let screenCenter = CGPoint(x: screenFrame.midX, y: screenFrame.midY)
            let distance = sqrt(pow(windowCenter.x - screenCenter.x, 2) + pow(windowCenter.y - screenCenter.y, 2))
            
            if distance < closestDistance {
                closestDistance = distance
                closestScreen = screen
            }
        }
        
        return closestScreen
    }
    
    private func convertScreenFrame(_ frame: CGRect) -> CGRect {
        // Convert from NSScreen's bottom-left origin to top-left origin
        guard let mainScreen = NSScreen.screens.first else { return frame }
        let mainScreenHeight = mainScreen.frame.height
        
        return CGRect(
            x: frame.origin.x,
            y: mainScreenHeight - frame.origin.y - frame.height,
            width: frame.width,
            height: frame.height
        )
    }
    
    private func calculateFrame(for position: WindowPosition, on screen: NSScreen) -> CGRect {
        let padding = paddingOption.value
        
        // Use visibleFrame which excludes menu bar and dock
        let visibleFrame = screen.visibleFrame
        
        // Convert to top-left coordinate system for positioning
        let workingFrame = convertVisibleFrameToTopLeft(visibleFrame)
        
        switch position {
        case .left:
            return CGRect(
                x: workingFrame.origin.x + padding,
                y: workingFrame.origin.y + padding,
                width: (workingFrame.width / 2) - (padding * 1.5),
                height: workingFrame.height - (padding * 2)
            )
        case .right:
            return CGRect(
                x: workingFrame.origin.x + (workingFrame.width / 2) + (padding * 0.5),
                y: workingFrame.origin.y + padding,
                width: (workingFrame.width / 2) - (padding * 1.5),
                height: workingFrame.height - (padding * 2)
            )
        case .top:
            return CGRect(
                x: workingFrame.origin.x + padding,
                y: workingFrame.origin.y + padding,
                width: workingFrame.width - (padding * 2),
                height: (workingFrame.height / 2) - (padding * 1.5)
            )
        case .bottom:
            return CGRect(
                x: workingFrame.origin.x + padding,
                y: workingFrame.origin.y + (workingFrame.height / 2) + (padding * 0.5),
                width: workingFrame.width - (padding * 2),
                height: (workingFrame.height / 2) - (padding * 1.5)
            )
        case .center:
            let width = workingFrame.width * 0.7
            let height = workingFrame.height * 0.7
            return CGRect(
                x: workingFrame.origin.x + (workingFrame.width - width) / 2,
                y: workingFrame.origin.y + (workingFrame.height - height) / 2,
                width: width,
                height: height
            )
        case .maximize:
            return CGRect(
                x: workingFrame.origin.x + padding,
                y: workingFrame.origin.y + padding,
                width: workingFrame.width - (padding * 2),
                height: workingFrame.height - (padding * 2)
            )
        case .topLeft:
            return CGRect(
                x: workingFrame.origin.x + padding,
                y: workingFrame.origin.y + padding,
                width: (workingFrame.width / 2) - (padding * 1.5),
                height: (workingFrame.height / 2) - (padding * 1.5)
            )
        case .topRight:
            return CGRect(
                x: workingFrame.origin.x + (workingFrame.width / 2) + (padding * 0.5),
                y: workingFrame.origin.y + padding,
                width: (workingFrame.width / 2) - (padding * 1.5),
                height: (workingFrame.height / 2) - (padding * 1.5)
            )
        case .bottomLeft:
            return CGRect(
                x: workingFrame.origin.x + padding,
                y: workingFrame.origin.y + (workingFrame.height / 2) + (padding * 0.5),
                width: (workingFrame.width / 2) - (padding * 1.5),
                height: (workingFrame.height / 2) - (padding * 1.5)
            )
        case .bottomRight:
            return CGRect(
                x: workingFrame.origin.x + (workingFrame.width / 2) + (padding * 0.5),
                y: workingFrame.origin.y + (workingFrame.height / 2) + (padding * 0.5),
                width: (workingFrame.width / 2) - (padding * 1.5),
                height: (workingFrame.height / 2) - (padding * 1.5)
            )
        case .leftTwoThirds:
            return CGRect(
                x: workingFrame.origin.x + padding,
                y: workingFrame.origin.y + padding,
                width: (workingFrame.width * 2 / 3) - (padding * 1.5),
                height: workingFrame.height - (padding * 2)
            )
        case .rightTwoThirds:
            return CGRect(
                x: workingFrame.origin.x + (workingFrame.width / 3) + (padding * 0.5),
                y: workingFrame.origin.y + padding,
                width: (workingFrame.width * 2 / 3) - (padding * 1.5),
                height: workingFrame.height - (padding * 2)
            )
        }
    }
    
    private func convertVisibleFrameToTopLeft(_ visibleFrame: CGRect) -> CGRect {
        // Convert NSScreen's visibleFrame (bottom-left origin) to top-left origin
        guard let mainScreen = NSScreen.screens.first else { return visibleFrame }
        let mainScreenHeight = mainScreen.frame.height
        
        return CGRect(
            x: visibleFrame.origin.x,
            y: mainScreenHeight - visibleFrame.origin.y - visibleFrame.height,
            width: visibleFrame.width,
            height: visibleFrame.height
        )
    }
    
    private func animateWindow(_ window: AXUIElement, to frame: CGRect, style: AnimationStyle) {
        // Get current position and size
        var currentPosition: AnyObject?
        var currentSize: AnyObject?
        
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &currentPosition)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &currentSize)
        
        guard let currentPosValue = currentPosition,
              let currentSizeValue = currentSize else { return }
        
        var currentPoint = CGPoint()
        var currentSizeStruct = CGSize()
        
        AXValueGetValue(currentPosValue as! AXValue, .cgPoint, &currentPoint)
        AXValueGetValue(currentSizeValue as! AXValue, .cgSize, &currentSizeStruct)
        
        // Animate using timer
        let duration = style.duration
        let steps = Int(duration * 60) // 60 FPS
        let stepDuration = duration / Double(steps)
        
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            
            let progress = Double(currentStep) / Double(steps)
            let easedProgress = self.applyEasing(progress, style: style)
            
            // Interpolate position and size
            let newX = currentPoint.x + (frame.origin.x - currentPoint.x) * easedProgress
            let newY = currentPoint.y + (frame.origin.y - currentPoint.y) * easedProgress
            let newWidth = currentSizeStruct.width + (frame.width - currentSizeStruct.width) * easedProgress
            let newHeight = currentSizeStruct.height + (frame.height - currentSizeStruct.height) * easedProgress
            
            // Set new position and size
            var newPosition = CGPoint(x: newX, y: newY)
            var newSize = CGSize(width: newWidth, height: newHeight)
            
            let positionValue = AXValueCreate(.cgPoint, &newPosition)!
            let sizeValue = AXValueCreate(.cgSize, &newSize)!
            
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
            
            if currentStep >= steps {
                timer.invalidate()
            }
        }
    }
    
    private func applyEasing(_ t: Double, style: AnimationStyle) -> Double {
        switch style {
        case .linear:
            return t
            
        case .smooth:
            // Ease-in-out cubic
            if t < 0.5 {
                return 4 * t * t * t
            } else {
                return 1 + 4 * (t - 1) * (t - 1) * (t - 1)
            }
            
        case .bounce:
            // Bounce effect
            if t < 0.363636 {
                return 7.5625 * t * t
            } else if t < 0.727272 {
                let t2 = t - 0.545454
                return 7.5625 * t2 * t2 + 0.75
            } else if t < 0.909090 {
                let t2 = t - 0.818181
                return 7.5625 * t2 * t2 + 0.9375
            } else {
                let t2 = t - 0.954545
                return 7.5625 * t2 * t2 + 0.984375
            }
            
        case .elastic:
            // Elastic ease-out
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            let p = 0.3
            let s = p / 4
            return pow(2, -10 * t) * sin((t - s) * (2 * .pi) / p) + 1
            
        case .spring:
            // Spring physics
            let damping = 0.5
            let velocity = 0.0
            let mass = 1.0
            let stiffness = 100.0
            let c = 2 * sqrt(mass * stiffness) * damping
            let omega = sqrt(stiffness / mass)
            let x = exp(-c * t / (2 * mass)) * cos(omega * t)
            return 1 - x
            
        case .overshoot:
            // Back ease-out
            let s = 1.70158
            let t2 = t - 1
            return t2 * t2 * ((s + 1) * t2 + s) + 1
            
        case .anticipate:
            // Back ease-in-out
            let s = 1.70158 * 1.525
            let t2 = t * 2
            if t2 < 1 {
                return 0.5 * (t2 * t2 * ((s + 1) * t2 - s))
            } else {
                let t3 = t2 - 2
                return 0.5 * (t3 * t3 * ((s + 1) * t3 + s) + 2)
            }
            
        case .rubberBand:
            // Rubber band effect
            if t < 0.4 {
                return pow(2, -10 * t) * sin((t - 0.075) * (2 * .pi) / 0.3) + 1
            } else {
                return 1 - pow(2, -10 * (t - 0.4)) * sin(((t - 0.4) - 0.075) * (2 * .pi) / 0.3)
            }
            
        case .jello:
            // Jello wobble
            if t == 0 || t == 1 { return t }
            let p = 0.4
            let a = 0.1
            let s = asin(1 / (1 / a)) * (p / (2 * .pi))
            return 1 + (1 / a) * pow(2, -10 * t) * sin((t - s) * (2 * .pi) / p)
            
        case .wobbly:
            // Wobbly motion
            let frequency = 3.0
            let decay = 8.0
            return 1 - exp(-decay * t) * cos(frequency * .pi * t)
            
        // MARK: - Smooth & Sleek Animations
        case .glide:
            // Ultra-smooth with gentle acceleration/deceleration
            let t2 = t * t
            let t3 = t2 * t
            return 3 * t2 - 2 * t3
            
        case .silk:
            // Buttery smooth with momentum curves
            if t < 0.5 {
                return 2 * t * t
            } else {
                return -1 + (4 - 2 * t) * t
            }
            
        case .flow:
            // Fluid motion inspired by water dynamics
            let t2 = t * t
            let t3 = t2 * t
            let t4 = t3 * t
            return 6 * t4 * t - 15 * t4 + 10 * t3
            
        case .drift:
            // Gentle floating motion with soft settling
            return 1 - pow(1 - t, 3)
            
        // MARK: - Playful & Fun Animations
        case .zoom:
            // Quick scale-in effect with position change
            if t < 0.8 {
                return pow(t / 0.8, 0.3)
            } else {
                let overshoot = (t - 0.8) / 0.2
                return 1 + 0.1 * sin(overshoot * .pi * 3) * (1 - overshoot)
            }
            
        case .pop:
            // Satisfying pop-in with slight overshoot and settle
            if t < 0.7 {
                return pow(t / 0.7, 2)
            } else {
                let settle = (t - 0.7) / 0.3
                return 1 + 0.15 * sin(settle * .pi * 2) * (1 - settle)
            }
            
        case .swoosh:
            // Fast curved motion with trailing effect
            let t2 = t * t
            return t2 * (3 - 2 * t)
            
        case .whip:
            // Snappy movement with elastic snap-back
            if t < 0.6 {
                return pow(t / 0.6, 1.5)
            } else {
                let snap = (t - 0.6) / 0.4
                return 1 + 0.2 * sin(snap * .pi * 4) * pow(1 - snap, 2)
            }
            
        case .bounce2x:
            // Double bounce for extra playfulness
            if t < 0.4 {
                let t1 = t / 0.4
                return 0.5 * (7.5625 * t1 * t1)
            } else if t < 0.7 {
                let t2 = (t - 0.4) / 0.3
                return 0.5 + 0.3 * (7.5625 * t2 * t2)
            } else {
                let t3 = (t - 0.7) / 0.3
                return 0.8 + 0.2 * (7.5625 * t3 * t3)
            }
            
        case .wiggle:
            // Subtle side-to-side motion during movement
            let baseProgress = t * t * (3 - 2 * t)
            let wiggleAmount = 0.02 * sin(t * .pi * 8) * (1 - t)
            return baseProgress + wiggleAmount
            
        // MARK: - Sophisticated & Premium Animations
        case .magnetic:
            // Attraction-based movement with pull effect
            let attraction = 1 - pow(1 - t, 4)
            let pull = 0.05 * sin(t * .pi * 2) * (1 - t)
            return attraction + pull
            
        case .gravity:
            // Physics-based falling with realistic deceleration
            if t < 0.8 {
                return 0.5 * pow(t / 0.8, 2)
            } else {
                let decel = (t - 0.8) / 0.2
                return 0.5 + 0.5 * (2 * decel - decel * decel)
            }
            
        case .orbit:
            // Curved path movement like planetary motion
            let angle = t * .pi * 0.5
            let radius = 1 - t
            let orbital = sin(angle) * radius * 0.1
            return t + orbital
            
        case .spiral:
            // Gentle spiral approach to final position
            let spiralAngle = t * .pi * 3
            let spiralRadius = (1 - t) * 0.05
            let spiral = sin(spiralAngle) * spiralRadius
            return t + spiral
            
        case .wave:
            // Sine wave motion path for organic feel
            let baseProgress = t * t * (3 - 2 * t)
            let waveOffset = 0.03 * sin(t * .pi * 4) * sin(t * .pi)
            return baseProgress + waveOffset
            
        // MARK: - Energetic & Dynamic Animations
        case .rocket:
            // Fast launch with trail effect
            if t < 0.3 {
                return pow(t / 0.3, 3) * 0.1
            } else {
                let boost = (t - 0.3) / 0.7
                return 0.1 + 0.9 * pow(boost, 0.5)
            }
            
        case .teleport:
            // Instant with fade out/in effect
            if t < 0.1 {
                return 0
            } else if t < 0.9 {
                return 1
            } else {
                return 1
            }
            
        case .lightning:
            // Zigzag path with electric energy
            let baseProgress = t * t
            let zigzag = 0.02 * sin(t * .pi * 12) * (1 - t)
            return baseProgress + zigzag
            
        case .pulse:
            // Rhythmic size pulsing during movement
            let baseProgress = t * t * (3 - 2 * t)
            let pulse = 0.01 * sin(t * .pi * 6)
            return baseProgress + pulse
            
        case .tornado:
            // Spinning motion with position change
            let spin = t * .pi * 4
            let spinRadius = (1 - t) * 0.03
            let spinOffset = sin(spin) * spinRadius
            let baseProgress = t * t * (3 - 2 * t)
            return baseProgress + spinOffset
        }
    }
}

// MARK: - Window Positions
enum WindowPosition: String {
    case left, right, top, bottom
    case topLeft, topRight, bottomLeft, bottomRight
    case center, maximize
    case leftTwoThirds, rightTwoThirds
}

// MARK: - HTTP Server
import Network

class HTTPServer {
    private var listener: NWListener?
    private let windowManager: WindowManager
    private let port: UInt16 = 8437
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }
    
    func start() {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        
        do {
            listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: port))
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            listener?.start(queue: .main)
            print("HTTP Server started on port \(port)")
        } catch {
            print("Failed to start server: \(error)")
        }
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                let request = String(data: data, encoding: .utf8) ?? ""
                self.handleRequest(request, connection: connection)
            }
            
            if isComplete {
                connection.cancel()
            }
        }
    }
    
    private func handleRequest(_ request: String, connection: NWConnection) {
        let lines = request.split(separator: "\r\n")
        guard let firstLine = lines.first else { return }
        
        let parts = firstLine.split(separator: " ")
        guard parts.count >= 2 else { return }
        
        let method = String(parts[0])
        let path = String(parts[1])
        
        var response = ""
        
        if method == "POST" && path.starts(with: "/resize/") {
            let pathComponents = path.split(separator: "/")
            if pathComponents.count >= 2 {
                let positionString = String(pathComponents[1])
                
                // Check for animation style parameter
                var animationStyle: AnimationStyle? = nil
                if pathComponents.count >= 3 {
                    let styleString = String(pathComponents[2])
                    animationStyle = AnimationStyle(rawValue: styleString)
                }
                
                if let position = WindowPosition(rawValue: positionString) {
                    DispatchQueue.main.async {
                        self.windowManager.resizeWindow(to: position, animationStyle: animationStyle)
                    }
                    response = createHTTPResponse(200, body: "{\"status\": \"success\", \"position\": \"\(positionString)\"}")
                } else {
                    response = createHTTPResponse(400, body: "{\"error\": \"Invalid position\"}")
                }
            }
        } else if method == "POST" && path.starts(with: "/monitor/") {
            let pathComponents = path.split(separator: "/")
            if pathComponents.count >= 2 {
                let monitorString = String(pathComponents[1])
                
                // Check for animation style parameter
                var animationStyle: AnimationStyle? = nil
                if pathComponents.count >= 3 {
                    let styleString = String(pathComponents[2])
                    animationStyle = AnimationStyle(rawValue: styleString)
                }
                
                if let monitorIndex = Int(monitorString) {
                    DispatchQueue.main.async {
                        let success = self.windowManager.moveWindowToMonitor(monitorIndex: monitorIndex, animationStyle: animationStyle)
                        if success {
                            let responseBody = animationStyle != nil ? 
                                "{\"status\": \"success\", \"action\": \"moved_to_monitor\", \"monitor\": \(monitorIndex), \"animation\": \"\(animationStyle!.rawValue)\"}" :
                                "{\"status\": \"success\", \"action\": \"moved_to_monitor\", \"monitor\": \(monitorIndex)}"
                            let successResponse = createHTTPResponse(200, body: responseBody)
                            connection.send(content: successResponse.data(using: .utf8)!, completion: .contentProcessed { _ in
                                connection.cancel()
                            })
                        } else {
                            let errorResponse = createHTTPResponse(400, body: "{\"error\": \"Invalid monitor index: \(monitorIndex). Available monitors: 1-\(NSScreen.screens.count)\"}")
                            connection.send(content: errorResponse.data(using: .utf8)!, completion: .contentProcessed { _ in
                                connection.cancel()
                            })
                        }
                        return
                    }
                    return
                } else {
                    response = createHTTPResponse(400, body: "{\"error\": \"Monitor index must be a positive integer\"}")
                }
            }
        } else if method == "GET" && path == "/" {
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Window Resizer</title>
                <style>
                    body { 
                        font-family: -apple-system, sans-serif; 
                        padding: 20px; 
                        background: #1a1a1a;
                        color: #fff;
                    }
                    button { 
                        margin: 5px; 
                        padding: 10px 20px; 
                        font-size: 16px; 
                        cursor: pointer;
                        background: #333;
                        color: #fff;
                        border: 1px solid #555;
                        border-radius: 8px;
                        transition: all 0.2s;
                    }
                    button:hover {
                        background: #444;
                        transform: scale(1.05);
                    }
                    .grid { 
                        display: grid; 
                        grid-template-columns: repeat(3, 1fr); 
                        gap: 10px; 
                        max-width: 400px;
                        margin: 20px 0;
                    }
                    .animation-selector {
                        margin: 20px 0;
                        padding: 20px;
                        background: #2a2a2a;
                        border-radius: 10px;
                    }
                    select {
                        padding: 8px;
                        font-size: 16px;
                        background: #333;
                        color: #fff;
                        border: 1px solid #555;
                        border-radius: 5px;
                    }
                </style>
            </head>
            <body>
                <h1>Window Resizer Control</h1>
                
                <div class="animation-selector">
                    <label>Animation Style: </label>
                    <select id="animationStyle">
                        <option value="">Default</option>
                        <optgroup label="Classic">
                            <option value="linear">Linear</option>
                            <option value="smooth">Smooth</option>
                            <option value="bounce">Bounce</option>
                            <option value="elastic">Elastic</option>
                            <option value="spring">Spring</option>
                            <option value="overshoot">Overshoot</option>
                            <option value="anticipate">Anticipate</option>
                            <option value="rubberBand">Rubber Band</option>
                            <option value="jello">Jello</option>
                            <option value="wobbly">Wobbly</option>
                        </optgroup>
                        <optgroup label="✨ Smooth & Sleek">
                            <option value="glide">✨ Glide</option>
                            <option value="silk">🪶 Silk</option>
                            <option value="flow">🌊 Flow</option>
                            <option value="drift">☁️ Drift</option>
                        </optgroup>
                        <optgroup label="🎈 Playful & Fun">
                            <option value="zoom">🔍 Zoom</option>
                            <option value="pop">🎈 Pop</option>
                            <option value="swoosh">💨 Swoosh</option>
                            <option value="whip">⚡ Whip</option>
                            <option value="bounce2x">🏀 Double Bounce</option>
                            <option value="wiggle">🐍 Wiggle</option>
                        </optgroup>
                        <optgroup label="🧲 Premium & Sophisticated">
                            <option value="magnetic">🧲 Magnetic</option>
                            <option value="gravity">🌍 Gravity</option>
                            <option value="orbit">🪐 Orbit</option>
                            <option value="spiral">🌀 Spiral</option>
                            <option value="wave">〰️ Wave</option>
                        </optgroup>
                        <optgroup label="🚀 Dynamic & Energetic">
                            <option value="rocket">🚀 Rocket</option>
                            <option value="teleport">✨ Teleport</option>
                            <option value="lightning">⚡ Lightning</option>
                            <option value="pulse">💓 Pulse</option>
                            <option value="tornado">🌪️ Tornado</option>
                        </optgroup>
                    </select>
                </div>
                
                <h2>Window Positioning</h2>
                <div class="grid">
                    <button onclick="resize('topLeft')">↖️ Top Left</button>
                    <button onclick="resize('top')">⬆️ Top</button>
                    <button onclick="resize('topRight')">↗️ Top Right</button>
                    <button onclick="resize('left')">⬅️ Left</button>
                    <button onclick="resize('center')">⏺ Center</button>
                    <button onclick="resize('right')">➡️ Right</button>
                    <button onclick="resize('bottomLeft')">↙️ Bottom Left</button>
                    <button onclick="resize('bottom')">⬇️ Bottom</button>
                    <button onclick="resize('bottomRight')">↘️ Bottom Right</button>
                </div>
                <button onclick="resize('maximize')" style="width: 100%; margin-top: 10px;">🔳 Maximize</button>
                
                <h3>Two-Thirds Positioning</h3>
                <div style="display: flex; gap: 10px; margin: 10px 0;">
                    <button onclick="resize('leftTwoThirds')">⬅️ Left 2/3</button>
                    <button onclick="resize('rightTwoThirds')">➡️ Right 2/3</button>
                </div>
                
                <h2>Monitor Movement</h2>
                <div id="monitorButtons" style="margin: 20px 0;">
                    <button onclick="moveToMonitor(1)">📺 Move to Monitor 1</button>
                    <button onclick="moveToMonitor(2)">📺 Move to Monitor 2</button>
                    <button onclick="moveToMonitor(3)">📺 Move to Monitor 3</button>
                    <button onclick="moveToMonitor(4)">📺 Move to Monitor 4</button>
                </div>
                
                <script>
                    function resize(position) {
                        const style = document.getElementById('animationStyle').value;
                        const url = style ? '/resize/' + position + '/' + style : '/resize/' + position;
                        fetch(url, { method: 'POST' })
                            .then(r => r.json())
                            .then(data => console.log(data));
                    }
                    
                    function moveToMonitor(monitorIndex) {
                        const style = document.getElementById('animationStyle').value;
                        const url = style ? '/monitor/' + monitorIndex + '/' + style : '/monitor/' + monitorIndex;
                        fetch(url, { method: 'POST' })
                            .then(r => r.json())
                            .then(data => {
                                console.log(data);
                                if (data.error) {
                                    alert('Error: ' + data.error);
                                }
                            })
                            .catch(err => {
                                console.error('Error:', err);
                                alert('Failed to move window to monitor ' + monitorIndex);
                            });
                    }
                </script>
            </body>
            </html>
            """
            response = createHTTPResponse(200, body: html, contentType: "text/html")
        } else {
            response = createHTTPResponse(404, body: "{\"error\": \"Not found\"}")
        }
        
        let responseData = response.data(using: .utf8)!
        connection.send(content: responseData, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}

// Helper function to create HTTP responses
func createHTTPResponse(_ statusCode: Int, body: String, contentType: String = "application/json") -> String {
    let statusText = statusCode == 200 ? "OK" : statusCode == 400 ? "Bad Request" : "Not Found"
    return """
    HTTP/1.1 \(statusCode) \(statusText)\r
    Content-Type: \(contentType)\r
    Content-Length: \(body.count)\r
    Access-Control-Allow-Origin: *\r
    \r
    \(body)
    """
}
