---
trigger: always_on
---

# Project Rules

## Semantic Versioning

- Follow semantic versioning for all changes
- Use appropriate prefixes in PR titles and commit messages:
  - `feat:` for new features (minor version bump)
  - `feat!:` for breaking changes (major version bump)
  - `fix:` for bug fixes (patch version bump)
  - Other valid prefixes: `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `chore:`, `revert:`
- Ensure PR titles match the semantic versioning pattern required by CI checks

## Project-Specific Guidelines

- Add your project-specific rules and guidelines here
- Document coding standards specific to this project
- Include any architectural decisions or patterns to follow
