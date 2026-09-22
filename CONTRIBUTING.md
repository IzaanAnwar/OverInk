# Contributing

Open an issue before starting a large change. Small fixes can go directly to a focused pull request that explains the problem, the new behavior, and the checks you ran.

Use Swift 6.2 or newer, macOS 26 or newer, and the macOS 26 SDK. Run these checks before submitting:

```sh
make validate
make test
make app
```

For UI changes, include screenshots that contain no private desktop content. Check light and dark appearance, Reduce Motion, multiple displays, full-screen apps, and `Shift-Command-3`, `Shift-Command-4`, and `Shift-Command-5` while drawing is active.

Never include signing certificates, Apple credentials, private screenshots, or user data in issues or commits. By contributing, you agree to license your contribution under the MIT license.
