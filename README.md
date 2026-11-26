# GrabKit

Automated website and App Store screenshots for Apple-platform apps, from a UI test. Named after [Grab](https://en.wikipedia.org/wiki/Grab_(software)), the Mac's screenshot utility from NeXTSTEP until Mojave.

- **GrabSupport**, the app side: launch arguments, light or dark appearance, a fail-closed launch decision, and a fixed window size.
- **GrabTesting**, the UI test side: drive the app to a screen, capture the window (or a crop of the screen for menus and sheets), detect light or dark, name the shots, attach them.
- **grab-export**: copies a run's shots out of its `.xcresult` as `NN-slug-light.png` and `NN-slug-dark.png`.

Requires Swift 6.4 (Xcode 27.2, as CI uses). GrabKit declares macOS 27, iOS 16, watchOS 9, tvOS 16, visionOS 1 and Mac Catalyst 16, and builds on Linux too:

| Platform | What's there |
| --- | --- |
| macOS | Everything: `GrabWindowSizer`, `GrabAppearance.apply()`, the XCUITest runner, `grab-export`. |
| iOS, Mac Catalyst, tvOS, visionOS | `GrabAppearance.userInterfaceStyle` and `apply(to:)` for a `UIWindow` instead of AppKit's; no `GrabWindowSizer`. `parkPointer()` does nothing where there's no pointer (tvOS, visionOS). |
| watchOS | As above, without the UIKit appearance API; the runner can't switch the watch's appearance. |
| Linux | GrabSupport's launch arguments and decision (logged to stderr instead of OSLog), `GrabCrop`, `GrabNaming`, `GrabFixture` and GrabExportCore. No `GrabImage` (CoreGraphics and ImageIO) or XCUITest runner. |

`grab-export` runs xcresulttool, so it only does its job on macOS; elsewhere it builds and exits with an error.

## The convention

1. **Mock data, never real services.** Screenshot mode fakes everything with real state behind it, so the Screenshots build needs no restricted entitlement.
2. **Its own bundle ID.** A `Screenshots` build configuration (Debug-based) builds `<bundle ID>.Screenshots`, signed ad hoc, with its own container, defaults and privacy permissions, and XCUITest can't kill the user's running copy.
3. **Decided at runtime, failing closed.** Every launch asks `GrabLaunchDecision` before it reads any data. A Screenshots build launched with `-<Prefix>Screenshots YES` runs on demo data. A Screenshots build without it quits. Any other build runs live and ignores the flag. There is no compile gate.
4. **No `#if DEBUG` in a package** for anything the Screenshots build needs: Xcode builds local packages with Release settings in a configuration whose name doesn't contain "Debug".

The full convention, with the reasons and per-app notes, is the `mac-app-screenshots` skill in [brightdigit/skills](https://github.com/brightdigit/skills).

## Installation

Add GrabKit to the app's package as a URL dependency:

```swift
.package(url: "https://github.com/brightdigit/GrabKit.git", from: "1.0.0-alpha.1"),
```

Link `GrabSupport` from the app's demo target and `GrabTesting` from the screenshot UI tests' library.

## Usage

App, at launch, before anything reads data:

```swift
import GrabSupport

if GrabLaunchDecision(launchArguments: .init(prefix: "My")).startsScreenshotMode() {
  // Build the app on demo data.
}
```

UI tests:

```swift
import GrabSupport
import GrabTesting
import XCTest

enum Screen: String, CaseIterable, GrabScreen {
  case editor, about

  var baseName: String {
    GrabNaming.baseName(number: (Self.allCases.firstIndex(of: self) ?? 0) + 1, slug: rawValue)
  }

  func launchArguments(appearance: GrabAppearance) -> [String] {
    GrabLaunchArguments(prefix: "My").launchArguments(appearance: appearance)
  }

  func drive(_ app: XCUIApplication) throws -> GrabTarget {
    GrabTarget(window: try app.windows.firstMatch.waitToExist("window"))
  }
}

final class ScreenshotTests: XCTestCase {
  @MainActor
  func test01Editor() throws {
    try GrabRunner(launchArguments: .init(prefix: "My")).capture(Screen.editor, in: self)
  }
}
```

Export, from the package that depends on GrabKit (SwiftPM builds `grab-export` from its resolved checkout):

```sh
swift run --package-path Packages/MyApp -c release grab-export build/screenshots.xcresult build/screenshots
```

It empties the output folder first. With `--keep-others` it replaces only the files the run exports and leaves the rest, so a run of one appearance keeps the other appearance's shots from an earlier run.

## Development

```sh
make test
make lint   # CI=1 lints without rewriting
```

## License

MIT. See [LICENSE](LICENSE).
