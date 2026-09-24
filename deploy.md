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

## Optional latency diagnostics

Diagnostics are disabled by default. After quitting the app, launch with:

```sh
open /Applications/InstantSpaceSwitcher.app \
  --env ISS_TRACE_LATENCY=1 --stderr /tmp/iss-latency.log
```

This logs F6/F7 event timestamps, hotkey handling, synthetic gesture delivery,
space lookups, menu refreshes, and workspace notifications. A 25 ms background
probe measures main-queue responsiveness. For two seconds after each directional
request, a main-run-loop timer samples the cursor display's reported space state
every 10 ms and logs changes. These samples can themselves be delayed by a busy
main thread; neither state samples nor notifications measure visible frame
completion. Probes add overhead, so compare runs with the same diagnostics enabled.

To disable diagnostics, quit and relaunch with `--env ISS_TRACE_LATENCY=0`.
Normal launches without the variable also leave logging and probe timers off.
Read-only profiles can be collected with `sample <pid> 30 1 -file <path>` while
manually reproducing the issue; no screen recording or input automation is needed.

### September 24, 2026 investigation (macOS 27.0, build 26A428)

- Reduced the two phase gaps from 10 ms to 2 ms. Repeated user testing retained
  each click, but the slower second switch remained.
- Profiling caught main-thread waits in status-item rendering / animation fences.
  Skipping unchanged icons and delaying icon updates until 500 ms after the last
  space-info refresh substantially reduced the observed main-thread stalls.
  These two changes were tested together; their individual contributions are
  unknown. They did not eliminate the remaining repeat-switch delay.
- Mouse-mapped and physical F6/F7 behaved alike. Slow repeated switches commonly
  took roughly 200–500 ms to notify despite much faster gesture delivery. Sampled
  space-state changes also showed delays. Dock profiles contained rendering-service
  waits on its serial space-switching queue, but did not establish a root cause or
  prove that the delay is unavoidable.
- Companion gesture events, velocity on every phase, and terminal velocity 9999
  instead of 2000 did not reliably help. Progress 0.01 instead of 0.000016 added
  visible glitching without solving the delay. Those experiments and their
  environment-variable overrides were removed.
- The user reported a small subjective improvement after restarting Dock; this
  was not measured. A reboot comparison was not performed in this investigation.

Retained behavior: 2 ms phase gaps, original progress and terminal-only velocity,
and fewer/deferred menu-bar icon updates. No verified fix for the remaining delay.
