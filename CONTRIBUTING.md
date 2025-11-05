# Contributing to Sploosh AI Sports Analytics

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork the repository** and clone it locally
2. **Install Node.js 24 LTS** (see [README.md](README.md) for details)
3. **Review the project structure** and existing code

## Development Workflow

### Branch Naming Convention

All branches must follow the date-prefixed format:

```text
YYYY.MM.DD/descriptive-branch-name
```

Example: `2025.11.04/add-new-feature`

### Making Changes

1. Create a new branch following the naming convention above
2. Make your changes
3. Test your changes thoroughly
4. Commit with GPG-signed commits (required)
5. Push to your fork
6. Open a Pull Request

### Commit Messages

Follow semantic versioning prefixes:

- `feat:` - New feature (minor version bump)
- `feat!:` - Breaking change (major version bump)
- `fix:` - Bug fix (patch version bump)
- `docs:` - Documentation changes
- `style:` - Code style/formatting
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `test:` - Adding/updating tests
- `build:` - Dependencies/build changes
- `ci:` - CI/CD changes
- `chore:` - General maintenance

Example: `feat: add MLB playoff game download support`

### GPG Signing

All commits must be signed with GPG. To set this up:

```bash
# Generate a GPG key if you don't have one
gpg --full-generate-key

# Configure Git to use your GPG key
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

## Pull Request Process

1. **Update documentation** if you're adding new features
2. **Add tests** for new functionality when applicable
3. **Follow the PR template** provided in `.github/pull_request_template.md`
4. **Ensure all tests pass**: `npm test`
5. **Use semantic versioning** in your PR title

### PR Title Format

```text
<type>: <description>
```

Example: `feat: add support for downloading MLS game data`

## Code Style

- **Shell Scripts**: Use 2-space indentation, include proper error handling
- **Markdown**: Follow the existing documentation style
- **JSON**: Use 2-space indentation

The project includes an `.editorconfig` file to help maintain consistent coding styles.

## Testing

Before submitting a PR:

```bash
# Run all tests
npm test

# Test specific components
npm run test:workflows
npm run test:nfl:espn
```

## Adding New Sports Data Sources

When adding support for a new sport or data source:

1. Create a download script in `src/` following existing patterns
2. Add npm scripts to `package.json`
3. Update the README with usage instructions
4. Create a data directory structure under `data/`
5. Add tests if applicable

## Documentation Standards

- Use ordinal date indicators (1st, 2nd, 3rd, 4th) in all documentation
- Keep the README updated with new features
- Add inline comments for complex logic
- Update the appropriate sport-specific README files

## Sports Data Analysis Guidelines

When working with sports data:

1. **Never fabricate data** - if information isn't available, state it explicitly
2. **Verify all statistics** against the source data
3. **Cross-reference player IDs** with roster data
4. **Follow the data verification checklist** for game analysis
5. **Update README files** after downloading new game data

## Questions or Issues?

- Open an issue for bugs or feature requests
- Use discussions for questions and general topics
- Email <rob@sploosh.ai> for security concerns

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain a positive environment

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to Sploosh AI Sports Analytics! 🏒 🏈 ⚾ ⚽
