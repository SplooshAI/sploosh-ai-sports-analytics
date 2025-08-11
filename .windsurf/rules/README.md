# Windsurf Global Rules

This directory contains global Windsurf rules that can be shared across all projects. These rules are designed to standardize workflows and practices across different repositories.

## How Global Rules Work

Global rules are applied across all workspaces and take precedence over workspace-specific rules. They are automatically loaded by Cascade when interacting with any repository.

## Sharing Rules Across Projects

To share these rules with other projects:

1. Copy the `.windsurf/rules` directory to your other project repositories
2. Alternatively, you can set up a central repository for these rules and symlink or copy them to other projects

## Available Rules

- **git_workflow_rules.md**: Standardized Git workflow practices including branch naming conventions and pull request creation processes

## Best Practices

- Keep rules concise and specific
- Use bullet points, numbered lists, and markdown for clarity
- Group related rules using XML tags (e.g., `<branch_creation>`, `<pull_request_workflow>`)
- Limit each rule file to 6000 characters (Windsurf limitation)
- Total global rules should not exceed 12,000 characters for optimal performance

## Adding New Rules

To add new global rules:

1. Create a new markdown file in this directory with a descriptive name
2. Format your rules using the best practices above
3. Commit and push the changes to share with your team

## Reference

For more information on Windsurf Memories & Rules, visit:
[https://docs.windsurf.com/windsurf/cascade/memories](https://docs.windsurf.com/windsurf/cascade/memories)
