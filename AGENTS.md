# Repository Guidelines

## Project Structure & Module Organization
This repository is a small Dart package for the arXiv API.

- `lib/arxlib.dart`: public exports for package consumers.
- `lib/src/`: internal implementation (client, query builder, parser, models, cache, HTTP adapter).
- `lib/src/parsing/atom_parser.dart`: Atom/OpenSearch XML parsing logic.
- `test/arxlib_test.dart`: unit/integration-style tests for query building, parsing, throttling, caching, and errors.
- Root docs: `README.md`, `CHANGELOG.md`, `LICENSE`.

Keep new public APIs exported via `lib/arxlib.dart`; keep implementation details in `lib/src/`.

## Build, Test, and Development Commands
Run from repository root:

- `dart pub get`: install dependencies.
- `dart analyze`: static analysis using `package:lints/recommended.yaml`.
- `dart format lib test`: format source and tests.
- `dart test`: run all tests.
- `dart test -n "parses a sample feed"`: run a focused test by name.

Use `dart analyze` and `dart test` before opening a PR.

## Coding Style & Naming Conventions
- Follow standard Dart style: 2-space indentation, trailing commas where formatter applies, no manual alignment.
- Naming: `UpperCamelCase` for classes/enums, `lowerCamelCase` for members, `snake_case.dart` filenames.
- Prefer immutable data structures and `final` fields where possible (consistent with existing models).
- Keep `lib/src/` modules focused; add a new file when logic becomes cross-cutting.

## Testing Guidelines
- Framework: `package:test`.
- Add tests for every behavioral change, especially:
  - query parameter generation,
  - parser field extraction,
  - throttling/caching behavior,
  - HTTP/API error handling.
- Test names should be descriptive sentences (current pattern: `test('builds correct query parameters', ...)`).

## Commit & Pull Request Guidelines
History is currently minimal (`init commit`), so use clear, conventional commits going forward:

- Commit message: short imperative summary, e.g. `Add API error feed parsing`.
- Keep changes scoped; separate refactors from behavior changes when practical.
- PRs should include:
  - what changed and why,
  - test evidence (`dart test`, `dart analyze`),
  - docs updates (`README.md` / `CHANGELOG.md`) when behavior or API changes.
