# ``GrabTesting``

Drives, captures, names and attaches an app's screenshots from a UI test.

## Overview

An app's screens are an enum conforming to ``GrabScreen``, one case per
design. A thin UI test target calls ``GrabRunner/capture(_:in:)`` once per
screen; each appearance is a fresh launch. `grab-export` then copies the
attachments out of the result bundle as `NN-slug-light.png` and
`NN-slug-dark.png`, named by the appearance detected in each image.

## Topics

### Running

- ``GrabRunner``
- ``GrabScreen``
- ``GrabTarget``
- ``GrabFixture``

### Images

- ``GrabImage``
- ``GrabCrop``
- ``GrabAppearanceDetector``
- ``GrabNaming``

### Errors

- ``GrabError``
