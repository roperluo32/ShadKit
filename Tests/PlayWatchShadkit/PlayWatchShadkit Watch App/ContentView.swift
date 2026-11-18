//
//  ContentView.swift
//  PlayWatchShadkit Watch App
//
//  Watch playground for ShadcnUI — categorized themes + Neo Brutalism chrome.
//

import ShadcnUI
import SwiftUI

struct ContentView: View {
    @State private var baseColor: ShadcnBaseColor = .neutral
    @State private var colorScheme: ColorScheme = .dark
    @State private var groupIndex = 0
    @State private var themeIndex = 0

    private var groups: [(name: String, themes: [ShadcnBaseColor])] {
        ShadcnBaseColor.themeGroups
    }

    private var theme: ShadcnTheme { baseColor.theme }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.x3) {
                    ThemeControls(
                        baseColor: $baseColor,
                        colorScheme: $colorScheme,
                        groupIndex: $groupIndex,
                        themeIndex: $themeIndex,
                        groups: groups
                    )

                    ShadcnSeparator()

                    if theme.chrome.usesHardElevation {
                        NeoBrutalismBanner()
                    }

                    ButtonsDemo()
                    BadgesDemo()
                    ControlsDemo()
                    FeedbackDemo()
                    CardDemo()
                }
                .padding(.horizontal, Space.x2)
                .padding(.vertical, Space.x2)
                // Keep hard-edge slabs inside the scroll clip.
                .shadcnHardEdgeClearance(theme)
            }
            .navigationTitle("ShadKit")
        }
        .preferredColorScheme(colorScheme)
        // glass defaults off when chrome.prefersGlassOff
        .shadcnSurface(theme)
        .id("\(baseColor.id)-\(colorScheme == .dark ? "dark" : "light")")
        .onAppear { syncSelectionFromBaseColor() }
    }

    private func syncSelectionFromBaseColor() {
        for (gi, group) in groups.enumerated() {
            if let ti = group.themes.firstIndex(of: baseColor) {
                groupIndex = gi
                themeIndex = ti
                return
            }
        }
    }
}

// MARK: - Theme

private struct ThemeControls: View {
    @Binding var baseColor: ShadcnBaseColor
    @Binding var colorScheme: ColorScheme
    @Binding var groupIndex: Int
    @Binding var themeIndex: Int
    let groups: [(name: String, themes: [ShadcnBaseColor])]

    @Environment(\.shadcnPalette) private var palette
    @Environment(\.shadcnTheme) private var theme

    private var group: (name: String, themes: [ShadcnBaseColor]) {
        groups[groupIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            Text("Theme")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(palette.mutedForeground)

            Text(group.name)
                .font(.caption2)
                .foregroundStyle(palette.mutedForeground)

            Text(baseColor.name)
                .font(.headline)
                .foregroundStyle(palette.foreground)

            HStack(spacing: Space.x1) {
                let swatches = baseColor.previewSwatches(for: colorScheme)
                ForEach(swatches.indices, id: \.self) { index in
                    Circle()
                        .fill(swatches[index])
                        .frame(width: 12, height: 12)
                        .overlay(Circle().strokeBorder(palette.border, lineWidth: 0.5))
                }
            }

            Text("\(themeIndex + 1) / \(group.themes.count) · \(theme.chrome.id)")
                .font(.caption2)
                .foregroundStyle(palette.mutedForeground)

            HStack(spacing: Space.x2) {
                ShadcnButton("⇠", variant: .outline, size: .small) {
                    cycleGroup(by: -1)
                }
                ShadcnButton(group.name, variant: .secondary, size: .small, fillsWidth: true) {
                    cycleGroup(by: 1)
                }
                ShadcnButton("⇢", variant: .outline, size: .small) {
                    cycleGroup(by: 1)
                }
            }

            HStack(spacing: Space.x2) {
                ShadcnButton("Prev", variant: .outline, size: .small) {
                    cycleTheme(by: -1)
                }
                ShadcnButton("Next", variant: .primary, size: .small) {
                    cycleTheme(by: 1)
                }
            }

            ShadcnButton("Neo Brutalism", variant: .destructive, size: .small, fillsWidth: true) {
                jumpToNeoBrutalism()
            }

            HStack {
                Text(colorScheme == .dark ? "Dark" : "Light")
                    .font(.caption2)
                    .foregroundStyle(palette.mutedForeground)
                Spacer()
                ShadcnSwitch(
                    isOn: Binding(
                        get: { colorScheme == .dark },
                        set: { colorScheme = $0 ? .dark : .light }
                    ),
                    size: .small
                )
                .accessibilityLabel("Dark mode")
            }
        }
    }

    private func cycleGroup(by delta: Int) {
        let next = (groupIndex + delta + groups.count) % groups.count
        groupIndex = next
        themeIndex = 0
        baseColor = groups[next].themes[0]
    }

    private func cycleTheme(by delta: Int) {
        let themes = group.themes
        guard !themes.isEmpty else { return }
        let next = (themeIndex + delta + themes.count) % themes.count
        themeIndex = next
        baseColor = themes[next]
    }

