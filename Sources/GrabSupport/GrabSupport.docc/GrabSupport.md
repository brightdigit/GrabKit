# ``GrabSupport``

The app side of screenshot mode.

## Overview

An app links GrabSupport from its demo target. Every launch asks
``GrabLaunchDecision`` before it reads any data: a Screenshots build (a
`.Screenshots` bundle ID, signed ad hoc, with its own container and
defaults) launched with `-<Prefix>Screenshots YES` runs on demo data, a
Screenshots build without it quits, and any other build runs live and
ignores the flag. There is no compile gate.

Never put screenshot code behind `#if DEBUG` in a package: Xcode builds
local packages with Release settings in a configuration whose name doesn't
contain "Debug", so the Screenshots build would compile it out.

## Topics

### Launch

- ``GrabLaunchArguments``
- ``GrabLaunchDecision``
- ``GrabAppearance``

### Windows

- ``GrabWindowSizer``
