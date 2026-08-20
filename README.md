# InstantSpaceSwitcher

Native instant workspace switching on macOS. No more waiting for animations.

https://github.com/user-attachments/assets/037422c9-3fb7-41cd-8da7-58d28c4c8eff

## Features

- Does not require disabling SIP
- Uses native macOS spaces
- Free

A simple CLI is provided (`InstantSpaceSwitcher.app/Contents/MacOS/ISSCli --help`)

### Moving a dragged window between Spaces

InstantSpaceSwitcher can preserve macOS's native behavior of moving a window to
another Space while you drag it. Keep Mission Control's **Move left a space** and
**Move right a space** shortcuts set to Control-Left Arrow and Control-Right
Arrow, then configure InstantSpaceSwitcher with unmodified shortcuts such as F6
and F7. Modifier-based InstantSpaceSwitcher shortcuts are not supported for this
drag behavior because their held modifiers can alter the native shortcut that
InstantSpaceSwitcher posts.

While the left mouse button is held, directional switches use the native macOS
shortcuts so the dragged window follows. If those native shortcuts are disabled
or remapped, InstantSpaceSwitcher falls back to its normal instant switch and the
window remains on its original Space.


## Installation

### Homebrew

```sh
brew install --cask jurplel/tap/instant-space-switcher
```

After installation the app is located inside `/Applications/InstantSpaceSwitcher.app`


### Downloads

Pre-built binaries are available through Github Releases [here](https://github.com/jurplel/InstantSpaceSwitcher/tags).

### Build from source

```sh
git clone https://github.com/jurplel/InstantSpaceSwitcher
cd InstantSpaceSwitcher
./dist/build.sh
open ./build/InstantSpaceSwitcher.app
```

### Troubleshooting / First time startup

1. When opening the app the first time you are likely to run into any of the following warnings:

> "Apple could not verify InstantSpaceSwitcher.app is free of malware"

> "App is damaged and can’t be opened"

> "App can't be opened because the developer cannot be verified"

Please follow the instructions [here](https://wiki.hacks.guide/wiki/Open_unsigned_applications_on_macOS_Sequoia_and_newer) for instructions on how to allow the app to run[^1].

2. Afterward you will get a warning that InstantSpaceSwitcher wants to use accessibility features. You have to allow this.

3. Then open the app from the Applications folder and the configuration window should appear.

## Background
When I first bought a high refresh rate monitor, around ~2018, I could tell that the space switching animation was longer because it had scaled with the refresh rate. Because of this, I eventually stopped using spaces altogether, and have been looking for a solution ever since. 

The workaround in this project is to create a synthetic trackpad gesture with an artificially high velocity. This effectively skips the animation.

If you work at Apple, and your team owns the space switching animation, please fix this long-standing bug[^2] (and let us disable the animation natively, please).

[^1]: This happens because the app is not signed, which requires a costly Apple Developer account
[^2]: And I know for a fact there is a rdar for this
