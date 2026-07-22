# Repository Guidelines

## Project Structure & Module Organization

`InDecision/` contains the SwiftUI application. `InDecisionApp.swift` is the entry point; screens follow the `*View.swift` pattern, while `AuthManager.swift` and `EventManager.swift` own shared state and Supabase operations. Data types and database coding keys live in `Models.swift`. Catalog resources belong in `InDecision/Assets.xcassets/`; project settings and package pins are under `InDecision.xcodeproj/`.

## Build, Test, and Development Commands

- `open InDecision.xcodeproj` opens the project for development and simulator runs.
- `xcodebuild -resolvePackageDependencies -project InDecision.xcodeproj` resolves the pinned Supabase and SwiftUI Sliders packages.
- `xcodebuild -project InDecision.xcodeproj -scheme InDecision -destination 'generic/platform=iOS Simulator' build` performs a command-line simulator build.
- `xcodebuild clean -project InDecision.xcodeproj -scheme InDecision` clears build products when troubleshooting.

## Coding Style & Naming Conventions

Use four-space indentation, opening braces on the declaration line, and trailing closures for view builders. Use `UpperCamelCase` for types, `lowerCamelCase` for properties and functions, and name screens `FeatureView.swift`. Keep views focused; move shared state and asynchronous backend work into `@MainActor` observable managers. Map Supabase snake_case fields through explicit `CodingKeys`. No formatter or linter is configured, so use Xcode's indentation.

## Testing Guidelines

There is no test target yet. For logic changes, add an XCTest target named `InDecisionTests`, use files such as `EventManagerTests.swift`, and name methods `testCondition_expectedResult()`. Run tests with **Product > Test** or `xcodebuild test` after a shared test scheme exists. Until then, manually verify onboarding, authentication callbacks, event creation, save/join actions, and profiles.

## Commit & Pull Request Guidelines

History uses short, outcome-focused subjects such as `Fixed like count`. Prefer an imperative form, for example `Fix saved-event color state`, and keep commits scoped. Pull requests should explain the user-visible effect, list validation, link the issue, and include screenshots or a recording for UI changes. Call out database, dependency, or project-file changes.

## Security & Configuration

Treat Supabase service-role keys, user data, and local credentials as secrets. The checked-in publishable key is client-safe, but privileged keys must never enter source control. Preserve the custom `indecision://login-callback` URL flow when changing authentication.
