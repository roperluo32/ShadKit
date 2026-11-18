import SwiftUI

/// Named soft shadow from the Tailwind scale — keeps chrome specs `Hashable`
/// without embedding `Color`.
public enum ShadcnSoftShadowLevel: String, Sendable, Hashable, CaseIterable {
    case xs, sm, md, lg, xl

    public var shadow: ShadcnShadow {
        switch self {
        case .xs: .xs
        case .sm: .sm
        case .md: .md
        case .lg: .lg
        case .xl: .xl
        }
    }
}

/// How a surface sits off the page — soft blur, hard offset slab, or flat.
public enum ShadcnElevation: String, Sendable, Hashable {
    case softXS = "soft-xs"
    case softSM = "soft-sm"
    case softMD = "soft-md"
    case softLG = "soft-lg"
    case softXL = "soft-xl"
    /// Zero-blur offset slab; offset comes from `ShadcnChromeSpec.hardShadow`.
    case hard
    case none

    public init(soft level: ShadcnSoftShadowLevel) {
        switch level {
        case .xs: self = .softXS
        case .sm: self = .softSM
        case .md: self = .softMD
        case .lg: self = .softLG
        case .xl: self = .softXL
        }
    }

    public var softLevel: ShadcnSoftShadowLevel? {
        switch self {
        case .softXS: .xs
        case .softSM: .sm
        case .softMD: .md
        case .softLG: .lg
        case .softXL: .xl
        case .hard, .none: nil
        }
    }

    public var isHard: Bool { self == .hard }

    /// Soft levels collapse to `.none` — for controls that only grow a slab
    /// under hard chrome (badge, avatar, progress, alert).
    public var hardOrNone: ShadcnElevation { isHard ? .hard : .none }
}

/// Idle stroke colour for fields that normally use `input` vs always `border`.
public enum ShadcnFieldStroke: String, Sendable, Hashable {
    case input
    case border
}

/// Press / hover response for elevated controls.
public enum ShadcnPressBehavior: String, Sendable, Hashable {
    /// Stock shadcn: drop opacity slightly while pressed.
    case fade
    /// Neobrutal: translate into the hard shadow and hide the slab.
    case shiftIntoShadow
    case none
}

/// Visual recipe beyond the palette — borders, radius, elevation, press.
///
/// Components read these tokens; they never branch on a theme name. Add a new
/// look in `ShadcnChromePreset.swift`, not by sprinkling `if theme.isFoo`
/// through primitives.
public struct ShadcnChromeSpec: Sendable, Hashable, Identifiable {
    public var id: String
    public var name: String
    public var borderWidth: CGFloat
    /// Default radius when a theme is assembled from this chrome without an override.
    public var preferredRadius: ShadcnRadius
    /// Offset for `.hard` elevation (`Npt Npt 0 0`). Unused when elevation is soft.
    public var hardShadow: ShadcnHardShadow

    /// Cards, alerts, large panels.
    public var surfaceElevation: ShadcnElevation
    /// Inputs, switches, badges, filled buttons.
    public var controlElevation: ShadcnElevation

    /// Force a visible border on controls that are borderless in soft chrome
    /// (switch track, progress, avatar, non-outline badge).
    public var emphasizesControlStroke: Bool

    public var fieldStroke: ShadcnFieldStroke
    public var pressBehavior: ShadcnPressBehavior

    /// Opaque fills so a hard-edge slab only peeks as an offset strip.
    public var prefersOpaqueFills: Bool
    /// Hard edges fight frosted materials — default glass off for this chrome.
    public var prefersGlassOff: Bool

    public var progressHeight: CGFloat
    public var progressTrackOpacity: Double

    /// Checkbox uses `radius.sm` instead of a fixed 4pt corner.
    public var checkboxUsesThemeRadius: Bool

    public init(
        id: String,
        name: String,
        borderWidth: CGFloat,
        preferredRadius: ShadcnRadius,
        hardShadow: ShadcnHardShadow = .default,
        surfaceElevation: ShadcnElevation,
        controlElevation: ShadcnElevation,
        emphasizesControlStroke: Bool,
        fieldStroke: ShadcnFieldStroke,
        pressBehavior: ShadcnPressBehavior,
        prefersOpaqueFills: Bool,
        prefersGlassOff: Bool,
        progressHeight: CGFloat,
        progressTrackOpacity: Double,
        checkboxUsesThemeRadius: Bool
    ) {
        self.id = id
        self.name = name
        self.borderWidth = borderWidth
        self.preferredRadius = preferredRadius
        self.hardShadow = hardShadow
        self.surfaceElevation = surfaceElevation
        self.controlElevation = controlElevation
        self.emphasizesControlStroke = emphasizesControlStroke
        self.fieldStroke = fieldStroke
        self.pressBehavior = pressBehavior
        self.prefersOpaqueFills = prefersOpaqueFills
        self.prefersGlassOff = prefersGlassOff
        self.progressHeight = progressHeight
        self.progressTrackOpacity = progressTrackOpacity
        self.checkboxUsesThemeRadius = checkboxUsesThemeRadius
    }

    public static func == (lhs: ShadcnChromeSpec, rhs: ShadcnChromeSpec) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var usesHardElevation: Bool {
        surfaceElevation.isHard || controlElevation.isHard
    }
}

/// Back-compat alias — prefer `ShadcnChromeSpec`.
public typealias ShadcnChrome = ShadcnChromeSpec

/// Offset for neobrutal hard shadows (`--box-shadow-x/y`).
///
/// Defaults to 4pt on phone/desktop and 3pt on watchOS so the slab still reads
/// on a small dial without eating half the control.
public struct ShadcnHardShadow: Sendable, Hashable {
    public var x: CGFloat
    public var y: CGFloat

    public init(x: CGFloat = ShadcnHardShadow.defaultOffset, y: CGFloat = ShadcnHardShadow.defaultOffset) {
        self.x = x
        self.y = y
    }

    public static let `default` = ShadcnHardShadow()

    /// Platform-tuned default offset (CSS reference is 4px).
    public static var defaultOffset: CGFloat {
        #if os(watchOS)
        3
        #else
        4
        #endif
    }

    public func shadow(color: Color) -> ShadcnShadow {
        .hard(color: color, x: x, y: y)
    }
}
