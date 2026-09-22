import CoreGraphics

enum StrokeGeometry {
  static func path(for stroke: DrawingStroke) -> CGPath? {
    guard let firstPoint = stroke.points.first else { return nil }
    let path = CGMutablePath()
    path.move(to: firstPoint)

    switch stroke.tool {
    case .pen, .highlighter:
      for point in stroke.points.dropFirst() {
        path.addLine(to: point)
      }
    case .line:
      if let lastPoint = stroke.points.last { path.addLine(to: lastPoint) }
    case .arrow:
      guard let lastPoint = stroke.points.last else { break }
      path.addLine(to: lastPoint)
      addArrowhead(to: path, from: firstPoint, to: lastPoint, lineWidth: stroke.width)
    case .rectangle:
      if let lastPoint = stroke.points.last {
        path.addRect(rect(from: firstPoint, to: lastPoint))
      }
    case .oval:
      if let lastPoint = stroke.points.last {
        path.addEllipse(in: rect(from: firstPoint, to: lastPoint))
      }
    case .eraser:
      return nil
    }
    return path
  }

  static func contains(_ point: CGPoint, in stroke: DrawingStroke, tolerance: CGFloat) -> Bool {
    guard let firstPoint = stroke.points.first else { return false }
    if stroke.points.count == 1 {
      return hypot(point.x - firstPoint.x, point.y - firstPoint.y) <= tolerance + stroke.width / 2
    }
    guard let path = path(for: stroke) else { return false }
    let hitPath = path.copy(
      strokingWithWidth: stroke.width + tolerance * 2,
      lineCap: .round,
      lineJoin: .round,
      miterLimit: 4
    )
    return hitPath.contains(point)
  }

  private static func rect(from start: CGPoint, to end: CGPoint) -> CGRect {
    CGRect(
      x: min(start.x, end.x),
      y: min(start.y, end.y),
      width: abs(end.x - start.x),
      height: abs(end.y - start.y)
    )
  }

  private static func addArrowhead(
    to path: CGMutablePath,
    from start: CGPoint,
    to end: CGPoint,
    lineWidth: CGFloat
  ) {
    let angle = atan2(end.y - start.y, end.x - start.x)
    let distance = hypot(end.x - start.x, end.y - start.y)
    let length = max(12, min(28, distance * 0.28 + lineWidth))
    let spread = CGFloat.pi / 7
    let firstWing = CGPoint(
      x: end.x - length * cos(angle - spread),
      y: end.y - length * sin(angle - spread)
    )
    let secondWing = CGPoint(
      x: end.x - length * cos(angle + spread),
      y: end.y - length * sin(angle + spread)
    )
    path.move(to: firstWing)
    path.addLine(to: end)
    path.addLine(to: secondWing)
  }
}
