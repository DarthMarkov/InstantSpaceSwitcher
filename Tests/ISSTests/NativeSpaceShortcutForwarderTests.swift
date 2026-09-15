import CoreGraphics
import XCTest
@testable import InstantSpaceSwitcher

final class NativeSpaceShortcutForwarderTests: XCTestCase {
  private func entry(enabled: Any, parameters: [Any]) -> [String: Any] {
    ["enabled": enabled, "value": ["type": "standard", "parameters": parameters]]
  }

  func testNativeBooleanAndIntegerPreferences() {
    for key: CGKeyCode in [123, 124] {
      XCTAssertTrue(NativeSpaceShortcutForwarder.isControlArrowEnabled(
        entry: entry(enabled: true, parameters: [65535, Int(key), 8650752]),
        keyCode: key))
    }
  }

  func testStringPreferencesObservedOnMacOS27() {
    for key: CGKeyCode in [123, 124] {
      XCTAssertTrue(NativeSpaceShortcutForwarder.isControlArrowEnabled(
        entry: entry(enabled: "1", parameters: ["65535", String(key), "8650752"]),
        keyCode: key))
    }
  }

  func testMixedPreferenceRepresentations() {
    XCTAssertTrue(NativeSpaceShortcutForwarder.isControlArrowEnabled(
      entry: entry(enabled: "true", parameters: [65535, "123", 8650752]),
      keyCode: 123))
  }

  func testDisabledShortcutsAreRejected() {
    for disabled: Any in [false, 0, "0", "false", "no"] {
      XCTAssertFalse(NativeSpaceShortcutForwarder.isControlArrowEnabled(
        entry: entry(enabled: disabled, parameters: [65535, 123, 8650752]),
        keyCode: 123))
    }
  }

  func testRemappedAndMalformedShortcutsAreRejected() {
    for parameters: [Any] in [
      [65535, 124, 8650752], // Opposite arrow.
      [65535, 123, 8781824], // Extra Shift modifier.
      ["65535", "invalid", "8650752"],
      [65535, 123],
      [65535, 65659, 8650752], // Must not truncate to key code 123.
    ] {
      XCTAssertFalse(NativeSpaceShortcutForwarder.isControlArrowEnabled(
        entry: entry(enabled: true, parameters: parameters), keyCode: 123))
    }
    XCTAssertFalse(NativeSpaceShortcutForwarder.isControlArrowEnabled(
      entry: [:], keyCode: 123))
  }
}
