# OverInk

**Ink over anything.** OverInk is a focused macOS menu-bar app for drawing over any application with a mouse or trackpad. It stays out of the way until drawing is active, then presents a compact native Liquid Glass tool strip.

[Download the latest release](https://github.com/IzaanAnwar/OverInk/releases/latest) · [View all versions](https://github.com/IzaanAnwar/OverInk/releases) · [MIT license](LICENSE)

## Use OverInk

1. Open OverInk. It appears in the menu bar without adding a Dock icon.
2. Click the OverInk icon in the menu bar, or press `Control-Option-D`.
3. Draw anywhere on screen.
4. Use the floating strip to switch tools, change color, undo, clear, or stop drawing.

Press `Escape`, right-click, or press `Control-Option-D` again to stop drawing. Existing marks stay visible while clicks pass through to the app underneath.

## What it includes

- Pen and translucent highlighter
- Straight line, arrow, rectangle, and oval
- Eraser with outline-aware hit testing
- Six colors and adjustable thickness
- Undo and Clear
- Tool-shaped cursors that reflect the current drawing color
- A floating control strip only while drawing is active

Pen and Highlighter are always freehand and follow the pointer without snapping. Line, Arrow, Rectangle, and Oval are the only tools that regularize the gesture into geometry.

OverInk supports multiple displays and full-screen Spaces. It requires macOS 26 or newer and does not require Screen Recording or Accessibility permission. It does not use analytics, accounts, or network access.

## Build locally

Build, install to the local `dist` directory, and launch:

```sh
make run
```

Run the full test suite:

```sh
make test
```

Create a signed app bundle and DMG using an ad-hoc signature:

```sh
make app
make package
```

Use `make universal` for an Intel and Apple Silicon app, or `make release` to run the complete local pipeline. Developer ID signing and notarization are optional and documented in [the release guide](docs/releases.md).

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md) before submitting changes or vulnerability reports.
