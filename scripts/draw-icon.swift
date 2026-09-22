import AppKit

let size = 1024
let bitmap = NSBitmapImageRep(
  bitmapDataPlanes: nil,
  pixelsWide: size,
  pixelsHigh: size,
  bitsPerSample: 8,
  samplesPerPixel: 4,
  hasAlpha: true,
  isPlanar: false,
  colorSpaceName: .deviceRGB,
  bytesPerRow: 0,
  bitsPerPixel: 0
)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

let shell = NSBezierPath(
  roundedRect: NSRect(x: 70, y: 70, width: 884, height: 884),
  xRadius: 200,
  yRadius: 200
)
NSGradient(
  starting: NSColor(red: 0.40, green: 0.31, blue: 0.96, alpha: 1),
  ending: NSColor(red: 0.12, green: 0.57, blue: 0.97, alpha: 1)
)!.draw(in: shell, angle: -55)

let glass = NSBezierPath(ovalIn: NSRect(x: 205, y: 205, width: 614, height: 614))
NSColor.white.withAlphaComponent(0.16).setFill()
glass.fill()
NSColor.white.withAlphaComponent(0.34).setStroke()
glass.lineWidth = 5
glass.stroke()

let pen = NSBezierPath()
pen.move(to: NSPoint(x: 327, y: 306))
pen.line(to: NSPoint(x: 718, y: 697))
pen.lineCapStyle = .round
NSColor.white.withAlphaComponent(0.96).setStroke()
pen.lineWidth = 82
pen.stroke()

let center = NSBezierPath()
center.move(to: NSPoint(x: 345, y: 324))
center.line(to: NSPoint(x: 700, y: 679))
center.lineCapStyle = .round
NSColor(red: 0.24, green: 0.38, blue: 0.91, alpha: 0.72).setStroke()
center.lineWidth = 34
center.stroke()

let tip = NSBezierPath()
tip.move(to: NSPoint(x: 270, y: 249))
tip.line(to: NSPoint(x: 358, y: 284))
tip.line(to: NSPoint(x: 305, y: 337))
tip.close()
NSColor.white.withAlphaComponent(0.96).setFill()
tip.fill()

NSGraphicsContext.restoreGraphicsState()
let destination = URL(fileURLWithPath: CommandLine.arguments[1])
try bitmap.representation(using: .png, properties: [:])!.write(to: destination)
