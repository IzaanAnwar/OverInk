import SwiftUI

struct ControlStripView: View {
  @ObservedObject var store: DrawingStore

  var body: some View {
    GlassEffectContainer(spacing: 8) {
      HStack(spacing: 8) {
        stopButton
        toolPalette
        historyPalette
      }
    }
    .padding(3)
    .frame(width: 358, height: 50)
  }

  private var stopButton: some View {
    Button {
      store.stopDrawing()
    } label: {
      Image(systemName: "stop.fill")
        .font(.system(size: 11, weight: .bold))
        .frame(width: 34, height: 34)
    }
    .buttonStyle(.glass)
    .buttonBorderShape(.circle)
    .foregroundStyle(.red)
    .focusEffectDisabled()
    .help("Stop drawing · ⌃⌥D")
    .accessibilityLabel("Stop drawing")
  }

  private var toolPalette: some View {
    HStack(spacing: 2) {
      ForEach(DrawingTool.directTools) { tool in
        toolButton(tool)
      }
      paletteDivider
      shapeMenu
      colorMenu
    }
    .padding(5)
    .frame(width: 195, height: 42)
    .glassEffect(.regular, in: .capsule)
  }

  private var historyPalette: some View {
    HStack(spacing: 2) {
      actionButton("Undo", symbol: "arrow.uturn.backward", isDisabled: !store.canUndo) {
        store.undo()
      }
      actionButton("Clear", symbol: "trash", isDisabled: !store.hasContent) {
        store.clear()
      }
    }
    .padding(5)
    .glassEffect(.regular, in: .capsule)
  }

  private func toolButton(_ tool: DrawingTool) -> some View {
    Button {
      store.selectedTool = tool
    } label: {
      Image(systemName: tool.symbol)
        .font(.system(size: 14, weight: .medium))
        .frame(width: 32, height: 32)
        .contentShape(.circle)
        .background(selectionBackground(for: tool), in: .circle)
    }
    .buttonStyle(.plain)
    .foregroundStyle(store.selectedTool == tool ? .primary : .secondary)
    .help(tool.title)
    .accessibilityLabel(tool.title)
    .accessibilityAddTraits(store.selectedTool == tool ? .isSelected : [])
  }

  private func selectionBackground(for tool: DrawingTool) -> Color {
    store.selectedTool == tool ? Color.primary.opacity(0.13) : .clear
  }

  private var shapeMenu: some View {
    let selectedShape =
      DrawingTool.shapeTools.contains(store.selectedTool) ? store.selectedTool : nil
    return Menu {
      ForEach(DrawingTool.shapeTools) { tool in
        Button {
          store.selectedTool = tool
        } label: {
          Label(tool.title, systemImage: tool.symbol)
        }
      }
    } label: {
      HStack(spacing: 3) {
        Image(systemName: selectedShape?.symbol ?? "square.on.circle")
          .font(.system(size: 13, weight: .medium))
        Image(systemName: "chevron.down")
          .font(.system(size: 7, weight: .bold))
          .foregroundStyle(.tertiary)
      }
      .frame(width: 40, height: 32)
      .contentShape(.capsule)
      .background(selectedShape == nil ? .clear : Color.primary.opacity(0.13), in: .capsule)
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .foregroundStyle(selectedShape == nil ? .secondary : .primary)
    .help(selectedShape?.title ?? "Shapes")
    .accessibilityLabel(selectedShape?.title ?? "Shapes")
  }

  private var colorMenu: some View {
    Menu {
      ForEach(StrokeColor.allCases) { color in
        Button {
          store.selectedColor = color
        } label: {
          Label(
            color.rawValue.capitalized,
            systemImage: store.selectedColor == color ? "checkmark.circle.fill" : "circle.fill"
          )
        }
      }
    } label: {
      Circle()
        .fill(store.selectedColor.color)
        .frame(width: 17, height: 17)
        .overlay { Circle().strokeBorder(.primary.opacity(0.22), lineWidth: 1) }
        .padding(7.5)
        .background(.primary.opacity(0.06), in: .circle)
        .frame(width: 32, height: 32)
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .disabled(!store.selectedTool.usesColor)
    .help("Stroke color")
    .accessibilityLabel("Stroke color")
  }

  private var paletteDivider: some View {
    Divider()
      .frame(height: 20)
      .padding(.horizontal, 3)
      .opacity(0.45)
  }

  private func actionButton(
    _ title: String,
    symbol: String,
    isDisabled: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: 13, weight: .medium))
        .frame(width: 32, height: 32)
        .contentShape(.circle)
    }
    .buttonStyle(.plain)
    .foregroundStyle(.secondary)
    .disabled(isDisabled)
    .help(title)
    .accessibilityLabel(title)
  }
}
