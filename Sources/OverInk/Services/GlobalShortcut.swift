import Carbon

@MainActor
final class GlobalShortcut {
  private var hotKey: EventHotKeyRef?
  private var handler: EventHandlerRef?
  private let identifier: EventHotKeyID
  var onPress: (() -> Void)?

  init(id: UInt32) {
    identifier = EventHotKeyID(signature: 0x4750_4E31, id: id)
    var eventType = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyPressed)
    )
    InstallEventHandler(
      GetApplicationEventTarget(),
      { _, event, context in
        guard let event, let context else { return OSStatus(eventNotHandledErr) }
        var pressedID = EventHotKeyID()
        let status = GetEventParameter(
          event,
          EventParamName(kEventParamDirectObject),
          EventParamType(typeEventHotKeyID),
          nil,
          MemoryLayout<EventHotKeyID>.size,
          nil,
          &pressedID
        )
        guard status == noErr else { return status }
        let shortcut = Unmanaged<GlobalShortcut>.fromOpaque(context).takeUnretainedValue()
        guard pressedID.id == shortcut.identifier.id else { return OSStatus(eventNotHandledErr) }
        MainActor.assumeIsolated { shortcut.onPress?() }
        return noErr
      },
      1,
      &eventType,
      Unmanaged.passUnretained(self).toOpaque(),
      &handler
    )
  }

  @discardableResult
  func register(keyCode: UInt32, modifiers: UInt32) -> Bool {
    unregister()
    var newHotKey: EventHotKeyRef?
    let status = RegisterEventHotKey(
      keyCode,
      modifiers,
      identifier,
      GetApplicationEventTarget(),
      0,
      &newHotKey
    )
    guard status == noErr else { return false }
    hotKey = newHotKey
    return true
  }

  func unregister() {
    if let hotKey { UnregisterEventHotKey(hotKey) }
    hotKey = nil
  }

  func stop() {
    unregister()
    if let handler { RemoveEventHandler(handler) }
    handler = nil
  }
}
