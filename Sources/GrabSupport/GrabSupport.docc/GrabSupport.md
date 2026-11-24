# ``GrabSupport``

The app side of screenshot mode.

## Overview

An app links GrabSupport only from its demo target, and reaches that target
only from `Main.swift` under `#if SCREENSHOTS`, a compilation condition set on
the app target in its `Screenshots` build configuration. Debug and Release
builds never reference it.

Never gate screenshot code with `#if DEBUG` in a package: Xcode builds local
packages with Release settings in a configuration whose name doesn't contain
"Debug".

A Screenshots build carries a `.Screenshots` bundle ID, is signed ad hoc, and
runs only on demo data. ``GrabLaunchDecision`` makes it quit unless it was
launched with `-<Prefix>Screenshots YES`.

## Topics

### Launch

- ``GrabLaunchArguments``
- ``GrabLaunchDecision``
- ``GrabAppearance``

### Windows

- ``GrabWindowSizer``
