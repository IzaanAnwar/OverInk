import AppKit

enum ToolCursorFactory {
  static func cursor(for tool: DrawingTool, color: StrokeColor) -> NSCursor {
    let imageSize = NSSize(width: 34, height: 34)
    let image = NSImage(size: imageSize)
    image.lockFocus()
    defer { image.unlockFocus() }

    let symbolName: String
    switch tool {
    case .pen: symbolName = "pencil.tip"
    case .highlighter: symbolName = "highlighter"
    case .line: symbolName = "line.diagonal"
    case .arrow: symbolName = "arrow.up.right"
    case .rectangle: symbolName = "rectangle"
    case .oval: symbolName = "circle"
    case .eraser: symbolName = "eraser"
    }

    let configuration = NSImage.SymbolConfiguration(pointSize: 19, weight: .medium)
    let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: tool.title)?
      .withSymbolConfiguration(configuration)
    let symbolRect = NSRect(x: 8, y: 8, width: 23, height: 23)
    symbol?.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1)

    let tint = tool == .eraser ? NSColor.labelColor : color.nsColor
    tint.setFill()
    symbolRect.fill(using: .sourceAtop)

    NSColor.windowBackgroundColor.withAlphaComponent(0.92).setFill()
    NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 8, height: 8)).fill()
    tint.setStroke()
    let hotspotRing = NSBezierPath(ovalIn: NSRect(x: 1, y: 1, width: 6, height: 6))
    hotspotRing.lineWidth = 1.5
    hotspotRing.stroke()

    return NSCursor(image: image, hotSpot: NSPoint(x: 4, y: 30))
  }
}
