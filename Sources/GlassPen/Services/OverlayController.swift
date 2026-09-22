import AppKit
import Combine

@MainActor
final class OverlayController {
  private let store: DrawingStore
  private var panels: [DrawingStore.DisplayID: OverlayPanel] = [:]
  private var subscriptions = Set<AnyCancellable>()
  private var screenObserver: NSObjectProtocol?

  init(store: DrawingStore) {
    self.store = store
    store.$isDrawingEnabled
      .removeDuplicates()
      .sink { [weak self] isEnabled in self?.updateInteraction(isEnabled: isEnabled) }
      .store(in: &subscriptions)
  }

  func start() {
    refreshPanels()
    screenObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated { self?.refreshPanels() }
    }
  }

  func stop() {
    if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
    screenObserver = nil
    for panel in panels.values {
      panel.close()
    }
    panels.removeAll()
  }

  private func refreshPanels() {
    let connectedDisplays = Dictionary(
      uniqueKeysWithValues: NSScreen.screens.compactMap { screen in
        screen.displayID.map { ($0, screen) }
      })

    let disconnectedDisplayIDs = panels.keys.filter { connectedDisplays[$0] == nil }
    for displayID in disconnectedDisplayIDs {
      panels.removeValue(forKey: displayID)?.close()
    }

    for (displayID, screen) in connectedDisplays {
      let panel =
        panels[displayID] ?? OverlayPanel(screen: screen, displayID: displayID, store: store)
      panels[displayID] = panel
      panel.updateFrame(for: screen)
      panel.ignoresMouseEvents = !store.isDrawingEnabled
      panel.orderFrontRegardless()
    }
  }

  private func updateInteraction(isEnabled: Bool) {
    for panel in panels.values {
      panel.ignoresMouseEvents = !isEnabled
      panel.orderFrontRegardless()
    }
  }
}

extension NSScreen {
  fileprivate var displayID: DrawingStore.DisplayID? {
    (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
  }
}
