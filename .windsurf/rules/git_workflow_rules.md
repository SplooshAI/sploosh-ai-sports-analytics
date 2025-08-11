---
trigger: always_on
---

# Git Workflow Rules

These global rules define standardized Git workflow practices to be applied across all projects.

<branch_creation>

- Always prefix new branch names with today's date in the format YYYY.MM.DD/ (e.g., 2025.06.21/)
- Never use plain 'git checkout -b' or track main by default

</branch_creation>

<pull_request_workflow>

- When asked to create a pull request for a branch, follow this process:
  1. Review the work and commits completed in the branch
  2. Review GitHub Workflows to check for any PR title naming conventions
  3. Use the contents of .github/pull_request_template.md as the template for the PR body
  4. Use the GitHub CLI (gh) to create the pull request with a properly formatted body:

     ```bash
     gh pr create --title "TITLE" --body "# Description

<!-- Describe your changes here -->

## Type of Change

<!-- Add one of these version tags: -->
version: feat     # New feature (minor version bump)
version: feat!    # Breaking change (major version bump)
version: fix      # Bug fix (patch version bump)
version: docs     # Documentation changes
version: style    # Code style/formatting
version: refactor # Code refactoring
version: perf     # Performance improvements
version: test     # Adding/updating tests
version: build    # Dependencies/build changes
version: ci       # CI/CD changes
version: chore    # General maintenance
version: revert   # Reverting changes

## Testing

- [ ] I have tested these changes locally using `act`
- [ ] All existing tests pass
- [ ] My commits are signed with GPG"

- **PR Description Guidelines**:
  - Use proper markdown formatting with clear section headers
  - Escape special characters in shell commands
  - Use code blocks with language specification (e.g., \`\`\`bash, \`\`\`javascript)
  - Keep the description concise but informative
  - Note any breaking changes or important considerations

- **Code Formatting Rules**:
  - Never automatically commit code changes without explicit approval
  - Verify all changes work as expected before suggesting commits
  - Provide clear explanations of changes before implementing them
  - Use proper escaping for multiline strings in shell commands
  - Always verify the output format before submitting

- If a PR has already been created but needs modification:
  1. NEVER close and recreate a PR - this loses PR history and creates confusion
  2. Always use `gh pr edit PR-NUMBER` to modify an existing PR
  3. For body changes: `gh pr edit PR-NUMBER --body "NEW-BODY"`
  4. For title changes: `gh pr edit PR-NUMBER --title "NEW-TITLE"`

</pull_request_workflow>