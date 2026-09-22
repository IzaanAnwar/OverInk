import AppKit
import Carbon
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
  private let store = DrawingStore()
  private lazy var overlayController = OverlayController(store: store)
  private lazy var controlStripController = ControlStripController(store: store)
  private let toggleShortcut = GlobalShortcut(id: 1)
  private let escapeShortcut = GlobalShortcut(id: 2)
  private var statusItem: NSStatusItem?
  private var popover: NSPopover?
  private var subscriptions = Set<AnyCancellable>()

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    configureStatusItem()
    configurePopover()
    configureShortcuts()
    observeDrawingState()
    overlayController.start()
    controlStripController.start()
  }

  func applicationWillTerminate(_ notification: Notification) {
    toggleShortcut.stop()
    escapeShortcut.stop()
    overlayController.stop()
    controlStripController.stop()
  }

  private func configureStatusItem() {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    item.button?.target = self
    item.button?.action = #selector(togglePopover)
    item.button?.toolTip = "GlassPen"
    statusItem = item
    updateStatusItem(isDrawingEnabled: false)
  }

  private func configurePopover() {
    let popover = NSPopover()
    popover.behavior = .transient
    popover.animates = true
    popover.contentSize = NSSize(width: 300, height: 330)
    popover.contentViewController = NSHostingController(
      rootView: ControlPanelView(store: store) { NSApp.terminate(nil) }
    )
    self.popover = popover
  }

  private func configureShortcuts() {
    toggleShortcut.onPress = { [weak self] in self?.store.toggleDrawing() }
    escapeShortcut.onPress = { [weak self] in self?.store.stopDrawing() }
    let modifiers = UInt32(controlKey) | UInt32(optionKey)
    if !toggleShortcut.register(keyCode: UInt32(kVK_ANSI_D), modifiers: modifiers) {
      store.notice =
        "The ⌃⌥D shortcut is already used by another app. Use the menu-bar button to start drawing."
    }
  }

  private func observeDrawingState() {
    store.$isDrawingEnabled
      .removeDuplicates()
      .sink { [weak self] isEnabled in
        guard let self else { return }
        updateStatusItem(isDrawingEnabled: isEnabled)
        if isEnabled {
          if !escapeShortcut.register(keyCode: UInt32(kVK_Escape), modifiers: 0),
            store.notice == nil
          {
            store.notice = "Escape is unavailable. Right-click or press ⌃⌥D to stop drawing."
          }
          popover?.close()
        } else {
          escapeShortcut.unregister()
        }
      }
      .store(in: &subscriptions)
  }

  private func updateStatusItem(isDrawingEnabled: Bool) {
    let symbolName = isDrawingEnabled ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle"
    let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: "GlassPen")
    symbol?.isTemplate = true
    statusItem?.button?.image = symbol
    statusItem?.button?.contentTintColor = isDrawingEnabled ? .systemRed : nil
    statusItem?.button?.toolTip = isDrawingEnabled ? "GlassPen is drawing" : "GlassPen"
  }

  @objc private func togglePopover() {
    guard statusItem?.button != nil, let popover else { return }
    if popover.isShown {
      popover.performClose(nil)
    } else {
      showPopover()
    }
  }

  private func showPopover() {
    guard let button = statusItem?.button, let popover, !popover.isShown else { return }
    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
  }
}

@main
struct GlassPenApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    Settings { EmptyView() }
  }
}
