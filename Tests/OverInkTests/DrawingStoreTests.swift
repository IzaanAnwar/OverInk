import CoreGraphics
import Testing

@testable import OverInk

@MainActor
struct DrawingStoreTests {
  @Test func commitAndUndoRestoreEmptyCanvas() {
    let store = DrawingStore()
    store.commit(stroke(), on: 1)

    #expect(store.hasContent)
    #expect(store.canUndo)
    #expect(store.strokes(on: 1).count == 1)

    store.undo()

    #expect(!store.hasContent)
    #expect(!store.canUndo)
    #expect(store.strokes(on: 1).isEmpty)
  }

  @Test func oneEraseGestureCreatesOneUndoStep() {
    let store = DrawingStore()
    store.commit(stroke(points: [CGPoint(x: 5, y: 5)]), on: 1)
    store.commit(stroke(points: [CGPoint(x: 30, y: 30)]), on: 1)

    store.beginErasing()
    store.erase(at: CGPoint(x: 5, y: 5), on: 1, tolerance: 4)
    store.erase(at: CGPoint(x: 30, y: 30), on: 1, tolerance: 4)
    store.endErasing()

    #expect(store.strokes(on: 1).isEmpty)
    store.undo()
    #expect(store.strokes(on: 1).count == 2)
  }

  @Test func clearCanBeUndoneAcrossDisplays() {
    let store = DrawingStore()
    store.commit(stroke(), on: 1)
    store.commit(stroke(), on: 2)

    store.clear()
    #expect(!store.hasContent)

    store.undo()
    #expect(store.strokes(on: 1).count == 1)
    #expect(store.strokes(on: 2).count == 1)
  }

  @Test func eraserHitsBetweenSampledPoints() {
    let store = DrawingStore()
    store.commit(
      stroke(points: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0)]),
      on: 1
    )

    store.beginErasing()
    store.erase(at: CGPoint(x: 50, y: 2), on: 1, tolerance: 2)
    store.endErasing()

    #expect(store.strokes(on: 1).isEmpty)
  }

  @Test func missedEraseDoesNotConsumeUndo() {
    let store = DrawingStore()
    store.commit(stroke(), on: 1)

    store.beginErasing()
    store.erase(at: CGPoint(x: 500, y: 500), on: 1, tolerance: 2)
    store.endErasing()
    store.undo()

    #expect(store.strokes(on: 1).isEmpty)
  }

  @Test func rectangleEraserTargetsOutlineNotInterior() {
    let store = DrawingStore()
    let rectangle = DrawingStroke(
      tool: .rectangle,
      color: .blue,
      width: 4,
      points: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 80)]
    )
    store.commit(rectangle, on: 1)

    store.beginErasing()
    store.erase(at: CGPoint(x: 50, y: 40), on: 1, tolerance: 4)
    store.endErasing()
    #expect(store.strokes(on: 1).count == 1)

    store.beginErasing()
    store.erase(at: CGPoint(x: 50, y: 1), on: 1, tolerance: 4)
    store.endErasing()
    #expect(store.strokes(on: 1).isEmpty)
  }

  @Test func arrowShaftCanBeErased() {
    let arrow = DrawingStroke(
      tool: .arrow,
      color: .coral,
      width: 3,
      points: [CGPoint(x: 10, y: 10), CGPoint(x: 90, y: 90)]
    )

    #expect(arrow.isNear(CGPoint(x: 50, y: 50), tolerance: 3))
    #expect(!arrow.isNear(CGPoint(x: 10, y: 90), tolerance: 3))
  }

  @Test func freehandLoopPreservesIntermediatePoints() {
    let loop = DrawingStroke(
      tool: .pen,
      color: .coral,
      width: 3,
      points: [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 100, y: 0),
        CGPoint(x: 100, y: 100),
        CGPoint(x: 0, y: 100),
        CGPoint(x: 0, y: 0),
      ]
    )

    #expect(loop.isNear(CGPoint(x: 100, y: 50), tolerance: 2))
    #expect(loop.isNear(CGPoint(x: 50, y: 100), tolerance: 2))
    #expect(!loop.isNear(CGPoint(x: 50, y: 50), tolerance: 2))
  }

  private func stroke(points: [CGPoint] = [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)])
    -> DrawingStroke
  {
    DrawingStroke(tool: .pen, color: .coral, width: 4, points: points)
  }
}