    private func jumpToNeoBrutalism() {
        guard let gi = groups.firstIndex(where: { $0.themes.contains(.neoBrutalism) }),
              let ti = groups[gi].themes.firstIndex(of: .neoBrutalism)
        else { return }
        groupIndex = gi
        themeIndex = ti
        baseColor = .neoBrutalism
    }
}

private struct NeoBrutalismBanner: View {
    @Environment(\.shadcnPalette) private var palette
    @Environment(\.shadcnTheme) private var theme

    var body: some View {
        ShadcnAlert(variant: .primary, systemImage: "hammer.fill") {
            ShadcnAlertTitle("Neo Brutalism")
            ShadcnAlertDescription(
                "border-\(Int(theme.borderWidth)) · shadow \(Int(theme.hardShadow.x))pt"
            )
        }
    }
}

// MARK: - Component demos

private struct ButtonsDemo: View {
    var body: some View {
        demoSection("Buttons") {
            VStack(spacing: Space.x2) {
                ShadcnButton("Primary", variant: .primary, size: .small, fillsWidth: true) {}
                ShadcnButton("Secondary", variant: .secondary, size: .small, fillsWidth: true) {}
                ShadcnButton("Outline", variant: .outline, size: .small, fillsWidth: true) {}
                ShadcnButton("Destructive", variant: .destructive, size: .small, fillsWidth: true) {}
            }
        }
    }
}

private struct BadgesDemo: View {
    var body: some View {
        demoSection("Badges") {
            ShadcnWrapLayout(spacing: Space.x1_5) {
                ShadcnBadge(variant: .primary) { Text("Primary") }
                ShadcnBadge(variant: .secondary) { Text("Secondary") }
                ShadcnBadge(variant: .outline) { Text("Outline") }
                ShadcnBadge(variant: .destructive) { Text("Alert") }
            }
        }
    }
}

private struct ControlsDemo: View {
    @State private var notifications = true
    @State private var volume = 0.45
    @State private var name = ""
    @State private var checked = false

    @Environment(\.shadcnPalette) private var palette

    var body: some View {
        demoSection("Controls") {
            VStack(alignment: .leading, spacing: Space.x3) {
                HStack {
                    Text("Notify")
                        .font(.caption2)
                        .foregroundStyle(palette.foreground)
                    Spacer()
                    ShadcnSwitch(isOn: $notifications, size: .small)
                        .accessibilityLabel("Notifications")
                }

                HStack {
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(palette.foreground)
                    Spacer()
                    ShadcnCheckbox(isChecked: $checked)
                        .accessibilityLabel("Mark done")
                }

                HStack {
                    ShadcnAvatar(initials: "NB", size: .small)
                    Text("Avatar")
                        .font(.caption2)
                        .foregroundStyle(palette.mutedForeground)
                }

                VStack(alignment: .leading, spacing: Space.x1) {
                    Text("Volume \(Int(volume * 100))%")
                        .font(.caption2)
                        .foregroundStyle(palette.mutedForeground)
                    ShadcnSlider(value: $volume, in: 0...1, step: 0.05)
                        .frame(height: 24)
                        .accessibilityLabel("Volume")
                }

                ShadcnTextField("Name", text: $name)
            }
        }
    }
}

private struct FeedbackDemo: View {
    @State private var progress = 0.62

    var body: some View {
        demoSection("Feedback") {
            VStack(alignment: .leading, spacing: Space.x2) {
                ShadcnProgress(value: progress)
                    .frame(height: 10)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            progress = progress > 0.9 ? 0.15 : min(progress + 0.2, 1)
                        }
                    }

                ShadcnAlert(variant: .primary, systemImage: "bell.fill") {
                    ShadcnAlertTitle("Synced")
                    ShadcnAlertDescription("Theme tokens follow appearance.")
                }

                ShadcnAlert(variant: .destructive, systemImage: "exclamationmark.triangle.fill") {
                    ShadcnAlertTitle("Watch only")
                    ShadcnAlertDescription("Link ShadcnUI — not AIElements.")
                }
            }
        }
    }
}

private struct CardDemo: View {
    @Environment(\.shadcnPalette) private var palette
    @Environment(\.shadcnTheme) private var theme

    var body: some View {
        demoSection("Card") {
            ShadcnCard {
                ShadcnCardHeader {
                    ShadcnCardTitle("Playground")
                    ShadcnCardDescription(
                        theme.chrome.usesHardElevation
                            ? "Hard edge + border-2 chrome."
                            : "Switch category, then Prev/Next themes."
                    )
                }
                ShadcnCardContent {
                    Text("Chrome: \(theme.chrome.id)")
                        .font(.caption2)
                        .foregroundStyle(palette.mutedForeground)
                }
                ShadcnCardFooter {
                    ShadcnButton("OK", variant: .secondary, size: .small, fillsWidth: true) {}
                }
            }
        }
    }
}

// MARK: - Layout helper

private func demoSection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
) -> some View {
    DemoSection(title: title, content: content)
}

private struct DemoSection<Content: View>: View {
    let title: String
    let content: Content

    @Environment(\.shadcnPalette) private var palette

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(palette.mutedForeground)
            content
        }
        .padding(.top, Space.x1)
    }
}

#Preview {
    ContentView()
}
