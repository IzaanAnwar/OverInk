import AppKit
import Combine

final class DrawingCanvasView: NSView {
  private let displayID: DrawingStore.DisplayID
  private let store: DrawingStore
  private var currentStroke: DrawingStroke?
  private var activeTool: DrawingTool?
  private var previousMouseCoalescingState: Bool?
  private var subscriptions = Set<AnyCancellable>()
  private let eraserTolerance: CGFloat = 13

  override var isOpaque: Bool { false }
  override var acceptsFirstResponder: Bool { false }

  init(displayID: DrawingStore.DisplayID, store: DrawingStore) {
    self.displayID = displayID
    self.store = store
    super.init(frame: .zero)
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    observeStore()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { nil }

  override func resetCursorRects() {
    addCursorRect(
      bounds, cursor: ToolCursorFactory.cursor(for: store.selectedTool, color: store.selectedColor))
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    for stroke in store.strokes(on: displayID) {
      draw(stroke, in: context)
    }
    if let currentStroke { draw(currentStroke, in: context) }
  }

  override func mouseDown(with event: NSEvent) {
    beginPreciseInputSampling()
    activeTool = store.selectedTool
    let point = convert(event.locationInWindow, from: nil)
    if activeTool == .eraser {
      store.beginErasing()
      store.erase(at: point, on: displayID, tolerance: eraserTolerance)
    } else {
      currentStroke = DrawingStroke(
        tool: activeTool ?? .pen,
        color: store.selectedColor,
        width: store.effectiveStrokeWidth,
        points: [point]
      )
    }
    needsDisplay = true
  }

  override func mouseDragged(with event: NSEvent) {
    let point = convert(event.locationInWindow, from: nil)
    if activeTool == .eraser {
      store.erase(at: point, on: displayID, tolerance: eraserTolerance)
    } else if currentStroke?.tool.isFreehand == true, shouldAppend(point) {
      currentStroke?.points.append(point)
    } else if let firstPoint = currentStroke?.points.first {
      currentStroke?.points = [firstPoint, point]
    }
    needsDisplay = true
  }

  override func mouseUp(with event: NSEvent) {
    defer {
      activeTool = nil
      endPreciseInputSampling()
    }
    if activeTool == .eraser {
      store.endErasing()
    } else if var currentStroke {
      let endPoint = convert(event.locationInWindow, from: nil)
      if currentStroke.tool.isFreehand {
        if shouldAppend(endPoint) { currentStroke.points.append(endPoint) }
      } else if currentStroke.tool.isShape, let firstPoint = currentStroke.points.first {
        let distance = hypot(endPoint.x - firstPoint.x, endPoint.y - firstPoint.y)
        guard distance >= 2 else {
          self.currentStroke = nil
          needsDisplay = true
          return
        }
        currentStroke.points = [firstPoint, endPoint]
      }
      store.commit(currentStroke, on: displayID)
      self.currentStroke = nil
    }
    needsDisplay = true
  }

  override func rightMouseDown(with event: NSEvent) {
    store.stopDrawing()
  }

  private func shouldAppend(_ point: CGPoint) -> Bool {
    guard let lastPoint = currentStroke?.points.last else { return true }
    return hypot(point.x - lastPoint.x, point.y - lastPoint.y) >= 1.5
  }

  private func beginPreciseInputSampling() {
    guard previousMouseCoalescingState == nil else { return }
    previousMouseCoalescingState = NSEvent.isMouseCoalescingEnabled
    NSEvent.isMouseCoalescingEnabled = false
  }

  private func endPreciseInputSampling() {
    guard let previousMouseCoalescingState else { return }
    NSEvent.isMouseCoalescingEnabled = previousMouseCoalescingState
    self.previousMouseCoalescingState = nil
  }

  private func observeStore() {
    store.$revision
      .sink { [weak self] _ in self?.needsDisplay = true }
      .store(in: &subscriptions)
    store.$selectedTool
      .sink { [weak self] _ in
        guard let self else { return }
        window?.invalidateCursorRects(for: self)
      }
      .store(in: &subscriptions)
    store.$selectedColor
      .sink { [weak self] _ in
        guard let self else { return }
        window?.invalidateCursorRects(for: self)
      }
      .store(in: &subscriptions)
    store.$isDrawingEnabled
      .dropFirst()
      .sink { [weak self] isEnabled in
        guard let self, !isEnabled else { return }
        currentStroke = nil
        activeTool = nil
        store.endErasing()
        endPreciseInputSampling()
        needsDisplay = true
      }
      .store(in: &subscriptions)
  }

  private func draw(_ stroke: DrawingStroke, in context: CGContext) {
    guard let firstPoint = stroke.points.first else { return }
    context.saveGState()
    context.setStrokeColor(
      stroke.color.nsColor.withAlphaComponent(stroke.tool == .highlighter ? 0.34 : 1).cgColor)
    context.setFillColor(
      stroke.color.nsColor.withAlphaComponent(stroke.tool == .highlighter ? 0.34 : 1).cgColor)
    context.setLineWidth(stroke.width)
    context.setLineCap(.round)
    context.setLineJoin(.round)

    if stroke.points.count == 1 {
      let radius = stroke.width / 2
      context.fillEllipse(
        in: CGRect(
          x: firstPoint.x - radius, y: firstPoint.y - radius, width: stroke.width,
          height: stroke.width))
    } else if let path = StrokeGeometry.path(for: stroke) {
      context.addPath(path)
      context.strokePath()
    }
    context.restoreGState()
  }
}
