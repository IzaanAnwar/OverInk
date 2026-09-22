import AppKit
import SwiftUI

enum DrawingTool: String, CaseIterable, Identifiable {
  case pen
  case highlighter
  case line
  case arrow
  case rectangle
  case oval
  case eraser

  var id: Self { self }

  var title: String {
    switch self {
    case .pen: "Pen"
    case .highlighter: "Highlight"
    case .line: "Line"
    case .arrow: "Arrow"
    case .rectangle: "Rectangle"
    case .oval: "Oval"
    case .eraser: "Eraser"
    }
  }

  var symbol: String {
    switch self {
    case .pen: "pencil.tip"
    case .highlighter: "highlighter"
    case .line: "line.diagonal"
    case .arrow: "arrow.up.right"
    case .rectangle: "rectangle"
    case .oval: "circle"
    case .eraser: "eraser"
    }
  }

  var isFreehand: Bool { self == .pen || self == .highlighter }
  var isShape: Bool { Self.shapeTools.contains(self) }
  var usesColor: Bool { self != .eraser }

  static let directTools: [Self] = [.pen, .highlighter, .eraser]
  static let shapeTools: [Self] = [.line, .arrow, .rectangle, .oval]
}

enum StrokeColor: String, CaseIterable, Identifiable {
  case coral
  case amber
  case mint
  case blue
  case white
  case graphite

  var id: Self { self }

  var nsColor: NSColor {
    switch self {
    case .coral: NSColor(srgbRed: 0.96, green: 0.24, blue: 0.30, alpha: 1)
    case .amber: NSColor(srgbRed: 1.00, green: 0.68, blue: 0.12, alpha: 1)
    case .mint: NSColor(srgbRed: 0.16, green: 0.76, blue: 0.52, alpha: 1)
    case .blue: NSColor(srgbRed: 0.20, green: 0.55, blue: 0.98, alpha: 1)
    case .white: .white
    case .graphite: NSColor(srgbRed: 0.12, green: 0.13, blue: 0.15, alpha: 1)
    }
  }

  var color: Color { Color(nsColor: nsColor) }
}
