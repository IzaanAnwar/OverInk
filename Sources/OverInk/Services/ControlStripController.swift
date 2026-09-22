import AppKit
import Combine

@MainActor
final class ControlStripController {
  private let store: DrawingStore
  private let panel: ControlStripPanel
  private var subscriptions = Set<AnyCancellable>()
  private var screenObserver: NSObjectProtocol?

  init(store: DrawingStore) {
    self.store = store
    panel = ControlStripPanel(store: store)
    store.$isDrawingEnabled
      .removeDuplicates()
      .sink { [weak self] isEnabled in self?.updateVisibility(isEnabled: isEnabled) }
      .store(in: &subscriptions)
  }

  func start() {
    updateVisibility(isEnabled: store.isDrawingEnabled)
    screenObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated { self?.keepPanelOnScreen() }
    }
  }

  func stop() {
    if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
    screenObserver = nil
    panel.close()
  }

  private func updateVisibility(isEnabled: Bool) {
    if isEnabled {
      positionPanel(on: preferredScreen())
      panel.orderFrontRegardless()
    } else {
      panel.orderOut(nil)
    }
  }

  private func keepPanelOnScreen() {
    guard !NSScreen.screens.contains(where: { $0.visibleFrame.intersects(panel.frame) }) else {
      return
    }
    positionPanel(on: preferredScreen())
  }

  private func positionPanel(on screen: NSScreen) {
    let visibleFrame = screen.visibleFrame
    let size = panel.frame.size
    let origin = NSPoint(
      x: visibleFrame.midX - size.width / 2,
      y: visibleFrame.maxY - size.height - 12
    )
    panel.setFrameOrigin(origin)
  }

  private func preferredScreen() -> NSScreen {
    let mouseLocation = NSEvent.mouseLocation
    return NSScreen.screens.first { $0.frame.contains(mouseLocation) } ?? NSScreen.main
      ?? NSScreen.screens[0]
  }

}
