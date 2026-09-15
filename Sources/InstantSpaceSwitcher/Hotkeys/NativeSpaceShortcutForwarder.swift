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

    guard
      let defaults = UserDefaults(suiteName: "com.apple.symbolichotkeys"),
      let hotkeys = defaults.dictionary(forKey: "AppleSymbolicHotKeys"),
      let entry = hotkeys[shortcutID] as? [String: Any]
    else {
      return false
    }

    return isControlArrowEnabled(entry: entry, keyCode: keyCode)
  }

  static func isControlArrowEnabled(entry: [String: Any], keyCode: CGKeyCode) -> Bool {
    let expectedFlags: CGEventFlags = [.maskControl, .maskSecondaryFn]

    // Preferences written by other tools can contain strings instead of plist
    // booleans and integers. Accept either representation of the same shortcut.
    let enabled: Bool
    if let number = entry["enabled"] as? NSNumber {
      enabled = number.boolValue
    } else if let string = entry["enabled"] as? String {
      enabled = ["1", "true", "yes"].contains(string.lowercased())
    } else {
      enabled = false
    }

    guard
      enabled,
      let value = entry["value"] as? [String: Any],
      let parameters = value["parameters"] as? [Any],
      parameters.count >= 3
    else {
      return false
    }

    return integerValue(parameters[1]) == UInt64(keyCode)
      && integerValue(parameters[2]) == expectedFlags.rawValue
  }

  private static func integerValue(_ value: Any) -> UInt64? {
    if let number = value as? NSNumber { return number.uint64Value }
    if let string = value as? String { return UInt64(string) }
    return nil
  }
}
