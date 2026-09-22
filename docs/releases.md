# Release process

1. Update `VERSION` using `major.minor.patch` and add the release notes to `CHANGELOG.md`.
2. Run `make release`.
3. Merge to `main` after CI passes.
4. Create and push an annotated tag matching `VERSION`, for example `git tag -a v0.1.1 -m 'OverInk 0.1.1'` and `git push origin v0.1.1`.
5. The Release workflow creates a universal DMG, verifies it, generates a SHA-256 checksum, and publishes both files to GitHub Releases.

Tags are immutable release identifiers. Publish a new version to fix a bad release. Do not replace assets attached to an existing tag.

## Signing and notarization

Without signing secrets, the workflow creates an ad-hoc signed community build. Gatekeeper may block downloaded community builds.

Configure these GitHub Actions secrets to enable Developer ID signing and Apple notarization:

- `MACOS_CERTIFICATE_BASE64`: Developer ID Application certificate and private key exported as a base64-encoded `.p12`
- `MACOS_CERTIFICATE_PASSWORD`: password for the `.p12`
- `MACOS_SIGNING_IDENTITY`: full Developer ID Application identity
- `APPLE_ID`, `APPLE_TEAM_ID`, `APPLE_APP_PASSWORD`: notarization credentials

The workflow imports credentials into a temporary runner keychain, enables hardened runtime signing, submits the DMG to Apple, staples the notarization ticket, and deletes the temporary keychain. Never commit credentials.
