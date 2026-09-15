# Rebuild and deploy locally

Run these commands from the repository root.

## Build and test

```sh
swift test --disable-sandbox
./dist/build.sh
```

The resulting app is `build/InstantSpaceSwitcher.app`.

## Replace the installed app

Quit InstantSpaceSwitcher from its menu bar icon, then run:

```sh
ditto build/InstantSpaceSwitcher.app /Applications/InstantSpaceSwitcher.app
open /Applications/InstantSpaceSwitcher.app
```

If macOS prompts again, grant InstantSpaceSwitcher access under **System
Settings → Privacy & Security → Accessibility**.

## If the Homebrew version is still installed

Remove it once before copying a local build:

```sh
brew uninstall --cask instant-space-switcher
```

Subsequent rebuilds only require the build and replacement steps above.
