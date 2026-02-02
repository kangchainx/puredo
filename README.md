# Puredo

Puredo is a lightweight macOS to-do app built with SwiftUI + SwiftData, with a desktop widget for quick task viewing.

## Features

- Today-focused task list
- Priority colors (Red / Yellow / Blue)
- Search and quick add
- Light / dark theme switch
- macOS desktop widget (mini task list)

## Tech Stack

- SwiftUI
- SwiftData
- WidgetKit
- Xcode project (`Puredo.xcodeproj`)

## Project Structure

- `Puredo/` – main app source code
- `PuredoWidget/` – widget extension source code
- `Puredo.xcodeproj/` – Xcode project configuration

## Run Locally

1. Open `Puredo.xcodeproj` in Xcode.
2. Select the `Puredo` scheme.
3. Run on macOS.

## Widget

The widget reads a shared task snapshot from App Group storage and displays pending tasks in a compact view.

## CI/CD

GitHub Actions is configured to:

- Build on push / pull request (`main`)
- Package and publish a release artifact when pushing tags like `v1.0.0`

See `.github/workflows/ci-cd.yml`.

## Chinese README

For Chinese documentation, see `README.zh-CN.md`.
