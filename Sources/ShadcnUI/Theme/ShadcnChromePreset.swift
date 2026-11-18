import SwiftUI

/// Built-in chrome recipes. Add new looks here — components already read tokens
/// from `ShadcnChromeSpec` and do not need theme-name branches.
extension ShadcnChromeSpec {

    /// Stock shadcn: thin borders, soft blur shadows, default radius.
    public static let `default` = ShadcnChromeSpec(
        id: "default",
        name: "Soft",
        borderWidth: 1,
        preferredRadius: ShadcnRadius(),
        hardShadow: .default,
        surfaceElevation: .softSM,
        controlElevation: .softXS,
        emphasizesControlStroke: false,
        fieldStroke: .input,
        pressBehavior: .fade,
        prefersOpaqueFills: false,
        prefersGlassOff: false,
        progressHeight: 8,
        progressTrackOpacity: 0.2,
        checkboxUsesThemeRadius: false
    )

    /// Neobrutalism: `border-2`, hard offset shadow, hover shifts into the shadow.
    public static let brutal = ShadcnChromeSpec(
        id: "brutal",
        name: "Brutal",
        borderWidth: 2,
        preferredRadius: ShadcnRadius(base: 5),
        hardShadow: .default,
        surfaceElevation: .hard,
        controlElevation: .hard,
        emphasizesControlStroke: true,
        fieldStroke: .border,
        pressBehavior: .shiftIntoShadow,
        prefersOpaqueFills: true,
        prefersGlassOff: true,
        progressHeight: 10,
        progressTrackOpacity: 0.15,
        checkboxUsesThemeRadius: true
    )

    /// Built-in chrome recipes for pickers (Soft / Brutal today).
    public static let presets: [ShadcnChromeSpec] = [.default, .brutal]

    public static func named(_ id: String?) -> ShadcnChromeSpec {
        presets.first { $0.id == id } ?? .default
    }
}
