import SwiftUI

/// Pointer / keyboard helpers that compile on watchOS as no-ops.
///
/// SwiftUI marks `onHover`, `onKeyPress`, `keyboardShortcut`, and
/// `onContinuousHover` unavailable on watchOS — calling them directly fails
/// the build even inside `applyIf`. These wrappers keep call sites uniform.
extension View {
    /// Pointer enter/exit. No-op on watchOS.
    @ViewBuilder
    func shadcnOnHover(perform action: @escaping (Bool) -> Void) -> some View {
        #if os(watchOS)
        self
        #else
        onHover(perform: action)
        #endif
    }

    /// Continuous pointer tracking. No-op on watchOS.
    ///
    /// `action` receives the local location while the pointer is over the
    /// view, and `nil` when it leaves — matching the useful subset of
    /// `HoverPhase` without naming that unavailable type on watchOS.
    @ViewBuilder
    func shadcnOnContinuousHover(perform action: @escaping (CGPoint?) -> Void) -> some View {
        #if os(watchOS)
        self
        #else
        onContinuousHover { phase in
            switch phase {
            case .active(let location): action(location)
            case .ended: action(nil)
            }
        }
        #endif
    }

    /// Escape / cancel keyboard shortcut. No-op on watchOS.
    @ViewBuilder
    func shadcnCancelKeyboardShortcut() -> some View {
        #if os(watchOS)
        self
        #else
        keyboardShortcut(.cancelAction)
        #endif
    }

    /// Arrow / space / tab / escape key handling. No-op on watchOS.
    @ViewBuilder
    func shadcnOnKeyPress(
        _ key: ShadcnKeyPress,
        action: @escaping () -> ShadcnKeyPressResult
    ) -> some View {
        #if os(watchOS)
        self
        #else
        onKeyPress(key.keyEquivalent) {
            switch action() {
            case .handled: return .handled
            case .ignored: return .ignored
            }
        }
        #endif
    }
}

/// Keys we wire for desktop/iPad keyboard paths — avoids naming
/// `KeyEquivalent` in signatures that must exist on watchOS.
enum ShadcnKeyPress: Sendable {
    case upArrow, downArrow, leftArrow, rightArrow, space, tab, escape

    #if !os(watchOS)
    var keyEquivalent: KeyEquivalent {
        switch self {
        case .upArrow: .upArrow
        case .downArrow: .downArrow
        case .leftArrow: .leftArrow
        case .rightArrow: .rightArrow
        case .space: .space
        case .tab: .tab
        case .escape: .escape
        }
    }
    #endif
}

enum ShadcnKeyPressResult: Sendable {
    case handled
    case ignored
}
