import Carbon
import CoreGraphics
import Foundation
import ISS

enum NativeSpaceShortcutForwarder {
  static func postShortcut(for direction: ISSDirection) -> Bool {
    let keyCode = direction == ISSDirectionLeft
      ? CGKeyCode(kVK_LeftArrow)
      : CGKeyCode(kVK_RightArrow)

    guard isControlArrowEnabled(for: direction, keyCode: keyCode) else {
      return false
    }

    let source = CGEventSource(stateID: .hidSystemState)
    guard
      let controlDown = CGEvent(
        keyboardEventSource: source,
        virtualKey: CGKeyCode(kVK_Control),
        keyDown: true),
      let keyDown = CGEvent(
        keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
      let keyUp = CGEvent(
        keyboardEventSource: source, virtualKey: keyCode, keyDown: false),
      let controlUp = CGEvent(
        keyboardEventSource: source,
        virtualKey: CGKeyCode(kVK_Control),
        keyDown: false)
    else {
      return false
    }

    let flags: CGEventFlags = [.maskControl, .maskSecondaryFn]
    controlDown.flags = .maskControl
    keyDown.flags = flags
    keyUp.flags = flags
    controlUp.flags = []
    controlDown.post(tap: .cghidEventTap)
    keyDown.post(tap: .cghidEventTap)
    keyUp.post(tap: .cghidEventTap)
    controlUp.post(tap: .cghidEventTap)
    return true
  }

  private static func isControlArrowEnabled(
    for direction: ISSDirection, keyCode: CGKeyCode
  ) -> Bool {
    let shortcutID = direction == ISSDirectionLeft ? "79" : "81"
    let expectedFlags: CGEventFlags = [.maskControl, .maskSecondaryFn]

    guard
      let defaults = UserDefaults(suiteName: "com.apple.symbolichotkeys"),
      let hotkeys = defaults.dictionary(forKey: "AppleSymbolicHotKeys"),
      let entry = hotkeys[shortcutID] as? [String: Any],
      entry["enabled"] as? Bool == true,
      let value = entry["value"] as? [String: Any],
      let parameters = value["parameters"] as? [NSNumber],
      parameters.count >= 3
    else {
      return false
    }

    return parameters[1].uint16Value == keyCode
      && parameters[2].uint64Value == expectedFlags.rawValue
  }
}
