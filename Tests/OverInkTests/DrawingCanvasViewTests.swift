import AppKit
import Testing

@testable import OverInk

@MainActor
struct DrawingCanvasViewTests {
  @Test(arguments: [DrawingTool.pen, .highlighter])
  func slowFreehandSamplesDoNotReplaceEarlierPath(tool: DrawingTool) {
    let store = DrawingStore()
    store.selectedTool = tool
    let canvas = DrawingCanvasView(displayID: 1, store: store)
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.contentView = canvas

    canvas.mouseDown(with: event(.leftMouseDown, at: CGPoint(x: 10, y: 10), in: window))
    for point in [
      CGPoint(x: 110, y: 10),
      CGPoint(x: 110, y: 110),
      CGPoint(x: 10, y: 110),
      CGPoint(x: 10.4, y: 110.3),
    ] {
      canvas.mouseDragged(with: event(.leftMouseDragged, at: point, in: window))
    }
    canvas.mouseUp(with: event(.leftMouseUp, at: CGPoint(x: 10, y: 10), in: window))

    let stroke = store.strokes(on: 1).first
    #expect(stroke?.points.count == 5)
    #expect(stroke?.isNear(CGPoint(x: 110, y: 60), tolerance: 2) == true)
    #expect(stroke?.isNear(CGPoint(x: 60, y: 60), tolerance: 2) == false)
  }

  @Test func shapeDragUsesStartAndEndPoints() {
    let store = DrawingStore()
    store.selectedTool = .rectangle
    let canvas = DrawingCanvasView(displayID: 1, store: store)
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.contentView = canvas

    canvas.mouseDown(with: event(.leftMouseDown, at: CGPoint(x: 10, y: 10), in: window))
    canvas.mouseDragged(
      with: event(.leftMouseDragged, at: CGPoint(x: 40, y: 70), in: window)
    )
    canvas.mouseUp(with: event(.leftMouseUp, at: CGPoint(x: 100, y: 110), in: window))

    let stroke = store.strokes(on: 1).first
    #expect(stroke?.points == [CGPoint(x: 10, y: 10), CGPoint(x: 100, y: 110)])
  }

  private func event(_ type: NSEvent.EventType, at point: CGPoint, in window: NSWindow) -> NSEvent {
    NSEvent.mouseEvent(
      with: type,
      location: point,
      modifierFlags: [],
      timestamp: 0,
      windowNumber: window.windowNumber,
      context: nil,
      eventNumber: 0,
      clickCount: 1,
      pressure: 1
    )!
  }
}
