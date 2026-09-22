import AppKit

final class OverlayPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  init(screen: NSScreen, displayID: DrawingStore.DisplayID, store: DrawingStore) {
    super.init(
      contentRect: screen.frame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    level = .floating
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
    backgroundColor = .clear
    isOpaque = false
    hasShadow = false
    hidesOnDeactivate = false
    isReleasedWhenClosed = false
    isMovable = false
    ignoresMouseEvents = true
    acceptsMouseMovedEvents = true
    contentView = DrawingCanvasView(displayID: displayID, store: store)
    setFrame(screen.frame, display: true)
  }

  func updateFrame(for screen: NSScreen) {
    setFrame(screen.frame, display: true)
  }
}
