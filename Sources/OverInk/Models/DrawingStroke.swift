import CoreGraphics
import Foundation

struct DrawingStroke: Identifiable, Equatable {
  let id: UUID
  let tool: DrawingTool
  let color: StrokeColor
  let width: CGFloat
  var points: [CGPoint]

  init(
    id: UUID = UUID(),
    tool: DrawingTool,
    color: StrokeColor,
    width: CGFloat,
    points: [CGPoint]
  ) {
    self.id = id
    self.tool = tool
    self.color = color
    self.width = width
    self.points = points
  }

  func isNear(_ point: CGPoint, tolerance: CGFloat) -> Bool {
    StrokeGeometry.contains(point, in: self, tolerance: tolerance)
  }
}
