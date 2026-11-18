import SwiftUI
import XCTest
@testable import ShadcnUI

/// Pins neobrutal hard-shadow chrome: zero blur, 4pt offset, border-2, radius 5.
final class BrutalChromeTests: XCTestCase {

    func testHardShadowHasZeroBlurAndDefaultOffset() {
        let shadow = ShadcnShadow.hard(color: .black)
        XCTAssertEqual(shadow.radius, 0)
        XCTAssertEqual(shadow.x, ShadcnHardShadow.defaultOffset)
        XCTAssertEqual(shadow.y, ShadcnHardShadow.defaultOffset)
    }

    func testHardShadowSpecBuildsMatchingShadow() {
        let spec = ShadcnHardShadow(x: 6, y: 3)
        let shadow = spec.shadow(color: .red)
        XCTAssertEqual(shadow.radius, 0)
        XCTAssertEqual(shadow.x, 6)
        XCTAssertEqual(shadow.y, 3)
    }

    func testBrutalChromePrefersRadiusFiveAndBorderTwo() {
        XCTAssertEqual(ShadcnChromeSpec.brutal.preferredRadius.base, 5)
        XCTAssertEqual(ShadcnChromeSpec.brutal.borderWidth, 2)
        XCTAssertEqual(ShadcnChromeSpec.default.borderWidth, 1)
        XCTAssertEqual(ShadcnChromeSpec.default.preferredRadius.base, 10)
        XCTAssertTrue(ShadcnChromeSpec.brutal.usesHardElevation)
        XCTAssertFalse(ShadcnChromeSpec.default.usesHardElevation)
        XCTAssertEqual(ShadcnChromeSpec.brutal.surfaceElevation, .hard)
        XCTAssertEqual(ShadcnChromeSpec.brutal.pressBehavior, .shiftIntoShadow)
        XCTAssertEqual(ShadcnChromeSpec.default.surfaceElevation, .softSM)
        XCTAssertEqual(ShadcnChromeSpec.default.controlElevation, .softXS)
    }

    func testNeoBrutalismThemePresetWiresChromeAndRadius() {
        let theme = ShadcnTheme.neoBrutalism()
        XCTAssertEqual(theme.chrome, .brutal)
        XCTAssertTrue(theme.isBrutal)
        XCTAssertEqual(theme.borderWidth, 2)
        XCTAssertEqual(theme.radius.base, 5)
        XCTAssertEqual(theme.hardShadow.x, ShadcnHardShadow.defaultOffset)
        XCTAssertEqual(theme.hardShadow.y, ShadcnHardShadow.defaultOffset)
        XCTAssertEqual(theme.hardShadow, theme.chrome.hardShadow)
        XCTAssertTrue(theme.chrome.prefersGlassOff)
        XCTAssertTrue(theme.chrome.prefersOpaqueFills)
    }

    func testThemeRadiusDefaultsToChromePreferred() {
        let soft = ShadcnTheme(chrome: .default)
        XCTAssertEqual(soft.radius.base, ShadcnChromeSpec.default.preferredRadius.base)

        let brutal = ShadcnTheme(chrome: .brutal)
        XCTAssertEqual(brutal.radius.base, 5)

        let overridden = ShadcnTheme(radius: ShadcnRadius(base: 14), chrome: .brutal)
        XCTAssertEqual(overridden.radius.base, 14)
    }

    func testHardShadowDefaultOffsetMatchesPlatform() {
        #if os(watchOS)
        XCTAssertEqual(ShadcnHardShadow.defaultOffset, 3)
        #else
        XCTAssertEqual(ShadcnHardShadow.defaultOffset, 4)
        #endif
    }

    func testNeoBrutalismBaseColorPrefersBrutalChrome() {
        XCTAssertEqual(ShadcnBaseColor.neoBrutalism.chrome, .brutal)
        XCTAssertTrue(ShadcnBaseColor.neoBrutalism.prefersBrutalChrome)
        XCTAssertFalse(ShadcnBaseColor.neutral.prefersBrutalChrome)
        XCTAssertEqual(ShadcnBaseColor.neoBrutalism.theme.chrome, .brutal)
        XCTAssertEqual(ShadcnBaseColor.neutral.theme.chrome, .default)
        XCTAssertEqual(ShadcnBaseColor.neoBrutalism.theme.radius.base, 5)
    }

    func testNamedLookupFindsNeoBrutalism() {
        XCTAssertEqual(ShadcnBaseColor.named("neo-brutalism").id, "neo-brutalism")
        XCTAssertEqual(ShadcnChromeSpec.named("brutal"), .brutal)
        XCTAssertEqual(ShadcnChromeSpec.named("missing"), .default)
    }

    func testHardOrNoneDropsSoftLevels() {
        XCTAssertEqual(ShadcnElevation.softSM.hardOrNone, .none)
        XCTAssertEqual(ShadcnElevation.hard.hardOrNone, .hard)
        XCTAssertEqual(ShadcnElevation.none.hardOrNone, .none)
    }

    func testHardShadowFactoryStaysSharp() {
        // Kept for the API; rendering uses `shadcnHardEdge` because
        // `shadow(radius: 0)` is unreliable in SwiftUI.
        let shadow = ShadcnShadow.hard(color: .white, x: 4, y: 4)
        XCTAssertEqual(shadow.radius, 0)
        XCTAssertEqual(shadow.color, Color.white)
    }
}
