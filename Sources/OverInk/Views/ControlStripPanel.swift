import AppKit
import SwiftUI

final class ControlStripPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }

  init(store: DrawingStore) {
    let hostingView = NSHostingView(rootView: ControlStripView(store: store))
    super.init(
      contentRect: NSRect(x: 0, y: 0, width: 358, height: 50),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    level = .statusBar
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
    backgroundColor = .clear
    isOpaque = false
    hasShadow = false
    hidesOnDeactivate = false
    isReleasedWhenClosed = false
    isMovableByWindowBackground = true
    contentView = hostingView
  }
}
