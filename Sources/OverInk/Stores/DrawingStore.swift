import Combine
import CoreGraphics

@MainActor
final class DrawingStore: ObservableObject {
  typealias DisplayID = UInt32
  private typealias Snapshot = [DisplayID: [DrawingStroke]]

  @Published var isDrawingEnabled = false
  @Published var selectedTool: DrawingTool = .pen
  @Published var selectedColor: StrokeColor = .coral
  @Published var strokeWidth: CGFloat = 4
  @Published private(set) var revision = 0
  @Published private(set) var canUndo = false
  @Published private(set) var hasContent = false
  @Published var notice: String?

  private var strokesByDisplay: Snapshot = [:]
  private var undoSnapshots: [Snapshot] = []
  private var erasingSnapshot: Snapshot?
  private var didEraseStroke = false
  private let maximumUndoCount = 40

  var effectiveStrokeWidth: CGFloat {
    selectedTool == .highlighter ? max(14, strokeWidth * 3.5) : strokeWidth
  }

  func strokes(on displayID: DisplayID) -> [DrawingStroke] {
    strokesByDisplay[displayID] ?? []
  }

  func toggleDrawing() {
    isDrawingEnabled.toggle()
  }

  func stopDrawing() {
    isDrawingEnabled = false
  }

  func commit(_ stroke: DrawingStroke, on displayID: DisplayID) {
    guard !stroke.points.isEmpty else { return }
    recordUndoSnapshot(strokesByDisplay)
    strokesByDisplay[displayID, default: []].append(stroke)
    publishContentChange()
  }

  func beginErasing() {
    erasingSnapshot = strokesByDisplay
    didEraseStroke = false
  }

  func erase(at point: CGPoint, on displayID: DisplayID, tolerance: CGFloat) {
    guard var strokes = strokesByDisplay[displayID] else { return }
    let previousCount = strokes.count
    strokes.removeAll { $0.isNear(point, tolerance: tolerance) }
    guard strokes.count != previousCount else { return }
    strokesByDisplay[displayID] = strokes
    didEraseStroke = true
    publishContentChange()
  }

  func endErasing() {
    if didEraseStroke, let erasingSnapshot {
      recordUndoSnapshot(erasingSnapshot)
    }
    erasingSnapshot = nil
    didEraseStroke = false
  }

  func undo() {
    guard let snapshot = undoSnapshots.popLast() else { return }
    strokesByDisplay = snapshot
    publishContentChange()
    canUndo = !undoSnapshots.isEmpty
  }

  func clear() {
    guard hasContent else { return }
    recordUndoSnapshot(strokesByDisplay)
    strokesByDisplay.removeAll()
    publishContentChange()
  }

  private func recordUndoSnapshot(_ snapshot: Snapshot) {
    undoSnapshots.append(snapshot)
    if undoSnapshots.count > maximumUndoCount {
      undoSnapshots.removeFirst(undoSnapshots.count - maximumUndoCount)
    }
    canUndo = true
  }

  private func publishContentChange() {
    hasContent = strokesByDisplay.values.contains { !$0.isEmpty }
    revision &+= 1
  }
}
