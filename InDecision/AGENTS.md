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


# Project Instructions

## Communication

- 모든 설명과 답변은 한국어로 작성한다.
- 코드, 파일명, 변수명, 함수명은 원문 그대로 유지한다.
- 변경한 코드의 이유를 한국어로 설명한다.

## Editing Rules

- 파일을 수정하기 전에 어떤 파일을 왜 수정할지 먼저 설명한다.
- 한 번에 여러 파일을 크게 변경하지 않는다.
- 기존 UI 디자인과 프로젝트 구조를 가능한 한 유지한다.
- 사용자의 명시적인 요청 없이 데이터 모델을 변경하지 않는다.
- 사용자의 명시적인 요청 없이 Git commit, push, reset을 실행하지 않는다.
- 파일 삭제나 되돌리기 어려운 명령을 실행하기 전에 반드시 확인한다.

## SwiftUI Project

- 이 프로젝트는 SwiftUI 기반 iOS 애플리케이션이다.
- SwiftUI의 데이터 흐름을 고려해 `@State`, `@Binding`, `@Observable`, `@Environment` 사용을 점검한다.
- 수정 후 가능한 경우 빌드 오류를 확인한다.
- 임시 해결책보다 현재 프로젝트 구조에 맞는 해결책을 우선한다.
