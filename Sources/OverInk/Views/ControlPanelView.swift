import AppKit
import SwiftUI

struct ControlPanelView: View {
  @ObservedObject var store: DrawingStore
  let quit: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      header
      Divider()
      VStack(spacing: 16) {
        drawingToggle
        toolControl
        colorControl
        thicknessControl
        if let notice = store.notice {
          Label(notice, systemImage: "exclamationmark.triangle.fill")
            .font(.caption)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(16)
      Divider()
      actions
    }
    .frame(width: 300)
  }

  private var header: some View {
    HStack(spacing: 10) {
      Image(systemName: "pencil.tip.crop.circle")
        .font(.system(size: 22, weight: .regular))
        .symbolRenderingMode(.hierarchical)
      VStack(alignment: .leading, spacing: 1) {
        Text("OverInk").font(.system(size: 14, weight: .semibold))
        Text("Draw over any app").font(.caption).foregroundStyle(.secondary)
      }
      Spacer()
      Text("⌃⌥D")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(.quaternary, in: .rect(cornerRadius: 6))
    }
    .padding(.horizontal, 16)
    .frame(height: 58)
  }

  private var drawingToggle: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("Drawing").fontWeight(.medium)
        Text(store.isDrawingEnabled ? "Click and drag anywhere" : "The screen remains clickable")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Toggle(
        "Drawing",
        isOn: Binding(
          get: { store.isDrawingEnabled },
          set: { store.isDrawingEnabled = $0 }
        )
      )
      .labelsHidden()
      .toggleStyle(.switch)
    }
  }

  private var toolControl: some View {
    LabeledContent("Tool") {
      Picker("Tool", selection: $store.selectedTool) {
        ForEach(DrawingTool.allCases) { tool in
          Label(tool.title, systemImage: tool.symbol).tag(tool)
        }
      }
      .labelsHidden()
      .pickerStyle(.menu)
      .frame(width: 150)
    }
  }

  private var colorControl: some View {
    LabeledContent("Color") {
      HStack(spacing: 10) {
        ForEach(StrokeColor.allCases) { color in
          Button {
            store.selectedColor = color
          } label: {
            Circle()
              .fill(color.color)
              .frame(width: 17, height: 17)
              .overlay { Circle().strokeBorder(.primary.opacity(0.14), lineWidth: 1) }
              .overlay {
                if store.selectedColor == color {
                  Circle().strokeBorder(.primary, lineWidth: 1.5).padding(-3)
                }
              }
          }
          .buttonStyle(.plain)
          .accessibilityLabel(color.rawValue.capitalized)
          .accessibilityAddTraits(store.selectedColor == color ? .isSelected : [])
        }
      }
      .opacity(store.selectedTool.usesColor ? 1 : 0.35)
      .allowsHitTesting(store.selectedTool.usesColor)
    }
  }

  private var thicknessControl: some View {
    LabeledContent("Thickness") {
      HStack(spacing: 8) {
        Slider(value: $store.strokeWidth, in: 2...12, step: 1).frame(width: 112)
        Text("\(Int(store.strokeWidth))")
          .font(.system(size: 11, design: .monospaced))
          .foregroundStyle(.secondary)
          .frame(width: 18, alignment: .trailing)
      }
      .disabled(!store.selectedTool.usesColor)
    }
  }

  private var actions: some View {
    HStack(spacing: 12) {
      Button("Undo", systemImage: "arrow.uturn.backward") { store.undo() }
        .disabled(!store.canUndo)
      Button("Clear", systemImage: "trash", role: .destructive) { store.clear() }
        .disabled(!store.hasContent)
      Spacer()
      Button("Quit") { quit() }
    }
    .buttonStyle(.borderless)
    .padding(.horizontal, 16)
    .frame(height: 48)
  }
}
