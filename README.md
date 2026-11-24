# GrabKit

Automated website and App Store screenshots for macOS apps, from a UI test. Named after [Grab](https://en.wikipedia.org/wiki/Grab_(software)), the Mac's screenshot utility from NeXTSTEP until Mojave.

- **GrabSupport**, the app side: launch arguments, light or dark appearance, a fail-closed launch decision, and a fixed window size.
- **GrabTesting**, the UI test side: drive the app to a screen, capture the window (or a crop of the screen for menus and sheets), detect light or dark, name the shots, attach them.
- **grab-export**: copies a run's shots out of its `.xcresult` as `NN-slug-light.png` and `NN-slug-dark.png`.

Requires macOS 27 and Swift 6.4.

## The convention

1. **One `Screenshots` build configuration** (Debug-based). In it, the app target alone sets `SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) DEBUG SCREENSHOTS`.
2. **Screenshot code lives in the app's own demo package target** and is reached only from `Main.swift` under `#if SCREENSHOTS`. Never gate it with `#if DEBUG` inside a package: Xcode builds local packages with Release settings in a configuration whose name doesn't contain "Debug".
3. **Mock data, never restricted entitlements.** The Screenshots build is `<bundle ID>.Screenshots`, signed ad hoc, and keeps only entitlements that need no provisioning profile. It gets its own container, defaults and privacy permissions, and XCUITest can't kill the user's running copy.
4. **Fail closed.** A Screenshots build launched without `-<Prefix>Screenshots YES` quits before it touches anything.

The full convention, with the reasons and per-app notes, is the `mac-app-screenshots` skill in [brightdigit/skills](https://github.com/brightdigit/skills).

## Usage

App, `Main.swift`:

```swift
#if SCREENSHOTS
  import GrabSupport
#endif

@main
struct Main: MyApp {
  #if SCREENSHOTS
    init() {
      GrabLaunchDecision(launchArguments: .init(prefix: "My")).requireScreenshotMode()
    }
  #endif
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

Export:

```sh
swift run --package-path <GrabKit> grab-export build/screenshots.xcresult build/screenshots
```

## Development

```sh
make test
make lint   # CI=1 lints without rewriting
```

## License

MIT. See [LICENSE](LICENSE).
